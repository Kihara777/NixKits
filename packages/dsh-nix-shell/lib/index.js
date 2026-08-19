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
 *   the timer service.
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

export const name = "nix-shell";

export const inject = ["subprocess", "timer", "tools"];

const DEFAULT_PATH_ENV =
  "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin";

const DEFAULT_TIMEOUT_MS = 300000;
const MAX_TIMEOUT_MS = 3600000;
const DEFAULT_STDOUT_MAX_BYTES = 2 * 1024 * 1024;
const DEFAULT_SPILL_MAX_BYTES = 16 * 1024 * 1024;
const DEFAULT_GRACE_MS = 5000;

export const Config = z.object({
  toolName: z.string().default("nix_shell"),
  shellPath: z.string().default("/run/current-system/sw/bin/bash"),
  pathEnv: z.string().default(DEFAULT_PATH_ENV),
  defaultTimeoutMs: z.number().default(DEFAULT_TIMEOUT_MS),
  maxTimeoutMs: z.number().default(MAX_TIMEOUT_MS),
  stdoutMaxBytes: z.number().default(DEFAULT_STDOUT_MAX_BYTES),
  stdoutSpillMaxBytes: z.number().default(DEFAULT_SPILL_MAX_BYTES),
  graceMs: z.number().default(DEFAULT_GRACE_MS),
});

function description() {
  return (
    "Execute a shell command on the NixOS host. Prefers the PATH-resolvable bash; " +
    "falls back to a Nix store shell path so it keeps working when the stock bash " +
    "tool cannot resolve bash (spawn bash ENOENT on NixOS). Returns exitCode/stdout/stderr " +
    "with truncation flags and spill paths."
  );
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

export function apply(ctx, config = {}) {
  const toolName = config.toolName ?? "nix_shell";
  const shellPath = config.shellPath ?? "/run/current-system/sw/bin/bash";
  const pathEnv = expandPathEnv(config.pathEnv ?? DEFAULT_PATH_ENV);
  const defaultTimeoutMs = config.defaultTimeoutMs ?? DEFAULT_TIMEOUT_MS;
  const maxTimeoutMs = config.maxTimeoutMs ?? MAX_TIMEOUT_MS;
  const stdoutMaxBytes = config.stdoutMaxBytes ?? DEFAULT_STDOUT_MAX_BYTES;
  const stdoutSpillMaxBytes = config.stdoutSpillMaxBytes ?? DEFAULT_SPILL_MAX_BYTES;
  const graceMs = config.graceMs ?? DEFAULT_GRACE_MS;

  async function execute(args, exec) {
    const command = args.command;
    if (typeof command !== "string" || command.trim() === "") {
      throw new Error("invalid command: expected a non-empty string");
    }

    let shell;
    try {
      shell = await ctx.subprocess.resolveExecutable("bash");
    } catch {
      shell = shellPath;
    }

    let timeoutMs = defaultTimeoutMs;
    if (typeof args.timeoutMs === "number" && args.timeoutMs > 0) {
      timeoutMs = Math.min(args.timeoutMs, maxTimeoutMs);
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
    description: description(),
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
        additionalProperties: { type: "string" },
        description: "Extra environment entries for the command, merged over the injected NixOS PATH.",
      },
    },
    output: {
      schema: { type: "object", additionalProperties: true },
      render: (_args, value) => [{ type: "text", text: JSON.stringify(value, null, 2) }],
    },
    execute,
  }));
}
