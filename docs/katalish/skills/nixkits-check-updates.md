# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> Checks upstream updates for all NixKits packages ｱﾝﾄﾞ patches. Auto-upgrades, syncs docs, writes fixes to maintenance log.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-check-updates/SKILL.md` |

## Features

- Auto-discovers all external packages from `flake.nix` ｱﾝﾄﾞ checks latest GitHub Releases
- Updates build configs (version, source hash, npmDepsHash)
- Syncs version numbers across all language docs
- Auto-invokes `write-maintenance-log` skill to write maintenance records after updates
- Reports locally installed versions
- Identifies hardcoded versions inside patch files ｱﾝﾄﾞ provides check guidance

## Hash Gotchas

- SRI hash must use standard base64 (`+` `/` `=`), not URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed from ｻﾞ GitHub archive tarball — must come from `nix build` hash mismatch error
- Use `lib.fakeHash` for empty `npmDepsHash`, not ｻﾞ empty string `""`
- npm packages need two `nix build` passes: first for source hash, second for npmDepsHash

## Scope

Reads `flake.nix` → `packages`, excluding:
- Self-hosted packages (source in repo)
- Dynamic version tracking (fetches latest at build time)
- nixpkgs-following (patch overlays)
- Patch-embedded versions (manual check, e.g. `comfyui-strix-halo`)

All remaining external packages are checked automatically.

## Usage

Activated when ｻﾞ user asks to "check for updates" or "update package versions".