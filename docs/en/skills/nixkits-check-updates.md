# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)

> Check all external NixKits packages for upstream release updates and apply them automatically.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-check-updates/SKILL.md` |

## Features

- Confirm user is in a local NixKits repo
- Check 4 external packages for latest GitHub Release
- Auto-update version, hash, npmDepsHash
- Sync documentation (3 languages)
- Report locally installed versions

## Scope

Dynamically reads packages from `flake.nix`, excluding:
- Self-hosted (source in local repo)
- Dynamic version (fetches latest at build time)
- Nixpkgs-tracked patches

All remaining external packages are checked automatically.
