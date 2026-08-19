#!/usr/bin/env node
/**
 * NixKits sudo executor — per-connection root command runner for the
 * dsh-nix-shell plugin.
 *
 * Designed for systemd socket activation (Accept=yes): each accepted
 * connection starts this process as root with stdin/stdout bound to the
 * socket.  Access control lives entirely at the socket level (SocketUser /
 * SocketMode gate who may connect); this process itself trusts its caller.
 *
 * Protocol (one request per connection):
 *   request (stdin, single JSON object):
 *     { "command": string, "cwd"?: string, "env"?: object, "timeoutMs"?: number }
 *   response (stdout, single JSON object, then exit):
 *     { "exitCode": number|null, "signal": string|null, "stdout": string,
 *       "stderr": string, "stdoutTruncated": bool, "stderrTruncated": bool,
 *       "timedOut": bool, "error"?: string }
 */
import { spawn } from "node:child_process";
import { createInterface } from "node:readline";

const MAX_REQUEST_BYTES = 1024 * 1024;
const MAX_OUTPUT_BYTES = 4 * 1024 * 1024;
const DEFAULT_TIMEOUT_MS = 300000;
const MAX_TIMEOUT_MS = 3600000;

function send(response) {
  process.stdout.write(JSON.stringify(response) + "\n");
}

async function readRequest() {
  const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
  let size = 0;
  const parts = [];
  for await (const line of rl) {
    size += Buffer.byteLength(line) + 1;
    if (size > MAX_REQUEST_BYTES) {
      throw new Error("request exceeds size limit");
    }
    parts.push(line);
  }
  const text = parts.join("\n");
  if (text.trim() === "") {
    throw new Error("empty request");
  }
  return JSON.parse(text);
}

function runCommand(request) {
  return new Promise((resolve) => {
    const command = String(request.command ?? "");
    if (command.trim() === "") {
      resolve({ error: "invalid command: expected a non-empty string" });
      return;
    }
    const cwd = typeof request.cwd === "string" && request.cwd.length > 0 ? request.cwd : "/";
    const timeoutMs = Math.min(
      typeof request.timeoutMs === "number" && request.timeoutMs > 0
        ? request.timeoutMs
        : DEFAULT_TIMEOUT_MS,
      MAX_TIMEOUT_MS,
    );
    const env = {
      PATH:
        "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin",
      ...process.env,
      ...(typeof request.env === "object" && request.env !== null ? request.env : {}),
    };
    delete env.NODE_OPTIONS;

    const shell = process.env.NIXKITS_SUDO_SHELL ?? "/run/current-system/sw/bin/bash";
    const child = spawn(shell, ["-c", command], {
      cwd,
      env,
      stdio: ["ignore", "pipe", "pipe"],
    });

    let stdout = "";
    let stderr = "";
    let stdoutTruncated = false;
    let stderrTruncated = false;
    let timedOut = false;

    const deadline = setTimeout(() => {
      timedOut = true;
      child.kill("SIGTERM");
      setTimeout(() => child.kill("SIGKILL"), 5000).unref();
    }, timeoutMs);

    const collect = (chunk, kind) => {
      if (kind === "stdout") {
        if (stdout.length < MAX_OUTPUT_BYTES) {
          stdout += chunk.toString("utf8");
          if (stdout.length > MAX_OUTPUT_BYTES) {
            stdout = stdout.slice(0, MAX_OUTPUT_BYTES);
            stdoutTruncated = true;
          }
        } else {
          stdoutTruncated = true;
        }
      } else {
        if (stderr.length < MAX_OUTPUT_BYTES) {
          stderr += chunk.toString("utf8");
          if (stderr.length > MAX_OUTPUT_BYTES) {
            stderr = stderr.slice(0, MAX_OUTPUT_BYTES);
            stderrTruncated = true;
          }
        } else {
          stderrTruncated = true;
        }
      }
    };
    child.stdout.on("data", (c) => collect(c, "stdout"));
    child.stderr.on("data", (c) => collect(c, "stderr"));

    child.on("error", (error) => {
      clearTimeout(deadline);
      resolve({ error: `spawn failed: ${error.message}`, timedOut });
    });
    child.on("close", (exitCode, signal) => {
      clearTimeout(deadline);
      resolve({
        exitCode,
        signal,
        timedOut,
        stdout,
        stderr,
        stdoutTruncated,
        stderrTruncated,
      });
    });
  });
}

try {
  const request = await readRequest();
  const result = await runCommand(request);
  send(result);
} catch (error) {
  send({ error: error instanceof Error ? error.message : String(error) });
}
process.exit(0);
