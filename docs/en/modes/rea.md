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

One **bundled plugin** — `@kihara777/dsh-nixos-shell/rea-mcp` — is appended on top of everything maintenance mode provides:

| Item | Value |
|------|-------|
| When it connects | `agent/session-start` — **one connection per session that selected this preset**, closed when the session ends |
| Transport | stdio JSON-RPC, `args: ['mcp']` |
| Executable | `$REA_BIN_PATH` (the module exports it as `pkgs.rea`'s `bin/rea`) |
| Tool naming | `mcp__rea__<raw name>`, registered on **that agent's scope** |

Three consequences:

- **The full tool set**: REA's 207 tools (measured through `tools/list` at 6.7.0) are all registered as `mcp__rea__*`, with `inputSchema` handed to the registry **unchanged** — no "JSON Schema → dsh shorthand spec" converter, because such a converter silently rejects legitimate calls when it is wrong. A long tool list is the price; this mode is for "I want all of it".
- **Only sessions of this mode get them**: that is the single reason for writing `rea-mcp` instead of mounting a `@deepseek-ai/dsh-mcp-client` row (see below).
- **Everything maintenance mode does keeps working**: host validation, `nixos_shell` / `nixos_cli`, the documentation and maintenance-log skills, the four-language convention.

### Why not `@deepseek-ai/dsh-mcp-client`

That was the first version. What the real deployment measured on 2026-10-20:

- presets use **eager activation** — `rea mcp` was spawned 4 seconds after dsh started, **before any session existed**;
- the tools landed on the root scope, so **a lampkeeper session** also carried 207 `mcp__rea__*` tools (31 + 207 = **238** tools in its request header).

"Mode" means only the session that selected it gets those tools, so this layer is written here: the connection and the registrations are bound to `agent.ctx` and torn down with the session.

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

## Verification status

| Layer | Result |
|---|---|
| The declaration is accepted by the platform | ✅ `AgentPresetRegistry.mount()` reports OK |
| The REA MCP server really starts | ✅ After deployment dsh spawned it **4 seconds** after start (measured pid, alive 5h+, 8 pipes to dsh) |
| The 207 tools really reach the model request | ✅ The session record's `request/header` carries **207** `mcp__rea__*` entries (238 tools total) |
| **Visible only to this mode's sessions** | ⏳ Pending after the `rea-mcp` change: a non-rea session should be back to 31, a rea session should be 238 |

The first two rows and the third are different claims: a live process only proves the connection is alive; whether the tools reach the request has to be counted in the request header.
And "reached one session" versus "reached only this mode's sessions" are yet another two — the first version failed exactly there.

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
