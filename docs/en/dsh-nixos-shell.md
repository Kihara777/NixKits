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
| `tools` | Optional POSIX tool names; the command runs via `nix shell nixpkgs#<pkg>… --command` (python3, grep, sed, awk, git, jq, ripgrep, …) |
| `workdir` / `timeoutMs` / `env` | Working directory / timeout (capped by config) / extra environment (merged over the injected NixOS PATH) |
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

The sudo daemon is a systemd socket-activated root executor (`nixkits-sudo-exec.js`, shipped with the plugin): one request per connection, JSON protocol, access control at the socket file (owned by the dsh service user, `0600`). PATH merge order: inherited env first, explicit NixOS profile PATH second (template-unit systemd default PATH contains only base store paths).

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

The package also ships the "维护模式" preset (`presets/maintenance-mode/`, id `maintenance`): based on NixOS模式, it additionally mounts the `maintenance-skills` entry — at initialization it registers runtime skills `write-project-docs`, `write-maintenance-log`, and every `translate-*` language extension (auto-discovered at apply time) from the repo's `skills/` tree embedded at build time (single source of truth, so a fresh session always gets the latest content), and injects the repository-maintenance workflow prompt section (commit batching, post-push maintenance log, doc sync, generalization). The module seeds it once via `nixkits.dsh.presets.maintenanceMode = true` into `$DSH_HOME/.agent-presets/maintenance`.
