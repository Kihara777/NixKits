# 维护模式 (Agent preset)

[中文](../../zh/modes/maintenance.md) | English | [日本語](../../ja/modes/maintenance.md)  | [偽中国語](../../pcn/modes/maintenance.md)

> A repository-maintenance-specific agent based on NixOS模式: it injects the documentation-writing and maintenance-log skills plus the upstream update-check skill, and loads the NixKits repository-maintenance workflow prompts.

## Basic Info

| Item | Value |
|------|-------|
| Mode id | `maintenance` |
| Distribution | `presets/maintenance-mode/` inside the dsh-nixos-shell package, seed-once copied to `$DSH_HOME/.agent-presets/maintenance` |
| Enable option | `nixkits.dsh.presets.maintenanceMode = true` |
| Derived from | [NixOS模式](nixos.md) (a fixed row block appended to the end of the composition) |
| Doc | [dsh-nixos-shell.md](../dsh-nixos-shell.md) (the package shipping this mode) |

## Behavior

On top of everything NixOS模式 provides:

- **Runtime skills**: the `maintenance-skills` entry registers `write-project-docs`, `write-maintenance-log`, `nix-flake-update-check`, and `nixkits-check-updates` at apply time from the repo `skills/` tree **embedded at build time**, and auto-discovers every `translate-*` language extension — the repo `skills/` is the single source of truth, so a fresh session is always current.
- **Maintenance workflow prompts**: batched commits → maintenance-log entry after push (all languages synced) → doc sync → generalization into skills.
- Everything else (system validation, `nixos_shell` / `nixos_cli`, development prompts) matches NixOS模式.

## Derivation

The maintenance mode composition file = the NixOS模式 composition with a fixed `maintenance-skills` row block **appended at the end** (comments included), and the two presets' `skills/` trees must match file for file — no other difference is allowed.

```yaml
- id: maintenance-skills
  name: '@kihara777/dsh-nixos-shell/maintenance-skills'
```

`develop/check-preset-derivation.py` validates that derivation and is wired into `nix flake check` (run by CI on every push); a drift fails the check, so it must be fixed before committing. When the appended block itself is changed deliberately, update the `MAINTENANCE_DELTA` constant in the script too. See the "预设" section of the repo's `AGENTS.md`.

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
    presets.maintenanceMode = true;
  };
}
```

## Notes

- Like NixOS模式 it is **seed-once**: `$DSH_HOME/.agent-presets/maintenance` is not overwritten when it already exists — edit that directory directly (the module makes it writable).
- After changing NixOS模式, the same change must be mirrored to maintenance mode, otherwise `nix flake check` fails on derivation drift.
