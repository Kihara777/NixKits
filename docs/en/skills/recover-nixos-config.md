# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> Recovers accidentally deleted `/etc/nixos` files from the Nix store.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/recover-nixos-config/SKILL.md` |

## Features

- Locates the flake source snapshot from the most recent successful build in the Nix store
- Searches `*-source` directories by hostname
- Identifies the correct source matching the latest generation
- Restores specified files (flake.nix, flake.lock, individual modules)
- Validates the restored config with `nix flake check`

## Usage

Activated when the user reports accidentally deleting files under `/etc/nixos`.
