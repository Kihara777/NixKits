# 狐莉模式 (Agent preset)

[中文](../../zh/modes/foxli.md) | English | [日本語](../../ja/modes/foxli.md)  | [偽中国語](../../pcn/modes/foxli.md)

> A "Swiss army knife" preset derived from NixOS模式: **daily maintenance, development and reverse engineering in one**. It is also **the boundary of what is released to the community** — 掌灯模式 derives from it and adds only its private adapter layer.

## Info

| Item | Value |
|------|-------|
| Mode id | `foxli` |
| Distribution | `presets/foxli-mode/preset.patch.yml` inside the dsh-nixos-shell package, as one `@deepseek-ai/dsh-agent-preset` patch row |
| Enable with | `nixkits.dsh.presets.foxliMode = true` |
| Derives from | [NixOS模式](nixos.md) (body + two fixed blocks: **maintenance**, **reverse**) |
| Package | `nixkits.dsh.presets.reaPackage` (default `pkgs.rea`) |
| Docs | [dsh-nixos-shell.md](../dsh-nixos-shell.md), [rea.md](../rea.md) |

## Three-layer derivation

```
NixOS模式 (minimal NixOS adaptation)
  └─ 狐莉模式 (maintenance + development + reverse)   ← this page; the community boundary
       └─ 掌灯模式 (in Kitsunome: this body + a private delta)
```

**Why one layer instead of two**: the old maintenance mode and reverse-engineering mode were each "NixOS + one block". Keeping them apart forced downstream to derive twice and maintain two skill lists — and **nothing was watching the downstream copy** (three skills were found missing on 2026-10-21 because of that).

## Behavior

Two blocks are appended on top of everything NixOS模式 provides.

### Maintenance block

- **Runtime skills**: `maintenance-skills` registers `write-project-docs`, `write-maintenance-log`, `nix-flake-update-check`, `nixkits-check-updates`, `upstream-audit`, `nixkits-package-upstream`, `agent-self-maintenance` from the build-time embedded `skills/` tree, plus every auto-discovered `translate-*` language extension.
- **Two-layer maintenance prompts**: `maintenance-workflow` (generic, order 901) and `maintenance-workflow-repo` (this repository's conventions, order 902). The single criterion: **does this rule still hold in another repository?** Yes → generic layer; no → adapter layer.

### Reverse block

One bundled plugin `@kihara777/dsh-nixos-shell/rea-mcp`:

| Item | Value |
|------|-------|
| When it connects | `agent/session-start` — **one connection per session that selected this preset**, closed with the session |
| Transport | stdio JSON-RPC, `args: ['mcp']` |
| Executable | `$REA_BIN_PATH` (exported by the module as `pkgs.rea`'s `bin/rea`) |
| Tool naming | `mcp__rea__<raw name>`, registered on **that agent's scope** |

All 207 REA tools (measured via `tools/list` at 6.7.0) are registered with `inputSchema` handed over **unchanged** — no "JSON Schema → dsh shorthand spec" converter, because such a converter silently rejects legitimate calls when it is wrong.

**Why not `@deepseek-ai/dsh-mcp-client`**: that was the first version. The 2026-10-20 deployment measured eager activation (the `rea mcp` process spawned 4 seconds after dsh started, before any session existed) and tools landing on the root scope — so **a 掌灯模式 session** carried 207 `mcp__rea__*` tools too (31 + 207 = **238** in its request header). "Mode" means only the session that selected it gets those tools.

## Prerequisites

`pkgs.rea` comes from the NixKits overlay; without it, pass `presets.reaPackage` explicitly — evaluation fails with "attribute 'rea' missing", which is a **loud** failure.

With `presets.foxliMode = true` the module exports `REA_BIN_PATH` into the dsh service, so the preset body contains **no store path at all**.

## Verification status

| Layer | Result |
|---|---|
| The declaration is accepted by the platform | ✅ `AgentPresetRegistry.mount()` reports OK |
| The REA MCP server really starts | ✅ Spawned **4 seconds** after dsh start (measured pid, alive 5h+, 8 pipes to dsh) |
| The 207 tools really reach the model request | ✅ Session record's `request/header` carries **207** `mcp__rea__*` entries (238 tools total) |
| **Visible only to this mode's sessions** | ⏳ Pending after the per-session `rea-mcp` change |

## Enable

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
    presets.foxliMode = true;
  };
}
```

## Derivation

The composition file = the `plugins:` body of NixOS模式 + **two fixed appended blocks** (maintenance, reverse), comments included; nothing else may differ. `develop/check-preset-derivation.py` checks it byte-for-byte in `nix flake check`:

```python
PATCH_FOXLI_DELTA = PATCH_MAINTENANCE_DELTA + PATCH_REA_DELTA
```

**掌灯模式's derivation is not here**: it lives in Kitsunome, reading this body at build time and appending its private delta; that repository's checker owns it.
