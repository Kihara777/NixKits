/**
 * nixos-shell — consolidated NixOS operations plugin for the DeepSeek Harness.
 *
 * Functional requirements are derived from the NixKits `nixos-modern-cli`
 * skill scenarios:
 *
 * 1. NixOS is declarative/immutable: no /usr/bin, minimal PATH, no apt —
 *    every child process gets an explicit NixOS PATH layout injected, and
 *    the shell falls back to a Nix store bash when PATH resolution fails
 *    (the stock tool's `spawn bash ENOENT` failure mode).
 * 2. "Shell environment": POSIX tools are missing by default — the
 *    `tools` parameter on the shell tool wraps the command in
 *    `nix shell nixpkgs#<pkg>… --command`, using the skill's package
 *    mapping (python3, coreutils, gnused, bash, gawk, git, …).
 * 3. "Check CLI capabilities": `nixos_cli op=capabilities` probes the
 *    modern CLI surface (nixos, nix-command), the resolved shell, and
 *    the sudo daemon, and recommends the modern command set.
 * 4. "System maintenance": read-only diagnostics — `system-status`
 *    (is-system-running + failed units), `generations` (system profile
 *    listing), `journal` (per-unit tail).  Mutating maintenance (gc,
 *    optimise, rebuild) goes through the shell tool with sudo: true, so
 *    escalation always carries an explicit justification.
 * 5. "Nix store path pitfalls": `audit-store-paths` scans user config
 *    files for absolute /nix/store/ references (they go stale after gc)
 *    and checks the git credential helper form, emitting the fix rule.
 *
 * Sudo daemon integration (carried over from the former dsh-nix-shell
 * plugin): at apply time the plugin checks the configured socket path
 * (composition config `sudoSocketPath`, falling back to the
 * `NIXKITS_SUDO_SOCKET` environment variable).  When the socket exists the
 * shell tool advertises `sudo` / `justification` parameters and routes
 * `sudo: true` requests to the external root executor over a Unix socket.
 *
 * The plugin consumes only capability seams (`subprocess`, `timer`,
 * `tools`) and provides no services, so it may sit loose in any
 * composition.  Execution policy (sandbox confinement) is intentionally
 * NOT applied — pair it with the nixkits.dsh module's PATH fix.
 *
 * @module @kihara777/dsh-nixos-shell
 */
import z from "@deepseek-ai/schemastery";
import { defineTool } from "@deepseek-ai/dsh-tools";
import { existsSync, readFileSync, readdirSync, lstatSync, readlinkSync } from "node:fs";
import { homedir } from "node:os";
import net from "node:net";

export const name = "nixos-shell";

export const inject = ["subprocess", "timer", "tools"];

const DEFAULT_PATH_ENV =
  "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin";

const DEFAULT_TIMEOUT_MS = 300000;
const MAX_TIMEOUT_MS = 3600000;
const DEFAULT_STDOUT_MAX_BYTES = 2 * 1024 * 1024;
const DEFAULT_SPILL_MAX_BYTES = 16 * 1024 * 1024;
const DEFAULT_GRACE_MS = 5000;
const SUDO_DAEMON_TIMEOUT_MS = 600000;
// rebuild（锁更新 + 构建 + 激活）在慢网络下可能远超 10 分钟/1 小时；守护
// 进程侧的超时会在激活中途 SIGTERM 掉 switch，留下部分激活状态，因此识别
// 出 rebuild 命令时统一使用 6 小时上限（与守护的 MAX_TIMEOUT_MS 对齐）。
const REBUILD_TIMEOUT_MS = 21600000;
// v3 协议：job_kill 通过写一行取消请求取消后台 sudo 任务（显式带内取消，
// 而非断连——断连在 rebuild 重启 dsh 时必然发生，不能当作取消）。
const CANCEL_LINE = '{"op":"cancel"}';

/**
 * Whether the command mutates system runtime state and must run detached
 * from the sudo daemon connection:
 *   - nixos-rebuild / nixos apply: the activation restarts dsh AND
 *     stops/starts nixkits-sudo.socket (see wrapDetachedSystemCommand);
 *   - systemctl restart dsh: restarts the harness process serving this very
 *     tool call — detached so the call returns before the restart lands
 *     (used to activate updated plugins without losing the call result).
 */
function isSystemMutationCommand(command) {
  return /\b(?:nixos-rebuild|nixos\s+apply|systemctl\s+restart\s+dsh(?:\.service)?)\b/.test(command);
}

/** Rebuild-only predicate kept for the 6h timeout decision. */
function isSystemRebuildCommand(command) {
  return /\b(?:nixos-rebuild|nixos\s+apply)\b/.test(command);
}

/**
 * Wrap a system-mutating command in a detached transient systemd unit.
 *
 * Why these commands must NEVER run as daemon children: during activation,
 * switch-to-configuration restarts dsh.service AND stops nixkits-sudo.socket
 * (template change → socket restart so new connections pick up the new
 * daemon).  Stopping the socket kills every accepted @ instance together
 * with its children — which includes the switch process itself when the
 * rebuild runs through the daemon — so the activation dies mid-way and the
 * socket is left down.  A transient unit lives in its own cgroup: the socket
 * stop and the dsh restart cannot reach it, so the activation completes and
 * the socket comes back up.  The caller gets the unit name back immediately
 * and follows progress via `nixos_cli op=journal unit=<unit>` / generations.
 *
 * NOTE: the transient unit does NOT inherit the daemon's PATH (systemd
 * starts it with the manager-default environment), so the inner command
 * exports the NixOS PATH explicitly.
 */
