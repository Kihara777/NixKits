# dsh-nixos-shell

[中文](../zh/dsh-nixos-shell.md) | English | [日本語](../ja/dsh-nixos-shell.md)  | [偽中国語](../pcn/dsh-nixos-shell.md)

A DeepSeek Harness (DSH) plugin for NixOS scenario capabilities — a **single plugin consolidating** shell execution, tool bootstrap, sudo-daemon routing, and read-only NixOS diagnostics. Functional requirements derive from the `nixos-modern-cli` skill scenarios (declarative immutable NixOS, minimal PATH, modern CLI, system maintenance, Nix store path pitfalls).

## Basic Info

| Item | Value |
|------|-------|
| Type | DSH Host plugin (npm package) |
| npm name | `@kihara777/dsh-nixos-shell` |
| Version | `0.1.0` |
| License | MIT |
| Requirements | Host dsh tree (`subprocess`/`timer`/`tools` capability seams and peer deps) |
| Supersedes | `dsh-nix-shell` (shell tool + sudo daemon) and `dsh-skill-nixkits` (7 skill plugins, abandoned) |

## Tools

### nixos_shell — shell executor

| Parameter | Description |
|-----------|-------------|
| `command` | Shell command to execute (required) |
| `tools` | Optional POSIX tool names; the command runs via `nix shell nixpkgs#<pkg>… --command`. Whitelist: python3, python, grep, ls, cat, head, tail, wc, tr, sort, mkdir, rm, cp, mv, find, env, sed, bash, awk, git, curl, jq, ripgrep, rsync, htop, tree, unzip |
| `workdir` / `timeoutMs` / `env` | Working directory / timeout (capped by config) / extra environment (merged over the injected NixOS PATH) |
| `run_in_background` | When `true`, registers a dsh-jobs background job and returns a job id immediately (read with `job_output`, stop with `job_kill`; no client-side timeout — `sudo: true` jobs carry the daemon's per-request cap). Use for long commands such as `nixos-rebuild` so tool results aren't lost to execution time. Local jobs stream incremental output; `sudo: true` jobs run over daemon protocol v3, where `job_kill` cancels via an explicit in-band cancel line. **Note**: a rebuild restarts the dsh service during activation (plugin paths are baked into the service unit), which clears in-process job records — after one, verify completion via `nixos_cli op=generations`; the command itself keeps running to completion in the daemon (a disconnect is never a cancel) |
| `sudo` / `justification` | Enabled when the sudo daemon socket is detected: `sudo: true` routes the request to the external root executor; `justification` is required and echoed with the result |

Behavior: prefers the PATH-resolvable `bash`, falls back to a Nix store shell path (fixing the stock tool's `spawn bash ENOENT`); injects a full NixOS PATH into every child; output truncation with spill files.

### nixos_cli — read-only NixOS diagnostics

| op | Description |
|----|-------------|
| `capabilities` | Probes nixos / nix-command / resolved shell / sudo daemon, returns the recommended rebuild command and the traditional→modern command map |
| `system-status` | `systemctl is-system-running` + failed units list |
| `generations` | System profile generations, newest first; `limit` default 20, max 200; returns the current generation and the total count |
| `journal` | Journal tail for one unit (`unit` required, accepts `*`/`%` globs, trailing `@` auto-appends `*` for all template instances; `lines` default 50, max 500) |
| `audit-store-paths` | Scans `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` for absolute `/nix/store/` references (stale after gc), checks the git credential helper form and emits the fix rule |

Mutating maintenance (`nix store gc`, `nix store optimise`, rebuild) goes through `nixos_shell` with `sudo: true` — escalation always carries an explicit justification.

## Architecture

```
nixos-shell plugin
├─ nixos_shell ── local: ctx.subprocess (PATH injection + spill/timeout)
│                └─ sudo: Unix socket → nixkits-sudo@.service (root, systemd socket-activated)
└─ nixos_cli ──── read-only local execution (systemctl / nix-env / journalctl / config-file scans)
```

The sudo daemon is a systemd socket-activated root executor (`nixkits-sudo-exec.js`, shipped with the plugin): one request per connection, JSON protocol (v3: the client writes one request line and keeps the connection open; the daemon executes on the first line and writes the response when done; any input line after the request means explicit cancel — SIGTERM to the child's whole process group, then SIGKILL after a grace period, since killing only the shell wrapper would leave orphaned grandchildren holding the pipe write-ends and hang the daemon — the in-band mechanism behind `job_kill`). **A disconnect is not a cancel**: a rebuild's activation stage restarts the dsh service, dropping the connection — treating that as cancel would kill the switch mid-activation and leave a partially activated system, so on peer loss the child keeps running detached to completion (daemon-side cap 6 hours, used automatically for rebuild commands). Access control at the socket file (owned by the dsh service user, `0600`). PATH merge order: inherited env first, explicit NixOS profile PATH second (template-unit systemd default PATH contains only base store paths).

### Rebuild / dsh-restart auto-detach

`nixos_shell` recognises `nixos-rebuild` / `nixos apply` / `systemctl restart dsh` commands (with `sudo: true`) and wraps them in a `systemd-run --collect` transient unit (own cgroup): the call returns the unit name immediately (`detachedUnit` in the result). Reason: run through the daemon, the dsh restart or socket stop these commands trigger would kill the calling chain itself (the @ instance and its children share one cgroup, or the harness process hosts this very call), dying mid-activation, leaving the socket down, and losing the call result. Detached execution lets the process run to completion; follow progress via `nixos_cli op=journal unit=nixkits-rebuild-<id>` and verify via `nixos_cli op=generations`.

Detached calls never claim the build outcome: they return `detached: true` + `detachedUnit` + `note` with `exitCode` `null` (systemd-run only hands off — a successful handoff is not a successful build); the real result must always be verified via journal/generations.

The module pairs this with stable mount points (see dsh.md): plugin package updates no longer change the dsh/sudo unit content, so an ordinary rebuild restarts nothing; plugin updates take effect via an explicit `systemctl restart dsh` (equally auto-detached), while the sudo executor spawns per connection and new connections use the new script automatically.

The sudo socket is validated at CALL time, not apply time: the socket disappears briefly during a rebuild's activation, so a session booted in that window does not permanently lose the `sudo` parameter — it works again as soon as the socket is back.

## Usage

Recommended: declarative install via the `nixkits.dsh` module (node_modules injection + generated composition row):

```nix
{
  nixkits.dsh = {
    sudo.enable = true;                 # deploys the sudo daemon and injects NIXKITS_SUDO_SOCKET
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
  };
}
```

Tool calls:

```
nixos_shell(command = "nix flake check", tools = ["git" "jq"])

# Mutating maintenance: run as root through the sudo daemon
nixos_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")

nixos_cli(op = "capabilities")
nixos_cli(op = "journal", unit = "dsh", lines = 30)
nixos_cli(op = "audit-store-paths")
```

## Agent preset

The package ships the "NixOS模式" preset (`presets/nixos-mode/`, id `nixos`): based on the creation-mode preset, it verifies at session initialization that the host is NixOS — on a non-NixOS host it registers a tool guard denying all execution plus a refusal prompt section; on NixOS it installs the development-guidance prompt section and mounts this plugin's two tools (`nixos_shell` / `nixos_cli`). The module seeds it (once) into `$DSH_HOME/.agent-presets/nixos` via `nixkits.dsh.presets.nixosMode = true` (later user edits are respected):

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
  };
}
```

The gate is the package subpath `@kihara777/dsh-nixos-shell/nixos-gate`, mounted only in the preset composition; global sessions are unaffected.

### Maintenance-mode preset

The package also ships the "维护模式" preset (`presets/maintenance-mode/`, id `maintenance`): based on NixOS模式, it additionally mounts the `maintenance-skills` entry — at initialization it registers runtime skills `write-project-docs`, `write-maintenance-log`, `nixkits-check-updates`, and every `translate-*` language extension (auto-discovered at apply time) from the repo's `skills/` tree embedded at build time (single source of truth, so a fresh session always gets the latest content), and injects the repository-maintenance workflow prompt section (commit batching, post-push maintenance log, doc sync, generalization). The module seeds it once via `nixkits.dsh.presets.maintenanceMode = true` into `$DSH_HOME/.agent-presets/maintenance`.

**Derivation**: the maintenance preset's composition equals the NixOS-mode composition with a fixed `maintenance-skills` block appended, and the two presets' `skills/` trees must match file for file — enforced by `develop/check-preset-derivation.py` under `nix flake check` (any change to NixOS mode must be mirrored to maintenance mode; see the "预设" section of the repo's AGENTS.md).
