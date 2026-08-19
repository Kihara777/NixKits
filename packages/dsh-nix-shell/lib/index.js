/**
 * NixOS-aware shell tool for the DeepSeek Harness.
 *
 * The stock bash tool resolves its shell through the subprocess service
 * against the dsh process PATH.  On NixOS that PATH often lacks bash
 * (`/bin/bash` does not exist), so every invocation fails with
 * `spawn bash ENOENT`.  This plugin registers a model-facing tool that:
 *
 * - prefers the PATH-resolvable `bash` when the host environment is healthy
 *   (so it degrades gracefully into a plain shell tool), and falls back to a
 *   Nix store shell path otherwise;
 * - injects an explicit NixOS PATH layout into every child process;
 * - caps foreground output with spill files and enforces a deadline through
 *   the timer service;
 * - optionally routes privileged commands to an external sudo daemon.
 *
 * Sudo daemon integration: at apply time the plugin checks the configured
 * socket path (composition config `sudoSocketPath`, falling back to the
 * `NIXKITS_SUDO_SOCKET` environment variable).  When the socket exists, the
 * tool advertises `sudo` / `justification` parameters and every `sudo: true`
 * request is executed by the daemon over a Unix socket (systemd
 * socket-activated root executor, see `nixkits-sudo-exec`).  When the socket
 * is absent the parameters are not advertised and sudo stays unavailable.
 *
 * It consumes only capability seams (`subprocess`, `timer`, `tools`) and
 * provides no services, so it may sit loose in any composition like
 * `tool-bash`.  Execution policy (sandbox confinement) is intentionally NOT
 * applied — this tool is a stopgap for hosts where the stock sandboxing bash
 * tool cannot start at all; pair it with the nixkits.dsh module's PATH fix
 * and prefer the stock tool once it works.
 *
 * @module @kihara777/dsh-nix-shell
 */
import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { existsSync } from "node:fs";
import net from "node:net";

export const name = "nix-shell";

export const inject = ["subprocess", "timer", "tools"];

const DEFAULT_PATH_ENV =
  "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin";

const DEFAULT_TIMEOUT_MS = 300000;
const MAX_TIMEOUT_MS = 3600000;
const DEFAULT_STDOUT_MAX_BYTES = 2 * 1024 * 1024;
const DEFAULT_SPILL_MAX_BYTES = 16 * 1024 * 1024;
const DEFAULT_GRACE_MS = 5000;
const SUDO_DAEMON_TIMEOUT_MS = 600000;

export const Config = z.object({
  toolName: z.string().default("nix_shell"),
  shellPath: z.string().default("/run/current-system/sw/bin/bash"),
  pathEnv: z.string().default(DEFAULT_PATH_ENV),
  defaultTimeoutMs: z.number().default(DEFAULT_TIMEOUT_MS),
  maxTimeoutMs: z.number().default(MAX_TIMEOUT_MS),
  stdoutMaxBytes: z.number().default(DEFAULT_STDOUT_MAX_BYTES),
  stdoutSpillMaxBytes: z.number().default(DEFAULT_SPILL_MAX_BYTES),
  graceMs: z.number().default(DEFAULT_GRACE_MS),
  sudoSocketPath: z.string().default(""),
});

function description(sudoEnabled) {
  const base =
    "Execute a shell command on the NixOS host. Prefers the PATH-resolvable bash; " +
    "falls back to a Nix store shell path so it keeps working when the stock bash " +
    "tool cannot resolve bash (spawn bash ENOENT on NixOS). Returns exitCode/stdout/stderr " +
    "with truncation flags and spill paths.";
  return sudoEnabled
    ? base + " Set sudo: true (with a justification) to run a privileged command through the external sudo daemon."
    : base;
}

/** Expand `$USER`-style placeholders in the configured PATH. */
function expandPathEnv(pathEnv) {
  const user = process.env.USER ?? "";
  return pathEnv.replaceAll("$USER", user);
}

/** Read a collected stream, normalizing absent/undefined spill paths to null. */
function readStream(reader) {
  if (reader === undefined) {
    return { text: "", lossy: false, spillPath: null };
  }
  const read = reader.readFrom(0);
  return {
    text: read.text,
    lossy: read.lossy,
    spillPath: read.spillPath ?? null,
  };
}

/** Execute one request through the external sudo daemon socket. */
function sudoExec(request, socketPath) {
  return new Promise((resolve) => {
    const socket = net.createConnection(socketPath);
    const chunks = [];
    let settled = false;
    const finish = (value) => {
      if (settled) return;
      settled = true;
      socket.destroy();
      resolve(value);
    };
    socket.setTimeout(SUDO_DAEMON_TIMEOUT_MS, () =>
      finish({ error: "sudo daemon timed out" }),
    );
    socket.on("connect", () => {
      socket.write(JSON.stringify(request) + "\n");
      socket.end();
    });
    socket.on("data", (chunk) => chunks.push(chunk));
    socket.on("close", () => {
      const text = Buffer.concat(chunks).toString("utf8");
      if (text.trim() === "") {
        finish({ error: "sudo daemon returned an empty response" });
        return;
      }
      try {
        finish(JSON.parse(text));
      } catch {
        finish({ error: `invalid response from sudo daemon: ${text.slice(0, 200)}` });
      }
    });
    socket.on("error", (error) =>
      finish({ error: `sudo daemon connection failed: ${error.message}` }),
    );
  });
}

