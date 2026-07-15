# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | English | [日本語](../../ja/skills/nixos-modern-cli.md)  | [偽中国語](../../pcn/skills/nixos-modern-cli.md)

> Activated on NixOS systems. Ensures modern Nix CLI usage, full shell capability, and correct maintenance procedures.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixos-modern-cli/SKILL.md` |

## Features

- Corrects AI models that mistake NixOS for a traditional Linux distro
- Provides a modern vs traditional CLI command reference table
- Guides running scripts requiring POSIX tools via `nix shell --command`
- Includes a common POSIX tool → nixpkgs package lookup table
- Covers system maintenance, log viewing, and garbage collection
- Lists NixOS-specific gotchas (PATH, nix-env persistence, etc.)
- Diagnoses Nix Store path traps: identifies and fixes stale `/nix/store/` paths in config files (e.g. `gh auth setup-git` credential helper breaking after GC)

## Usage

Auto-activated when the AI detects a NixOS environment, or on explicit request for "modern nix commands".
