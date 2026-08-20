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

function shellDescription(sudoEnabled) {
  const base =
    "Execute a shell command on the NixOS host. Prefers the PATH-resolvable bash; " +
    "falls back to a Nix store shell path so it keeps working when the stock bash " +
    "tool cannot resolve bash (spawn bash ENOENT on NixOS). Returns exitCode/stdout/stderr " +
    "with truncation flags and spill paths. Pass `tools` to wrap the command in " +
    "`nix shell nixpkgs#<pkg>… --command` so missing POSIX tools are provided " +
    "temporarily; the accepted tool-name whitelist is listed on the `tools` parameter.";
  return sudoEnabled
    ? base + " Set sudo: true (with a justification) to run a privileged command through the external sudo daemon."
    : base;
}

const CLI_OPS = ["capabilities", "system-status", "generations", "journal", "audit-store-paths"];

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
  const shellToolName = config.shellToolName ?? "nixos_shell";
  const cliToolName = config.cliToolName ?? "nixos_cli";
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

  /** Run one local command through the dsh subprocess service. */
  async function runLocal(argv, { cwd, env, timeoutMs, maxBytes = stdoutMaxBytes }) {
    const collect = {
      maxBytes,
      spill: { maxBytes: stdoutSpillMaxBytes },
    };
    const handle = ctx.subprocess.spawn({
      argv,
      cwd,
      stdio: { stdin: "ignore", stdout: collect, stderr: collect },
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
    const finalCommand = tools.length > 0 ? wrapWithTools(command, tools) : command;

    // Sudo routing: hand the whole request to the external daemon.
    if (args.sudo === true) {
      if (!sudoEnabled) {
        throw new Error("sudo is not available: the external sudo daemon socket was not detected");
      }
      if (typeof args.justification !== "string" || args.justification.trim() === "") {
        throw new Error("justification is required with sudo: one sentence explaining why this exact command needs elevated privileges");
      }
      const response = await sudoExec(
        { command: finalCommand, cwd, env, timeoutMs },
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

    return runLocal([shell, "-c", finalCommand], { cwd, env, timeoutMs });
  }

  /** Read-only NixOS diagnostics (nixos-modern-cli "system maintenance" + pitfalls). */
  async function executeCli(args, exec) {
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
        sudoDaemonAvailable: sudoEnabled,
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

    throw new Error(`unknown op: ${op} — available: ${CLI_OPS.join(", ")}`);
  }

  ctx.tools.register(defineTool({
    name: shellToolName,
    description: shellDescription(sudoEnabled),
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
    execute: executeShell,
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
