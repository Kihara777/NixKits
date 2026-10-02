# NixOS模式 (Agent preset)

[中文](../../zh/modes/nixos.md) | English | [日本語](../../ja/modes/nixos.md)  | [偽中国語](../../pcn/modes/nixos.md)

> A NixOS-specific agent based on creation mode: at session initialization it validates the host system (a non-NixOS host denies all execution) and loads `nixos_shell` / `nixos_cli` plus the NixOS efficient-development prompts.

## Basic Info

| Item | Value |
|------|-------|
| Mode id | `nixos` |
| Distribution | `presets/nixos-mode/preset.patch.yml` inside the dsh-nixos-shell package, spliced into the profile's `cordis.patch.yml` as one `@deepseek-ai/dsh-agent-preset` patch row (dsh 0.2.0; 0.1.x seed-once copied it to `$DSH_HOME/.agent-presets/nixos`) |
| Enable option | `nixkits.dsh.presets.nixosMode = true` |
| Derived from | creation mode (the `cordis` preset shipped with dsh) |
| Doc | [dsh-nixos-shell.md](../dsh-nixos-shell.md) (the package shipping this mode) |

## Behavior

- **Host validation**: `nixos-gate` reads `/etc/NIXOS` and `/etc/os-release` at apply time; on a non-NixOS host it registers a tool guard denying all execution and injects the refusal prompt (telling the user to switch back to another mode), so it mounts safely on a machine without NixOS.
- **Tools**: `nixos_shell` (PATH injection / `nix shell` tool bootstrap / sudo-daemon routing) and `nixos_cli` (read-only diagnostics: capabilities / system-status / generations / journal / audit-store-paths).
- **Prompts**: the NixOS efficient-development guide (declarative immutable system, package management, path pitfalls).
- **Skills** (5): `cordis-plugin-development` and `editing-cordis-compositions`, shipped upstream with `@deepseek-ai/dsh-agent-preset` (the preset mounts upstream's copy directly rather than bundling its own), plus `nixos-modern-cli`, `recover-nixos-config` and `nixos-specialisation-tuning`, registered from the repository `skills/` tree through the build-time subset `skills-nixos/`.
- **Composition**: creation mode's full tool surface + the `persona` row (it sets only `prefix` and **does not** set `complete`, so runtime context is still appended) + the `nixos-gate` and `nixos-shell` rows.

## The persona row (preset identity)

The composition mounts an `@deepseek-ai/dsh-persona` row, giving that session its identity prompt (shadowing the deployment-level default persona):

| Field | Type | Default | Description |
|------|------|--------|------|
| `prefix` | string | — (**required**) | Identity prompt prefix; when missing the plugin fails to load (`$.prefix missing required value`) |
| `suffix` | string | `""` | Suffix appended after the runtime context |
| `complete` | boolean | `false` | When `true` the persona is the complete prompt and no runtime context is appended |
| `includeRuntimeContext` | boolean | `true` | Whether to append runtime context (model, working directory, …) |

> **Upgrade note**: `prefix` is **required** as of dsh 0.1.5-alpha.2 (the field was previously named `text`). If a preset still writes `text`, the persona plugin fails to load and takes down **the whole session creation path** — once `session/create` fails, the settings UI, the llm provider catalog, and session history all become unloadable, surfacing in the frontend as `llm/listProviders failed: Failed to fetch` plus an infinite `commands/list` retry. **That symptom shares a root cause with a "model settings page error"; do not misdiagnose it as a network or reverse-proxy problem**. After upgrading dsh, verify the config schema of every plugin row in your presets.

## Install

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

After a rebuild, pick "NixOS模式" in the session mode selector.

## Notes

- **Nothing is copied as of 0.2.0**: the preset is one `@deepseek-ai/dsh-agent-preset` row in the profile patch layer, with its body taken verbatim from the `preset.patch.yml` in the package (the stable channel takes the pinned rev, alpha follows HEAD). A `$DSH_HOME/.agent-presets/nixos` left by an older release is a historical leftover 0.2.0 never reads, and the module **deliberately does not delete it** (the old contract promised to respect your edits to that copy). To change the preset, change the `preset.patch.yml` in the package.
- The gate entry is the in-package subpath `@kihara777/dsh-nixos-shell/nixos-gate`, mounted only in the preset composition; global sessions are unaffected.
