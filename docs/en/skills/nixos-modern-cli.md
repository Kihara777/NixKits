# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md)

> Helps AI models correctly understand NixOS vs traditional Linux, using modern CLI for system maintenance.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixos-modern-cli/SKILL.md` |

## Problem Solved

Small models often mistake NixOS for a traditional Linux distro, leading to:
- Attempting `apt`/`yum` package installs
- Unable to locate common command paths
- Not knowing how to apply config changes

This skill provides a complete NixOS operations reference.

## Core Content

- Key differences of NixOS declarative/immutable system
- Modern CLI priority (`nixos`/`nix` > `nixos-rebuild`/`nix-env`)
- Shell environment and ad-hoc tool installation
- System update and maintenance workflows
- Common pitfalls and solutions
