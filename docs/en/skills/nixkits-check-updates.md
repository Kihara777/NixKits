# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-check-updates.md) | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> Checks all NixKits packages and patches for upstream updates, applies version bumps and doc sync.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-check-updates/SKILL.md` |

## Features

- Auto-discovers all external packages from `flake.nix` and checks latest GitHub Releases
- Updates build configs (version, source hash, npmDepsHash)
- Syncs version numbers across all 3 language docs
- Auto-invokes `write-maintenance-log` skill to write maintenance records after updates
- Reports locally installed versions
- Identifies hardcoded versions inside patch files and provides check guidance

## Hash Gotchas

- SRI hash must use standard base64 (`+` `/` `=`), not URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed from the GitHub archive tarball — must come from `nix build` hash mismatch error
- Use `lib.fakeHash` for empty `npmDepsHash`, not the empty string `""`
- npm packages need two `nix build` passes: first for source hash, second for npmDepsHash

## Scope

Reads `flake.nix` → `packages`, excluding:
- Self-hosted packages (source in repo)
- Dynamic version tracking (fetches latest at build time)
- nixpkgs-following (patch overlays)
- Patch-embedded versions (manual check, e.g. `comfyui-strix-halo`)

All remaining external packages are checked automatically.

## Usage

Activated when the user asks to "check for updates" or "update package versions".