function wrapDetachedSystemCommand(command, cwd, pathEnv) {
  const unitPrefix = isSystemRebuildCommand(command) ? "nixkits-rebuild" : "nixkits-dsh-restart";
  const unit = `${unitPrefix}-${Date.now().toString(36)}`;
  // **结局落盘**（2026-11-06 加）：detach 解决了「激活被 socket 重启杀掉」，
  // 但没有解决「dsh 重启后这次 apply 成没成没人知道」——unit 的退出码只躺在
  // journal 里，而重启后的新会话不会去翻 journal。
  //
  // 所以在 unit 内把结局写成一行：`done <ISO> exit=<code>`。位置在 /run 下，
  // 按 unit 名一一对应；`nixos_cli op=apply-status` 读它，是「唤醒之后先看什么」
  // 的依据。用 /run 而不是 /var：apply 不重启机器，/run 活得够久；
  // 真重启了那些状态本来也就过期了。
  const statusDir = "/run/nixos-apply";
  const statusFile = `${statusDir}/${unit}.status`;
  const inner =
    `mkdir -p ${shq(statusDir)} 2>/dev/null; ` +
    `printf 'running %s\\n' "$(date --iso-8601=seconds)" > ${shq(statusFile)} 2>/dev/null; ` +
    `export PATH=${shq(pathEnv)}; cd ${shq(cwd)} && ${command}; ` +
    `rc=$?; printf 'done %s exit=%d\\n' "$(date --iso-8601=seconds)" "$rc" >> ${shq(statusFile)} 2>/dev/null; exit "$rc"`;
  const wrapped =
    `/run/current-system/sw/bin/systemd-run --collect --unit=${unit} -- ` +
    `/run/current-system/sw/bin/bash -c ${shq(inner)}`;
  return { unit, statusFile, wrapped };
}

/** POSIX tool → nixpkgs package mapping (nixos-modern-cli requirement). */
const TOOL_PACKAGES = {
  python3: "python3",
  python: "python3",
  grep: "gnugrep",
  ls: "coreutils",
  cat: "coreutils",
  head: "coreutils",
  tail: "coreutils",
  wc: "coreutils",
  tr: "coreutils",
  sort: "coreutils",
  mkdir: "coreutils",
  rm: "coreutils",
  cp: "coreutils",
  mv: "coreutils",
  find: "findutils",
  env: "coreutils",
  sed: "gnused",
  bash: "bash",
  awk: "gawk",
  git: "git",
  curl: "curl",
  jq: "jq",
  ripgrep: "ripgrep",
  rsync: "rsync",
  htop: "htop",
  tree: "tree",
  unzip: "unzip",
};

/** Traditional → modern command mapping (nixos-modern-cli requirement). */
const MODERN_COMMANDS = [
  ["nixos-rebuild switch", "nixos apply (nixos binary, nixos-cli project) or nixos-rebuild switch"],
  ["nix-env -iA", "nix profile install"],
  ["nix-shell", "nix shell"],
  ["nix-build", "nix build"],
  ["nix-collect-garbage", "nix store gc"],
  ["nix-store --optimise", "nix store optimise"],
  ["nix-channel --update", "unnecessary with flakes"],
];

export const Config = z.object({
  shellToolName: z.string().default("nixos_shell"),
  cliToolName: z.string().default("nixos_cli"),
  shellPath: z.string().default("/run/current-system/sw/bin/bash"),
  pathEnv: z.string().default(DEFAULT_PATH_ENV),
  defaultTimeoutMs: z.number().default(DEFAULT_TIMEOUT_MS),
  maxTimeoutMs: z.number().default(MAX_TIMEOUT_MS),
  stdoutMaxBytes: z.number().default(DEFAULT_STDOUT_MAX_BYTES),
  stdoutSpillMaxBytes: z.number().default(DEFAULT_SPILL_MAX_BYTES),
  graceMs: z.number().default(DEFAULT_GRACE_MS),
  sudoSocketPath: z.string().default(""),
});

function shellDescription(sudoConfigured) {
  const base =
    "Execute a shell command on the NixOS host. Prefers the PATH-resolvable bash; " +
    "falls back to a Nix store shell path so it keeps working when the stock bash " +
    "tool cannot resolve bash (spawn bash ENOENT on NixOS). Returns exitCode/stdout/stderr " +
    "with truncation flags and spill paths. Pass `tools` to wrap the command in " +
    "`nix shell nixpkgs#<pkg>… --command` so missing POSIX tools are provided " +
    "temporarily; the accepted tool-name whitelist is listed on the `tools` parameter. " +
    "Set `run_in_background: true` for long-running commands (e.g. nixos-rebuild): the call " +
    "returns a job id immediately; read its output with `job_output` and stop it with `job_kill`. " +
    "A rebuild restarts the DSH service mid-activation (plugin paths are baked into the service " +
    "unit), which clears in-process job records — after one, verify completion via " +
    "`nixos_cli op=generations` instead of `job_output`; the command itself keeps running to " +
    "completion in the sudo daemon.";
  return sudoConfigured
    ? base + " Set sudo: true (with a justification) to run a privileged command through the external sudo daemon. nixos-rebuild / nixos apply commands run DETACHED in a transient systemd unit (independent cgroup): the call returns the unit name immediately and the activation survives the mid-way dsh restart and sudo-socket restart — follow progress via `nixos_cli op=journal unit=<unit>` and verify via generations. Plugin package updates do NOT restart dsh automatically (stable mount points); activate them with `systemctl restart dsh` — also auto-detached, so the call returns before the restart lands."
    : base;
}

