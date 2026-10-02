# 维护模式 (Agent preset)

[中文](../../zh/modes/maintenance.md) | English | [日本語](../../ja/modes/maintenance.md)  | [偽中国語](../../pcn/modes/maintenance.md)

> A repository-maintenance-specific agent based on NixOS模式: it injects the documentation-writing and maintenance-log skills plus the upstream update-check skill, and loads **two layers** of maintenance-workflow prompts — a generic method plus a repository (NixKits) adapter layer.

## Basic Info

| Item | Value |
|------|-------|
| Mode id | `maintenance` |
| Distribution | `presets/maintenance-mode/preset.patch.yml` inside the dsh-nixos-shell package, as one `@deepseek-ai/dsh-agent-preset` patch row (same path as NixOS模式; 0.1.x seed-once copied it) |
| Enable option | `nixkits.dsh.presets.maintenanceMode = true` |
| Derived from | [NixOS模式](nixos.md) (a fixed row block appended to the end of the composition) |
| Doc | [dsh-nixos-shell.md](../dsh-nixos-shell.md) (the package shipping this mode) |

## Behavior

On top of everything NixOS模式 provides:

- **Runtime skills**: the `maintenance-skills` entry registers `write-project-docs`, `write-maintenance-log`, `nix-flake-update-check`, and `nixkits-check-updates` at apply time from the repo `skills/` tree **embedded at build time**, and auto-discovers every `translate-*` language extension — the repo `skills/` is the single source of truth, so a fresh session is always current.
- **Maintenance workflow prompts, in two layers** (the same split the skills above already use: generic method ← repository adapter layer):

  | Section | Scope | Content |
  |---------|-------|---------|
  | `maintenance-workflow` (order 901) | **Generic** — true of any repository | batch commits by logical category, record after pushing, keep docs in sync with code, generalize fixes into skills, single source for skill content |
  | `maintenance-workflow-repo` (order 902) | **This repository's (NixKits) conventions** | the four languages and their base (`docs/zh/` first), `write-maintenance-log` as the standard, a verifiable entry-count check, single source for the skill tree |

  The only test is: **would this rule still hold in another repository?** If yes it stays in the generic layer; if no it goes to the adapter. The generic layer names no repository-specific thing (NixKits / the four languages / `translate-*` / `MAINTENANCE.md` / `grep -c` / `docs/zh`).

  Component option `repoWorkflow: false` keeps only the generic layer, for a session maintaining a different repository.
- Everything else (system validation, `nixos_shell` / `nixos_cli`, development prompts, and the 5 skills bundled with NixOS模式) matches NixOS模式.

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

- Same path as NixOS模式: **nothing is copied as of 0.2.0** — the preset is one patch row in the profile patch layer (its body taken verbatim from `presets/maintenance-mode/preset.patch.yml`). A `$DSH_HOME/.agent-presets/maintenance` left by an older release is a leftover 0.2.0 never reads, and the module deliberately does not delete it.
- After changing NixOS模式, the same change must be mirrored to maintenance mode, otherwise `nix flake check` fails on derivation drift.
