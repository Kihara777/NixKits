# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` files from ｻﾞ Nix store.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/recover-nixos-config/SKILL.md` |

## Features

- Locates ｻﾞ flake source snapshot from ｻﾞ most recent successful build in ｻﾞ Nix store
- Searches `*-source` directories by hostname
- Identifies ｻﾞ correct source matching ｻﾞ latest generation
- Restores specified files (flake.nix, flake.lock, individual modules)
- Validates ｻﾞ restored config ｳｨｽﾞ `nix flake check`

## Usage

Activated when ｻﾞ user reports accidentally deleting files under `/etc/nixos`.