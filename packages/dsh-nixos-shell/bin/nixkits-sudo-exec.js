#!/usr/bin/env node
/**
 * NixKits sudo executor — per-connection root command runner for the
 * nixos-shell plugin.
 *
 * Designed for systemd socket activation (Accept=yes): each accepted
 * connection starts this process as root with stdin/stdout bound to the
 * socket.  Access control lives entirely at the socket level (SocketUser /
 * SocketMode gate who may connect); this process itself trusts its caller.
 *
 * Protocol (v3, one request per connection):
 *   request (stdin, single JSON line):
 *     { "command": string, "cwd"?: string, "env"?: object, "timeoutMs"?: number }
 *   after the request, every further input line means CANCEL: the child's
 *   whole process group gets SIGTERM (SIGKILL after a grace period).  This
 *   is the in-band mechanism job_kill uses to stop a background sudo job.
 *   response (stdout, single JSON line, then exit):
 *     { "exitCode": number|null, "signal": string|null, "stdout": string,
 *       "stderr": string, "stdoutTruncated": bool, "stderrTruncated": bool,
 *       "timedOut": bool, "cancelled": bool, "error"?: string }
 *
 * v3 语义（本协议存在的核心理由）：客户端在命令运行期间保持连接打开，
 * 但**连接断开不是取消**。`nixos-rebuild switch` 的激活阶段会重启
 * dsh.service（插件 store 路径烧进 wrapper，ExecStart 变化 → systemd
 * 重启），插件客户端随之消失、socket 断开；若把断开当取消，switch 会
 * 在激活中途被杀，留下部分激活的系统状态。因此取消必须是显式的带内
 * 取消行；对端消失时子进程以分离方式继续运行到完成，输出被丢弃。
 */
import { spawn } from "node:child_process";
import { createInterface } from "node:readline";

const MAX_REQUEST_BYTES = 1024 * 1024;
const MAX_OUTPUT_BYTES = 4 * 1024 * 1024;
const DEFAULT_TIMEOUT_MS = 300000;
// 上限放宽到 6 小时：rebuild（锁更新 + 构建 + 激活）在慢网络下可能远超
// 1 小时，超时在激活中途 SIGTERM 掉 switch 同样会留下部分激活状态。
const MAX_TIMEOUT_MS = 21600000;
const CANCEL_GRACE_MS = 5000;

/**
 * Read the single request line.  Every line after the first is forwarded to
 * `onExtraLine` — with the v3 protocol these lines are cancel requests.
 */
function readRequest(onExtraLine) {
  const rl = createInterface({ input: process.stdin, crlfDelay: Infinity });
  return new Promise((resolve, reject) => {
    rl.once("line", (line) => {
      if (Buffer.byteLength(line) > MAX_REQUEST_BYTES) {
        reject(new Error("request exceeds size limit"));
        return;
      }
      try {
        const request = JSON.parse(line);
        rl.on("line", onExtraLine);
        resolve(request);
      } catch {
        reject(new Error("invalid request JSON"));
      }
    });
    rl.once("error", reject);
  });
}

function runCommand(request, registerCancel) {
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
      ...process.env,
      // The explicit NixOS profile PATH must come AFTER the inherited env:
      // socket-activated template units inherit systemd's manager-default
      // PATH (coreutils/findutils/grep/sed/systemd store paths only), which
      // would otherwise override this and leave profile tools such as
      // nixos-rebuild or ps unresolvable inside the executed command.
      PATH:
        "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/root/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin",
      ...(typeof request.env === "object" && request.env !== null ? request.env : {}),
    };
    delete env.NODE_OPTIONS;

    const shell = process.env.NIXKITS_SUDO_SHELL ?? "/run/current-system/sw/bin/bash";
    // detached: 子进程成为新进程组组长（setsid）。取消/超时必须按进程组
    // 击杀——只杀 shell 包装进程的话，孙进程（如 sleep、nixos-rebuild 的
    // 子树）会变孤儿并继承管道写端，导致守护的 child close 永不触发、
    // 响应发不出、进程无法退出。
    const child = spawn(shell, ["-c", command], {
      cwd,
      env,
      stdio: ["ignore", "pipe", "pipe"],
      detached: true,
    });

    let stdout = "";
    let stderr = "";
    let stdoutTruncated = false;
    let stderrTruncated = false;
    let timedOut = false;
    let cancelled = false;

    /** Kill the whole process group (shell + descendants), then escalate. */
    const killGroup = () => {
      const terminate = () => {
        try {
          process.kill(-child.pid, "SIGTERM");
        } catch {
          try {
            child.kill("SIGTERM");
          } catch {
            // already gone
          }
        }
      };
      terminate();
      setTimeout(() => {
        try {
          process.kill(-child.pid, "SIGKILL");
        } catch {
          // already gone
        }
      }, CANCEL_GRACE_MS).unref();
    };

    const deadline = setTimeout(() => {
      timedOut = true;
      killGroup();
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

    // v3：取消 = 显式取消行（SIGTERM + 宽限后 SIGKILL）。连接断开
    // （dsh 重启等）不会触发任何取消逻辑——rebuild 的 switch 阶段会
    // 重启 dsh.service 并断开连接，命令必须继续运行到完成。
    registerCancel(() => {
      if (cancelled) return;
      cancelled = true;
      killGroup();
    });

    // 对端消失后输出无处可送：吞掉流错误（send 也有 destroyed 守卫），
    // 子进程以分离方式继续运行。
    process.stdout.on("error", () => {});
    process.stdin.on("error", () => {});

    child.on("error", (error) => {
      clearTimeout(deadline);
      resolve({ error: `spawn failed: ${error.message}`, timedOut, cancelled });
    });
    child.on("close", (exitCode, signal) => {
      clearTimeout(deadline);
      resolve({
        exitCode,
        signal,
        timedOut,
        cancelled,
        stdout,
        stderr,
        stdoutTruncated,
        stderrTruncated,
      });
    });
  });
}

/** Write the response and only exit once it has flushed (socket writes are async). */
function deliver(response) {
  return new Promise((resolve) => {
    if (process.stdout.destroyed || !process.stdout.writable) {
      resolve();
      return;
    }
    try {
      process.stdout.write(JSON.stringify(response) + "\n", () => resolve());
    } catch {
      resolve();
    }
  });
}

let onCancel = () => {};
try {
  const request = await readRequest((line) => onCancel(line));
  const result = await runCommand(request, (handler) => {
    onCancel = handler;
  });
  await deliver(result);
} catch (error) {
  await deliver({ error: error instanceof Error ? error.message : String(error) });
}
process.exit(0);
