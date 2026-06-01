# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md)

> Coding Agent skill: recover accidentally deleted `/etc/nixos` config files from the Nix store.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/recover-nixos-config/SKILL.md` |

## Trigger

Automatically activated when the user has deleted files under `/etc/nixos` (flake.nix, flake.lock, etc.) and the system was previously built successfully.

## How It Works

Every successful `nixos-rebuild` preserves a snapshot of the `/etc/nixos` flake source in the Nix store (`*-source` directory). Deleted files can be recovered even without local backups.

## Install

Copy the `skills/` directory to any of:

```
~/.agents/skills/
~/.codewhale/skills/
~/.opencode/skills/
```

## Usage

Automatically invoked by the AI assistant when `/etc/nixos` file loss is detected. No manual call needed. Recovery steps:

1. Search Nix store for source snapshots matching the hostname
2. Identify the source from the latest generation
3. Verify file contents
4. Copy lost files back to `/etc/nixos`
5. Run `nix flake check` to validate
