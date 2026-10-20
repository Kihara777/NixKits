# 逆向模式 (Agent preset)

[中文](../../zh/modes/rea.md) | English | [日本語](../../ja/modes/rea.md)  | [偽中国語](../../pcn/modes/rea.md)

> A reverse-engineering agent built on 维护模式 (maintenance mode): on top of **everything** maintenance mode provides, it mounts REA (Reverse Engineer Anything) as an MCP server in this session — tools named `mcp__rea__*`, registered in full.

## Info

| Item | Value |
|------|-------|
| Mode id | `rea` |
| Distribution | `presets/rea-mode/preset.patch.yml` inside the dsh-nixos-shell package, as one `@deepseek-ai/dsh-agent-preset` patch row |
| Enable with | `nixkits.dsh.presets.reaMode = true` |
| Derives from | [维护模式](maintenance.md) (a fixed row block appended at the end of the composition) |
| Package | `nixkits.dsh.presets.reaPackage` (default `pkgs.rea`) |
| Docs | [rea.md](../rea.md) (the package itself), [dsh-nixos-shell.md](../dsh-nixos-shell.md) (the package that distributes this mode) |

## Behavior

One `@deepseek-ai/dsh-mcp-client` row is appended on top of everything maintenance mode provides:

| Field | Value |
|-------|-------|
| `serverName` | `rea` |
| `transport` | `stdio` |
| `command` | `$REA_BIN_PATH` (exported by the module as `pkgs.rea`'s `bin/rea`) |
| `args` | `['mcp']` |
| `failOnStartupError` | `false` |

That gives three things:

- **The full tool set**: every REA MCP tool is registered as `mcp__rea__*` (about a hundred). `dsh-mcp-client` has **no** allowlist or filter option (checked against its README and config field table), so the only way to take a subset is not to mount this row — this mode is for "I want all of it", and a long tool list is its price, not a defect.
- **Everything maintenance mode does keeps working**: host validation, `nixos_shell` / `nixos_cli`, the documentation and maintenance-log skills, the four-language convention. When analysis results have to go back into a repository, the workflow is already there.
- **A dead REA does not break the preset**: `failOnStartupError: false`. If REA fails, the rest of maintenance mode still works; what is missing is the `mcp__rea__*` group (and the log records the connection failure).

## Prerequisites

`pkgs.rea` comes from the NixKits overlay (`nixpkgs.overlays = [ inputs.nixkits.overlays.default ]`). Without the overlay, pass `presets.reaPackage` explicitly — otherwise evaluation fails with "attribute 'rea' missing", which is a **loud** failure, not a silent skip.

With `presets.reaMode = true` the module exports `REA_BIN_PATH` into the dsh service, so the preset body contains **no store path at all** (the body must stay byte-derivable and readable on a machine without Nix).

## Known limits

Same set as the [rea package docs](../rea.md); not repeated here. The three most easily misread:

| Item | Reality |
|------|---------|
| `rea doctor` host check | On NixOS it reports `unsupported_host` (upstream recognizes distributions through the apt/dnf/pacman family). **Static analysis works as measured** — that line is a verdict, not a runtime prerequisite |
| frida dynamic instrumentation | Unavailable in this package (offline build + `--ignore-scripts`) |
| Hopper / Ghidra / IDA, JADX | Bring your own; the JDK and `ps` ship with `pkgs.rea` |

## Enable

```nix
{
  nixkits.dsh = {
    # the preset's `@kihara777/dsh-nixos-shell/maintenance-skills` rows only resolve with this injection
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.maintenanceMode = true;   # 逆向模式 derives from it
    presets.reaMode = true;
  };
}
```

## Derivation

The reverse-engineering mode's composition file = the `plugins:` body of 维护模式 + a **fixed `mcp-rea` row block appended at the end** (comments included); nothing else may differ.

```yaml
- id: mcp-rea
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: rea
    transport: stdio
    command: !!js "(process.env.REA_BIN_PATH || 'rea')"
    args: ['mcp']
    failOnStartupError: false
```

The chain has **three segments**: NixOS模式 → 维护模式 → 逆向模式. `develop/check-preset-derivation.py` checks each segment byte-for-byte and runs in `nix flake check` (every push): change NixOS模式 without updating maintenance mode and segment one fails; change maintenance mode without updating this mode and segment two fails. Deliberately changing the appended block means updating the script's `PATCH_REA_DELTA` constant. See the `AGENTS.md` "预设" section.

## How to confirm it is really mounted

Look for `mcp__rea__*` tools in a session, or check the `fiberPhase` of the `preset-rea` row in settings. **"The config file says so" is not "it mounted"** — a declaration whose activation fails stays on the roster with its diagnostic instead of disappearing silently.