export function apply(ctx, config = {}) {
  const toolName = config.toolName ?? "nix_shell";
  const shellPath = config.shellPath ?? "/run/current-system/sw/bin/bash";
  const pathEnv = expandPathEnv(config.pathEnv ?? DEFAULT_PATH_ENV);
  const defaultTimeoutMs = config.defaultTimeoutMs ?? DEFAULT_TIMEOUT_MS;
  const maxTimeoutMs = config.maxTimeoutMs ?? MAX_TIMEOUT_MS;
  const stdoutMaxBytes = config.stdoutMaxBytes ?? DEFAULT_STDOUT_MAX_BYTES;
  const stdoutSpillMaxBytes = config.stdoutSpillMaxBytes ?? DEFAULT_SPILL_MAX_BYTES;
  const graceMs = config.graceMs ?? DEFAULT_GRACE_MS;

  // Init-time daemon detection: configured path or the module-injected env
  // var, gated on the socket actually existing.
  const configuredSocket =
    (config.sudoSocketPath ?? "").trim() ||
    process.env.NIXKITS_SUDO_SOCKET?.trim() ||
    "";
  const sudoEnabled = configuredSocket !== "" && existsSync(configuredSocket);
  const sudoSocketPath = configuredSocket;

  async function execute(args, exec) {
    const command = args.command;
    if (typeof command !== "string" || command.trim() === "") {
      throw new Error("invalid command: expected a non-empty string");
    }

    const cwd = typeof args.workdir === "string" && args.workdir.length > 0
      ? args.workdir
      : (exec.agent?.cwd ?? process.cwd());

    const env = { PATH: pathEnv };
    if (args.env !== undefined && args.env !== null && typeof args.env === "object") {
      for (const [key, value] of Object.entries(args.env)) {
        if (typeof value === "string") env[key] = value;
      }
    }

    let timeoutMs = defaultTimeoutMs;
    if (typeof args.timeoutMs === "number" && args.timeoutMs > 0) {
      timeoutMs = Math.min(args.timeoutMs, maxTimeoutMs);
    }

    // Sudo routing: hand the whole request to the external daemon.
    if (args.sudo === true) {
      if (!sudoEnabled) {
        throw new Error("sudo is not available: the external sudo daemon socket was not detected");
      }
      if (typeof args.justification !== "string" || args.justification.trim() === "") {
        throw new Error("justification is required with sudo: one sentence explaining why this exact command needs elevated privileges");
      }
      const response = await sudoExec(
        { command, cwd, env, timeoutMs },
        sudoSocketPath,
      );
      if (typeof response.error === "string" && response.error !== "") {
        return {
          exitCode: null,
          signal: null,
          timedOut: false,
          stdout: "",
          stderr: response.error,
          stdoutTruncated: false,
          stderrTruncated: false,
          stdoutSpillPath: null,
          stderrSpillPath: null,
          sudo: true,
          justification: args.justification,
        };
      }
      return {
        exitCode: response.exitCode ?? null,
        signal: response.signal ?? null,
        timedOut: response.timedOut ?? false,
        stdout: response.stdout ?? "",
        stderr: response.stderr ?? "",
        stdoutTruncated: response.stdoutTruncated ?? false,
        stderrTruncated: response.stderrTruncated ?? false,
        stdoutSpillPath: null,
        stderrSpillPath: null,
        sudo: true,
        justification: args.justification,
      };
    }

    let shell;
    try {
      shell = await ctx.subprocess.resolveExecutable("bash");
    } catch {
      shell = shellPath;
    }

    const collect = {
      maxBytes: stdoutMaxBytes,
      spill: { maxBytes: stdoutSpillMaxBytes },
    };

    const handle = ctx.subprocess.spawn({
      argv: [shell, "-c", command],
      cwd,
      stdio: {
        stdin: "ignore",
        stdout: collect,
        stderr: collect,
      },
      graceMs,
      env,
    });

    let timedOut = false;
    const deadline = (async () => {
      await ctx.timer.timeout(timeoutMs);
      timedOut = true;
      handle.terminate();
    })();

    let outcome;
    try {
      outcome = await handle.done;
    } catch (error) {
      return {
        exitCode: null,
        signal: null,
        timedOut,
        stdout: "",
        stderr: String(error instanceof Error ? error.message : error),
        stdoutTruncated: false,
        stderrTruncated: false,
        stdoutSpillPath: null,
        stderrSpillPath: null,
      };
    }

    const out = readStream(handle.collected.stdout);
    const err = readStream(handle.collected.stderr);
    return {
      exitCode: outcome.exitCode ?? null,
      signal: outcome.signal ?? null,
      timedOut,
      stdout: out.text,
      stderr: err.text,
      stdoutTruncated: out.lossy,
      stderrTruncated: err.lossy,
      stdoutSpillPath: out.spillPath,
      stderrSpillPath: err.spillPath,
    };
  }

  ctx.tools.register(defineTool({
    name: toolName,
    description: description(sudoEnabled),
    parameters: {
      command: {
        type: "string",
        required: true,
        description: "The shell command to execute.",
      },
      workdir: {
        type: "string",
        description: "Working directory. Defaults to the session workspace.",
      },
      timeoutMs: {
        type: "number",
        description: "Timeout in milliseconds (capped by the plugin configuration).",
      },
      env: {
        type: "object",
        additionalProperties: true,
        description: "Extra environment entries for the command, merged over the injected NixOS PATH.",
      },
      ...(sudoEnabled ? {
        sudo: {
          type: "boolean",
          description: "Run the command through the external sudo daemon (root). Requires justification.",
        },
        justification: {
          type: "string",
          description: "Required with sudo: one sentence for the user explaining why this exact command needs elevated privileges.",
        },
      } : {}),
    },
    output: {
      schema: { type: "object", additionalProperties: true },
      render: (_args, value) => [{ type: "text", text: JSON.stringify(value, null, 2) }],
    },
    execute,
  }));
}
