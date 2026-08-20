# dsh-nix-shell

[中文](../zh/dsh-nix-shell.md) | English | [日本語](../ja/dsh-nix-shell.md)  | [偽中国語](../pcn/dsh-nix-shell.md)

NixOS-aware shell tool plugin for the DeepSeek Harness (DSH). On NixOS the dsh process PATH often lacks bash (`/bin/bash` does not exist), so the stock bash tool fails every call with `spawn bash ENOENT`. This plugin registers the model tool `nix_shell`: it prefers the PATH-resolvable bash (degrading to a plain shell tool on healthy hosts), falls back to a Nix store shell path otherwise, and injects an explicit NixOS PATH into every child process.

## Basic Info

| Item | Value |
|------|-------|
| Type | DSH host plugin (npm package) |
| npm name | `@kihara777/dsh-nix-shell` |
| Version | `0.2.0` |
| License | MIT |
| Tool name | `nix_shell` |

## Architecture

```
Model ⇐ tool registration (ctx.tools) ⇐ plugin ⇐ ctx.subprocess ⇐ bash -c <command>
                                       ⇑ ctx.timer (deadline)
```

- Host-only plugin: consumes capability seams (`subprocess`/`timer`/`tools`), provides no services — it may sit loose in a composition like `tool-bash`
- Peers (`cordis`/`dsh-subprocess`/`dsh-timer`) come from the host dsh tree, matching the ecosystem convention
- **No sandbox execution policy is applied** — it is a stopgap for hosts where the stock sandboxing bash tool cannot start; prefer the stock tool once the module PATH fix (see [dsh](dsh.md)) is deployed

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `toolName` | `nix_shell` | Registered tool name |
| `shellPath` | `/run/current-system/sw/bin/bash` | Fallback shell when PATH resolution fails |
| `pathEnv` | NixOS layout | PATH injected into children (supports `$USER`) |
| `defaultTimeoutMs` | `300000` | Default timeout |
| `maxTimeoutMs` | `3600000` | Timeout cap |
| `stdoutMaxBytes` / `stdoutSpillMaxBytes` | 2 MiB / 16 MiB | In-memory and full-stream spill caps |
| `graceMs` | `5000` | Termination grace period |
| `sudoSocketPath` | `""` (disabled) | External sudo daemon socket path; also read from `NIXKITS_SUDO_SOCKET` |

## Sudo daemon integration

Inside the dsh sandbox `sudo` loses its setuid bit and cannot elevate. At **apply time** the plugin probes the external sudo daemon socket (composition config `sudoSocketPath`, falling back to the `NIXKITS_SUDO_SOCKET` environment variable); when present it advertises the `sudo`/`justification` parameters, and `sudo: true` requests are not executed locally but routed whole (command/cwd/env/timeout) over the Unix socket to the daemon, which runs them as root:

```
nix_shell(sudo=true)
  └─ Unix socket ──▶ systemd socket activation (nixkits-sudo@.service, root)
                       └─ nixkits-sudo-exec.js: one request per connection, JSON request/response
```

- **Access-control boundary**: the socket file is owned by the dsh service user with mode `0600` (`SocketUser`/`SocketMode`) — only that user can connect, which equals passwordless root execution for that user
- **Audit**: `justification` is mandatory and echoed with the result; service stderr goes to the journal
- One-line module enablement: `nixkits.dsh.sudo.enable = true` (creates the socket, the per-connection root service, and injects `NIXKITS_SUDO_SOCKET`)
- Without the daemon the `sudo` parameters are not advertised; a vanished socket yields a clear error at call time

## Usage

Declarative install via `nixkits.dsh.plugins.packages` (node_modules injection + generated composition row):

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nix-shell;
    id = "tool-nix-shell";
    name = "@kihara777/dsh-nix-shell";
  }];
}
```

Manual composition row (when the npm package is resolvable from dsh):

```yaml
- insert:
  - id: tool-nix-shell
    name: '@kihara777/dsh-nix-shell'
```

> **Note**: new entries must be wrapped in an `- insert:` op — a bare `- id:` row only patches an existing entry, and dsh reports `patch: entry … not found` and drops the row; the package itself must be resolvable from the profile (`$DSH_HOME/node_modules` or the dsh install tree's node_modules).

Tool call:

```
nix_shell(command = "nix flake check", workdir = "/path/to/flake")

# Run as root through the external sudo daemon (deploy the daemon first, see "Sudo daemon integration")
nix_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")
```