const CLI_OPS = ["capabilities", "system-status", "generations", "journal", "audit-store-paths", "apply-status"];

function cliDescription() {
  return (
    "Read-only NixOS diagnostics (from the nixos-modern-cli scenario set). " +
    "op: capabilities (probe nixos / nix-command / shell / sudo daemon and print the " +
    "traditional→modern command map), system-status (systemctl is-system-running + failed units), " +
    "generations (system profile generations, newest first — default 20, limit up to 200), " +
    "journal (journalctl tail for one unit — unit accepts */% globs and a trailing @ matches " +
    "all template instances; optional lines), audit-store-paths (scan user config files for stale " +
    "absolute /nix/store/ references and check the git credential helper form). " +
    "Mutating maintenance (gc, optimise, rebuild) belongs to nixos_shell with sudo: true."
  );
}

/** Expand `$USER`-style placeholders in the configured PATH. */
function expandPathEnv(pathEnv) {
  const user = process.env.USER ?? "";
  return pathEnv.replaceAll("$USER", user);
}

/** Single-quote-escape a string for embedding in a shell command line. */
function shq(text) {
  return "'" + String(text).replaceAll("'", "'\\''") + "'";
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

/**
 * Execute one request through the external sudo daemon socket (v3 protocol).
 * `clientTimeoutMs` bounds how long the caller waits before giving up on the
 * response — a client-side timeout destroys the socket but the daemon keeps
 * the child running detached (disconnect is never a cancel).
 */
function sudoExec(request, socketPath, clientTimeoutMs = SUDO_DAEMON_TIMEOUT_MS) {
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
    socket.setTimeout(clientTimeoutMs, () =>
      finish({ error: "sudo daemon timed out" }),
    );
    socket.on("connect", () => {
      // v3 协议：发送一行请求后保持连接打开（守护读首行即执行，完成后
      // 回写响应并关闭连接）。若在等待期间连接断开，说明 dsh 自身被重启
      // （如 rebuild 的激活阶段）——命令仍在守护侧继续运行。
      socket.write(JSON.stringify(request) + "\n");
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
  const shellToolName = config.shellToolName ?? "nixos_shell";
  const cliToolName = config.cliToolName ?? "nixos_cli";
  const shellPath = config.shellPath ?? "/run/current-system/sw/bin/bash";
  const pathEnv = expandPathEnv(config.pathEnv ?? DEFAULT_PATH_ENV);
  const defaultTimeoutMs = config.defaultTimeoutMs ?? DEFAULT_TIMEOUT_MS;
  const maxTimeoutMs = config.maxTimeoutMs ?? MAX_TIMEOUT_MS;
  const stdoutMaxBytes = config.stdoutMaxBytes ?? DEFAULT_STDOUT_MAX_BYTES;
  const stdoutSpillMaxBytes = config.stdoutSpillMaxBytes ?? DEFAULT_SPILL_MAX_BYTES;
  const graceMs = config.graceMs ?? DEFAULT_GRACE_MS;

  // Init-time daemon configuration: configured path or the module-injected
  // env var.  The socket is validated at CALL time, not apply time: the
  // activation of a rebuild briefly stops nixkits-sudo.socket, so a harness
  // booted during that window must not permanently lose the sudo parameter.
  const configuredSocket =
    (config.sudoSocketPath ?? "").trim() ||
    process.env.NIXKITS_SUDO_SOCKET?.trim() ||
    "";
  const sudoConfigured = configuredSocket !== "";
  const sudoSocketPath = configuredSocket;
  const requireSudo = () => {
    if (!sudoConfigured || !existsSync(sudoSocketPath)) {
      throw new Error(
        "sudo is not available: the external sudo daemon socket was not detected " +
          `at ${sudoSocketPath || "(no path configured)"}. Restore it with ` +
          "`sudo systemctl start nixkits-sudo.socket`, then retry.",
      );
    }
  };

  /** Spawn one local command through the dsh subprocess service (no timeout). */
  function spawnLocal(argv, { cwd, env, maxBytes = stdoutMaxBytes }) {
    const collect = {
      maxBytes,
      spill: { maxBytes: stdoutSpillMaxBytes },
    };
    return ctx.subprocess.spawn({
      argv,
      cwd,
      stdio: { stdin: "ignore", stdout: collect, stderr: collect },
      graceMs,
      env,
    });
  }

  /** Run one local command through the dsh subprocess service. */
  async function runLocal(argv, { cwd, env, timeoutMs, maxBytes = stdoutMaxBytes }) {
    const handle = spawnLocal(argv, { cwd, env, maxBytes });

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

  /**
   * Background job hooks for one local spawn: no timeout, incremental output,
   * cancel via terminate. `readOutput` returns only the delta since the last
   * read (dsh-jobs `read` semantics); the final `done` output carries the
   * complete combined stdout/stderr.
   */
  function localBackgroundJob(argv, opts) {
    const handle = spawnLocal(argv, opts);
    let readOffset = 0;
    const fullText = () => {
      const out = readStream(handle.collected.stdout);
      const err = readStream(handle.collected.stderr);
      const text = err.text.length > 0 ? `${out.text}${out.text === "" ? "" : "\n"}${err.text}` : out.text;
      const lossy = out.lossy || err.lossy;
      return { text, lossy };
    };
    const snapshot = fullText();
    readOffset = snapshot.text.length;
    return {
      cancel: () => void handle.terminate(),
      done: handle.done
        .then((outcome) => {
          const final = fullText();
          return {
            status: "completed",
            detail: `exit code: ${outcome.exitCode ?? outcome.signal ?? "unknown"}`,
            output: final.text,
          };
        })
        .catch((error) => ({
          status: "failed",
          detail: String(error instanceof Error ? error.message : error),
        })),
      readOutput: () => {
        const current = fullText();
        if (current.text.length <= readOffset) return "";
        const delta = current.text.slice(readOffset);
        readOffset = current.text.length;
        return delta;
      },
    };
  }

  /**
   * Background job hooks for one sudo-daemon request (v3 protocol): write the
   * request and keep the connection open; the daemon responds when the command
   * finishes. Cancel writes an explicit cancel line — the daemon kills the
   * child on it (disconnect alone is NOT a cancel: a rebuild restarts dsh
   * mid-activation, which drops this connection, and the command must keep
   * running to completion). No client-side timeout: the daemon enforces the
   * per-request cap (6 hours max).
   */
  function sudoBackgroundJob(request, socketPath) {
    const socket = net.createConnection(socketPath);
    const chunks = [];
    let settled = false;
    let cancelled = false;
    let settleFn;
    const done = new Promise((resolve) => {
      settleFn = resolve;
    });
    const finish = (value) => {
      if (settled) return;
      settled = true;
      socket.destroy();
      settleFn(value);
    };
    socket.on("connect", () => {
      socket.write(JSON.stringify(request) + "\n");
    });
    socket.on("data", (chunk) => chunks.push(chunk));
    socket.on("close", () => {
      if (settled) return;
      if (cancelled) {
        // dsh-jobs 状态枚举不含 "cancelled"（running/stopping/completed/
        // killed/failed）——job_kill 取消映射为 killed。
        finish({ status: "killed", detail: "cancelled by job_kill" });
        return;
      }
      const text = Buffer.concat(chunks).toString("utf8").trim();
      if (text === "") {
        finish({ status: "failed", detail: "sudo daemon returned an empty response" });
        return;
      }
      try {
        const response = JSON.parse(text);
        if (typeof response.error === "string" && response.error !== "") {
          finish({ status: "failed", detail: response.error });
          return;
        }
        const out = response.stdout ?? "";
        const err = response.stderr ?? "";
        finish({
          status: "completed",
          detail: `exit code: ${response.exitCode ?? response.signal ?? "unknown"}${response.cancelled ? " (cancelled)" : ""}`,
          output: err.length > 0 ? `${out}${out === "" ? "" : "\n"}${err}` : out,
        });
      } catch {
        finish({ status: "failed", detail: `invalid response from sudo daemon: ${text.slice(0, 200)}` });
      }
    });
    socket.on("error", (error) =>
      finish({ status: "failed", detail: `sudo daemon connection failed: ${error.message}` }),
    );
    return {
      cancel: () => {
        if (settled || cancelled) return;
        cancelled = true;
        // end() 而非 write()+destroy()：destroy 会丢弃尚未刷出的取消行，
        // 守护收不到取消、子进程变孤儿。end 保证数据先刷出再 FIN（守护
        // 只认取消行，FIN 不触发任何动作）。
        try {
          socket.end(CANCEL_LINE + "\n");
        } catch {
          // peer already gone — the daemon keeps the child detached; the
          // client-side job record still settles below
        }
      },
      done,
    };
  }

  /** Build the nix shell tool-bootstrap wrapper (nixos-modern-cli "Shell environment"). */
  function wrapWithTools(command, tools) {
    const unknown = tools.filter((t) => !Object.prototype.hasOwnProperty.call(TOOL_PACKAGES, t));
    if (unknown.length > 0) {
      const known = Object.keys(TOOL_PACKAGES).join(", ");
      throw new Error(`unknown tool(s): ${unknown.join(", ")} — known names: ${known}`);
    }
    const pkgs = [...new Set(tools.map((t) => TOOL_PACKAGES[t]))]
      .map((p) => `nixpkgs#${p}`)
      .join(" ");
    // Uniform wrapper string: safe for both the local argv path (via bash -c)
    // and the sudo daemon path (the daemon itself runs bash -c).
    // NOT bash -lc: a login shell sources the /etc/profile chain, which
    // resets PATH and discards the `nix shell` injection entirely.
    return `exec nix shell ${pkgs} --command bash -c ${shq(command)}`;
  }

  async function executeShell(args, exec) {
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

    const tools = Array.isArray(args.tools) ? args.tools.filter((t) => typeof t === "string") : [];
    let finalCommand = tools.length > 0 ? wrapWithTools(command, tools) : command;
    // rebuild 自动分离：激活阶段会重启 dsh 并 stop/start nixkits-sudo.socket，
    // 若 rebuild 经守护执行，socket 停止会连同 switch 进程一起杀掉（@ 实例
    // 及其子进程同 cgroup），激活中途死亡且 socket 无法自动恢复。分离到
    // systemd-run 瞬态单元（独立 cgroup）后激活可以完整跑完。
    let detachedUnit = null;
    if (args.sudo === true && isSystemMutationCommand(finalCommand)) {
      const detached = wrapDetachedSystemCommand(finalCommand, cwd, pathEnv);
      finalCommand = detached.wrapped;
      detachedUnit = detached.unit;
    }

    // Background execution: register a dsh-jobs job and return its id
    // immediately (read with job_output, stop with job_kill). No timeout
    // applies; local jobs stream incremental output, sudo jobs settle on the
    // daemon response.
    if (args.run_in_background === true) {
      const jobs = ctx.get("jobs");
      if (jobs === void 0) {
        throw new Error("background jobs unavailable: load @deepseek-ai/dsh-jobs and @deepseek-ai/dsh-tool-jobs");
      }
      let hooks;
      if (args.sudo === true) {
        requireSudo();
        if (typeof args.justification !== "string" || args.justification.trim() === "") {
          throw new Error("justification is required with sudo: one sentence explaining why this exact command needs elevated privileges");
        }
        hooks = sudoBackgroundJob(
          {
            command: finalCommand,
            cwd,
            env,
            // rebuild 允许 6h（守护侧上限）；其他后台命令沿用配置上限
            timeoutMs: isSystemRebuildCommand(finalCommand) ? REBUILD_TIMEOUT_MS : maxTimeoutMs,
          },
          sudoSocketPath,
        );
        // 分离命令：systemd-run 交接即返回——任务很快 "completed" 并不代表
        // 构建成功，把验证指引追加到最终输出，避免把交接成功当构建成功。
        if (detachedUnit !== null) {
          const base = hooks;
          hooks = {
            ...base,
            done: base.done.then((result) => ({
              ...result,
              output: `${result.output ?? ""}\n[detached ${detachedUnit}: the result above only confirms the handoff — the real outcome is pending; track progress via nixos_cli op=journal unit=${detachedUnit} and verify completion via nixos_cli op=generations]`,
            })),
          };
        }
      } else {
        let shell;
        try {
          shell = await ctx.subprocess.resolveExecutable("bash");
        } catch {
          shell = shellPath;
        }
        hooks = localBackgroundJob([shell, "-c", finalCommand], { cwd, env });
      }
      return {
        kind: "background",
        jobId: jobs.start({
          kind: "bash",
          label: command,
          ...(exec.agent ? { owner: exec.agent } : {}),
          run: () => hooks,
        }),
        sudo: args.sudo === true,
        justification: args.sudo === true ? args.justification : undefined,
        ...(detachedUnit !== null ? { detachedUnit, detached: true } : {}),
      };
    }

    // Sudo routing: hand the whole request to the external daemon.
    if (args.sudo === true) {
      requireSudo();
      if (typeof args.justification !== "string" || args.justification.trim() === "") {
        throw new Error("justification is required with sudo: one sentence explaining why this exact command needs elevated privileges");
      }
      // rebuild 命令在激活阶段会重启 dsh 自身：守护侧与客户端侧的短超时
      // 都会在激活中途打断 switch，改用 6h 上限。
      const isRebuild = isSystemRebuildCommand(finalCommand);
      const daemonTimeoutMs = isRebuild ? REBUILD_TIMEOUT_MS : timeoutMs;
      const clientTimeoutMs = isRebuild ? REBUILD_TIMEOUT_MS : SUDO_DAEMON_TIMEOUT_MS;
      const response = await sudoExec(
        { command: finalCommand, cwd, env, timeoutMs: daemonTimeoutMs },
        sudoSocketPath,
        clientTimeoutMs,
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
          ...(detachedUnit !== null ? { detachedUnit, detached: true } : {}),
        };
      }
      if (detachedUnit !== null) {
        // 分离交接结果不得声称构建成功：systemd-run 只负责排队，真实成败
        // 待验证。exitCode 置 null 并给出明确的验证指引。
        return {
          exitCode: null,
          signal: null,
          timedOut: false,
          stdout: response.stdout ?? "",
          stderr: response.stderr ?? "",
          stdoutTruncated: response.stdoutTruncated ?? false,
          stderrTruncated: response.stderrTruncated ?? false,
          stdoutSpillPath: null,
          stderrSpillPath: null,
          sudo: true,
          justification: args.justification,
          detachedUnit,
          detached: true,
          note: `detached: this result only confirms the handoff to transient unit ${detachedUnit} — the real outcome is pending. Track progress via nixos_cli op=journal unit=${detachedUnit} and verify completion via nixos_cli op=generations.`,
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

    return runLocal([shell, "-c", finalCommand], { cwd, env, timeoutMs });
  }

  /** Read-only NixOS diagnostics (nixos-modern-cli "system maintenance" + pitfalls). */
  async function executeCli(args, exec) {
    // **薄封装**：`runLocal` 收的是 argv 数组（它直接交给 `ctx.subprocess.spawn`），
    // 而下面这些判断逻辑写起来是 shell 字符串更清楚。所以在这儿包一层
    // `bash -c`，免得每处调用各自拼数组。
    //
    // 注意它**不是**给用户输入用的：调用方都是本文件里写死的命令（其中拼进去的
    // 路径都过了 `shq`）。别把工具参数直接喂进来。
    const sh = (command, opts = {}) =>
      runLocal(["/run/current-system/sw/bin/bash", "-c", command], {
        timeoutMs: opts.timeoutMs ?? 15000,
        env: { PATH: pathEnv },
      });

    const op = args.op;
    const cwd = typeof args.workdir === "string" && args.workdir.length > 0
      ? args.workdir
      : (exec.agent?.cwd ?? process.cwd());
    const env = { PATH: pathEnv };
    const timeoutMs = typeof args.timeoutMs === "number" && args.timeoutMs > 0
      ? Math.min(args.timeoutMs, maxTimeoutMs)
      : Math.min(defaultTimeoutMs, 120000);

    if (op === "capabilities") {
      const nixosCli = await runLocal(["nixos", "--version"], { cwd, env, timeoutMs, maxBytes: 4096 });
      const nixCommand = await runLocal(["nix", "--version"], { cwd, env, timeoutMs, maxBytes: 4096 });
      let shell = shellPath;
      try {
        shell = await ctx.subprocess.resolveExecutable("bash");
      } catch {
        // keep the configured fallback
      }
      return {
        nixosCliAvailable: nixosCli.exitCode === 0,
        nixosCliVersion: nixosCli.stdout.trim().split("\n")[0] || null,
        nixCommandAvailable: nixCommand.exitCode === 0,
        nixVersion: nixCommand.stdout.trim().split("\n")[0] || null,
        shell,
        sudoDaemonAvailable: sudoConfigured && existsSync(sudoSocketPath),
        recommendedRebuild: nixosCli.exitCode === 0
          ? "nixos apply /etc/nixos"
          : "sudo nixos-rebuild switch --flake /etc/nixos",
        modernCommands: MODERN_COMMANDS.map(([traditional, modern]) => ({ traditional, modern })),
      };
    }

    if (op === "system-status") {
      const running = await runLocal(["systemctl", "is-system-running"], { cwd, env, timeoutMs, maxBytes: 4096 });
      const failed = await runLocal(["systemctl", "--failed", "--no-legend", "--no-pager"], { cwd, env, timeoutMs, maxBytes: 65536 });
      return {
        isSystemRunning: running.stdout.trim().split("\n")[0] || running.stderr.trim(),
        runningExitCode: running.exitCode,
        failedUnits: failed.stdout.trim(),
      };
    }

    if (op === "generations") {
      // Read-only in-process listing: nix-env --list-generations needs a
      // write lock on the profile lock file and fails for unprivileged
      // users ("opening lock file …: Permission denied"), so list the
      // profile directory symlinks directly instead.  Capped to the most
      // recent generations by default (`limit`, newest first).
      const dir = "/nix/var/nix/profiles";
      const limit = typeof args.limit === "number" && args.limit > 0
        ? Math.min(Math.floor(args.limit), 200)
        : 20;
      try {
        const current = readlinkSync(`${dir}/system`);
        const links = readdirSync(dir)
          .filter((n) => /^system-\d+-link$/.test(n))
          .sort((a, b) => {
            const na = Number(/^system-(\d+)-link$/.exec(a)?.[1] ?? 0);
            const nb = Number(/^system-(\d+)-link$/.exec(b)?.[1] ?? 0);
            return nb - na;
          });
        const truncated = links.length > limit;
        const entries = links.slice(0, limit).map((n) => {
          const st = lstatSync(`${dir}/${n}`);
          return { name: n, mtime: new Date(st.mtimeMs).toISOString() };
        });
        return {
          profileDir: dir,
          current,
          generationCount: links.length,
          truncated,
          generations: entries,
        };
      } catch (error) {
        return {
          profileDir: dir,
          generations: [],
          error: String(error instanceof Error ? error.message : error),
        };
      }
    }

    if (op === "journal") {
      let unit = typeof args.unit === "string" ? args.unit.trim() : "";
      if (unit === "") {
        throw new Error("op=journal requires unit: the systemd unit name to read");
      }
      // journalctl -u supports shell-style globs (*, %) natively; a trailing
      // `@` means "all instances of this template", so append `*`.
      if (/@$/.test(unit)) unit += "*";
      if (!/^[A-Za-z0-9@._:*%-]+$/.test(unit)) {
        throw new Error("invalid unit name: allowed characters are A-Za-z0-9@._:*%-");
      }
      const lines = typeof args.lines === "number" && args.lines > 0
        ? Math.min(Math.floor(args.lines), 500)
        : 50;
      const result = await runLocal(
        ["journalctl", "-u", unit, "-n", String(lines), "--no-pager"],
        { cwd, env, timeoutMs, maxBytes: 262144 },
      );
      return {
        exitCode: result.exitCode,
        stdout: result.stdout,
        stderr: result.stderr.trim(),
      };
    }

    if (op === "audit-store-paths") {
      const home = homedir();
      const candidates = [".gitconfig", ".bashrc", ".zshrc", ".profile"].map((f) => `${home}/${f}`);
      const findings = [];
      for (const file of candidates) {
        if (!existsSync(file)) continue;
        let raw = "";
        try {
          raw = readFileSync(file, "utf8");
        } catch {
          continue;
        }
        raw.split("\n").forEach((line, index) => {
          if (line.includes("/nix/store/")) {
            findings.push({ file, line: index + 1, snippet: line.trim().slice(0, 160) });
          }
        });
      }
      const helper = await runLocal(["git", "config", "--get", "credential.https://github.com.helper"], {
        cwd,
        env,
        timeoutMs,
        maxBytes: 4096,
      });
      const helperValue = helper.exitCode === 0 ? helper.stdout.trim() : null;
      const riskyHelper = helperValue !== null && helperValue.includes("/nix/store/");
      return {
        scannedFiles: candidates.filter((f) => existsSync(f)),
        findings,
        gitCredentialHelper: helperValue,
        gitCredentialHelperRisky: riskyHelper,
        guidance: riskyHelper
          ? "Replace the absolute /nix/store/ path in the credential helper with the bare command name: git config --global credential.https://github.com.helper '!gh auth git-credential'. Absolute store paths in config files go stale after nix store gc."
          : "No /nix/store/ references in the git credential helper. Rule: prefer bare command names (resolved via $PATH) or /run/current-system/sw/bin symlinks over absolute store paths in config files.",
      };
    }

    // **上一次 apply 的结局**（2026-11-06 加）。dsh 在激活中途会被重启，重启后
    // 的新会话不知道那次 apply 成没成——unit 的退出码只躺在 journal 里，而没人会
    // 主动去翻。`wrapDetachedSystemCommand` 现在把 `running …` / `done … exit=N`
    // 写进 `/run/nixos-apply/<unit>.status`，这个分支把它们读出来。
    //
    // **只读**：不清理、不标记已读。消费与否由调用方决定（清理是另一条判断）。
    if (op === "apply-status") {
      const dir = "/run/nixos-apply";
      const listing = await sh(`ls -1t ${shq(dir)}/*.status 2>/dev/null | head -20`, { timeoutMs: 15000 });
      const files = String(listing.stdout ?? "").split("\n").map((s) => s.trim()).filter(Boolean);
      if (files.length === 0) {
        return {
          runs: [],
          note: "还没有 detached 的 apply/rebuild 记录（或机器重启过——/run 是易失的）。",
        };
      }
      const runs = [];
      for (const file of files) {
        const body = await sh(`cat ${shq(file)} 2>/dev/null`, { timeoutMs: 10000 });
        const text = String(body.stdout ?? "");
        const unit = file.split("/").pop().replace(/\.status$/, "");
        const doneLine = text.split("\n").find((l) => l.startsWith("done "));
        const runningLine = text.split("\n").find((l) => l.startsWith("running "));
        runs.push({
          unit,
          statusFile: file,
          // `done` 存在 = 已经结束；否则还跑着（或者 unit 被杀，连 done 都没写）。
          finished: Boolean(doneLine),
          exitCode: doneLine ? Number(/exit=(-?\d+)/.exec(doneLine)?.[1] ?? NaN) : null,
          startedAt: runningLine ? runningLine.slice("running ".length) : null,
          finishedAt: doneLine ? doneLine.split(" ")[1] : null,
        });
      }
      return {
        runs,
        hint: "finished=false 可能是还在跑，也可能是 unit 被杀、连 done 都没写——两种都要看 `nixos_cli op=journal unit=<unit>` 再判。",
      };
    }

    throw new Error(`unknown op: ${op} — available: ${CLI_OPS.join(", ")}`);
  }

  ctx.tools.register(defineTool({
    name: shellToolName,
    description: shellDescription(sudoConfigured),
    parameters: {
      command: {
        type: "string",
        required: true,
        description: "The shell command to execute.",
      },
      tools: {
        type: "array",
        items: { type: "string" },
        description:
          "Optional POSIX tool names to provide via `nix shell`. Whitelist: " +
          Object.keys(TOOL_PACKAGES).join(", ") +
          ". The command then runs inside `nix shell nixpkgs#<pkg>… --command`.",
      },
      workdir: {
        type: "string",
        description: "Working directory. Defaults to the session workspace.",
      },
      timeoutMs: {
        type: "number",
        description: "Timeout in milliseconds (capped by the plugin configuration).",
      },
      run_in_background: {
        type: "boolean",
        description:
          "Run in the background and return a job id immediately (collect with job_output, stop with job_kill). No client-side timeout applies; sudo jobs carry the daemon's per-request cap. Use for long-running commands such as nixos-rebuild — note that a rebuild restarts the DSH service mid-activation, clearing the job record, so verify its completion via nixos_cli(op=generations)/journal.",
      },
      env: {
        type: "object",
        additionalProperties: true,
        description: "Extra environment entries for the command, merged over the injected NixOS PATH.",
      },
      ...(sudoConfigured ? {
        sudo: {
          type: "boolean",
          description:
            "Run the command through the external sudo daemon (root). Requires justification. " +
            "The socket is validated at call time — if it is down, restore it with `sudo systemctl start nixkits-sudo.socket`. " +
            "nixos-rebuild / nixos apply / `systemctl restart dsh` commands are auto-detached into a transient systemd unit so the call returns before any dsh/sudo-socket restart lands; detached results carry `detached: true` + `detachedUnit` + `note` and exitCode null — the handoff is NOT the build outcome, verify via journal/generations. Plugin package updates only take effect after an explicit `systemctl restart dsh`.",
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
    execute: executeShell,
  }));

  // ── nixos_apply：构建与应用分开 ────────────────────────────────────────────
  //
  // 2026-11-06 加。起因是一个反复出现的形状：`nixos apply` 一条命令里同时做了
  // 「构建」和「切换」，于是**构建失败但切换已经开始**这种情况无法表达——
  // 更糟的是激活阶段会重启 dsh，会话当场断掉，重启后的新会话不知道成没成。
  //
  // 这个工具把两段分开：
  //   1. build（同步、可失败）：只构建，不碰系统；失败就停，**不切换**；
  //   2. switch（detach）：构建确认通过后才重置系统，结局落盘到 /run/nixos-apply。
  //
  // 判据：`nixos build` 的退出码为 0 才进入第 2 段。这是「构建失败不导致应用失败」
  // 的机制化——不是靠人记得先 build。
  ctx.tools.register(defineTool({
    name: "nixos_apply",
    description:
      "Build the NixOS configuration and only then switch to it — as two separate steps. " +
      "`stage: build` (default) runs `nixos build` synchronously: it does NOT touch the running " +
      "system and it fails loudly, so a broken configuration never reaches activation. " +
      "`stage: switch` runs the activation DETACHED in a transient systemd unit (the activation " +
      "restarts dsh mid-way, so a normal call would be killed) and writes the outcome to " +
      "`/run/nixos-apply/<unit>.status` (`running …` then `done … exit=N`); read it back with " +
      "`nixos_cli op=apply-status`. Refuses to switch unless the most recent build for the same " +
      "flake directory exited 0 — that is the point of the tool, not a formality. " +
      "Use nixos_shell for anything else.",
    parameters: {
      stage: {
        type: "string",
        required: true,
        enum: ["build", "switch"],
        description: "build = compile only (safe, synchronous); switch = activate (detached, restarts dsh).",
      },
      flakeDir: {
        type: "string",
        description: "Flake directory (default /etc/nixos). Also used to match a build to a switch.",
      },
      justification: {
        type: "string",
        description: "Required with stage=switch: one sentence for the user explaining why this activation is needed.",
      },
      timeoutMs: {
        type: "number",
        description: "stage=build only: timeout in milliseconds (capped by the plugin configuration).",
      },
    },
    output: {
      schema: { type: "object", additionalProperties: true },
      render: (_args, value) => [{ type: "text", text: JSON.stringify(value, null, 2) }],
    },
    execute: async (args, exec) => {
      const stage = String(args.stage ?? "build");
      const flakeDir = typeof args.flakeDir === "string" && args.flakeDir.length > 0 ? args.flakeDir : "/etc/nixos";
      const buildStateDir = "/run/nixos-apply";

      if (stage === "switch") {
        if (!sudoConfigured) {
          throw new Error("stage=switch 需要 sudo 守护进程，但插件未配置（sudoConfigured=false）");
        }
        if (typeof args.justification !== "string" || args.justification.trim() === "") {
          throw new Error("stage=switch 需要 justification：一句话说明为什么现在要切换");
        }
        // **门**：必须有一次同一 flakeDir 的成功构建记录。这是这个工具存在的理由，
        // 不是流程装饰——它挡的正是「构建没验过就直接切换」。
        const gatePath = `${buildStateDir}/build-${flakeDir.replace(/[^a-zA-Z0-9]/g, "_")}.status`;
        const gate = await sh(`tail -1 ${shq(gatePath)} 2>/dev/null`, { timeoutMs: 10000 });
        const lastLine = String(gate.stdout ?? "").trim();
        const okBuild = /^done .* exit=0$/.test(lastLine);
        if (!okBuild) {
          throw new Error(
            `拒绝切换：${flakeDir} 没有一次通过的构建记录（${gatePath} 最后一行：${lastLine || "（空）"}）。` +
            "先跑 `nixos_apply --stage build`，构建过了再来切换——这正是「构建失败不该走到切换」那条判据。",
          );
        }
        const detached = wrapDetachedSystemCommand(
          `/run/current-system/sw/bin/nixos apply ${shq(flakeDir)} -y`,
          flakeDir,
          pathEnv,
        );
        const res = await sh(detached.wrapped, { timeoutMs: 60000 });
        return {
          detached: true,
          unit: detached.unit,
          statusFile: detached.statusFile,
          caller: String(res.stderr ?? "").trim() || undefined,
          note:
            "handoff 不是结局。激活会重启 dsh（会话可能断），完成后用 `nixos_cli op=apply-status` 读结局，再用 op=generations 确认世代。",
        };
      }

      // stage=build：同步跑，不碰系统。
      const cmd = `/run/current-system/sw/bin/nixos build ${shq(flakeDir)}`;
      const statePath = `${buildStateDir}/build-${flakeDir.replace(/[^a-zA-Z0-9]/g, "_")}.status`;
      const stamp = () => new Date().toISOString();
      await sh(`mkdir -p ${shq(buildStateDir)} 2>/dev/null; printf 'running %s\\n' ${shq(stamp())} > ${shq(statePath)} 2>/dev/null`, { timeoutMs: 10000 });
      const timeoutMs = typeof args.timeoutMs === "number" && args.timeoutMs > 0
        ? Math.min(args.timeoutMs, maxTimeoutMs)
        : defaultTimeoutMs;
      let exitCode = 0, out = "", err = "";
      try {
        const r = await sh(cmd, { timeoutMs });
        exitCode = Number(r.exitCode ?? 0);
        out = String(r.stdout ?? "");
        err = String(r.stderr ?? "");
      } catch (error) {
        exitCode = Number(error?.exitCode ?? 1);
        err = String(error?.message ?? error);
      }
      await sh(`printf 'done %s exit=%d\\n' ${shq(stamp())} ${exitCode} >> ${shq(statePath)} 2>/dev/null`, { timeoutMs: 10000 });
      return {
        stage: "build",
        flakeDir,
        exitCode,
        ok: exitCode === 0,
        statusFile: statePath,
        stdoutTail: out.slice(-4000),
        stderrTail: err.slice(-4000),
        note: exitCode === 0
          ? "构建通过。确认无误后用 `nixos_apply --stage switch` 激活（那一步会重启 dsh）。"
          : "构建失败，**没有**切换；修好再来。",
      };
    },
  }));

  ctx.tools.register(defineTool({
    name: cliToolName,
    description: cliDescription(),
    parameters: {
      op: {
        type: "string",
        required: true,
        enum: CLI_OPS,
        description: `Diagnostic operation: ${CLI_OPS.join(" / ")}.`,
      },
      unit: {
        type: "string",
        description:
          "op=journal: the systemd unit name to read. Accepts journalctl shell-style globs (*, %) " +
          "and a trailing @ (auto-appends * to match all template instances, e.g. nixkits-sudo@).",
      },
      lines: {
        type: "number",
        description: "op=journal: number of log lines to return (default 50, max 500).",
      },
      limit: {
        type: "number",
        description: "op=generations: max generations to return, newest first (default 20, max 200).",
      },
      workdir: {
        type: "string",
        description: "Working directory. Defaults to the session workspace.",
      },
      timeoutMs: {
        type: "number",
        description: "Timeout in milliseconds (capped by the plugin configuration).",
      },
    },
    output: {
      schema: { type: "object", additionalProperties: true },
      render: (_args, value) => [{ type: "text", text: JSON.stringify(value, null, 2) }],
    },
    execute: executeCli,
  }));
}
