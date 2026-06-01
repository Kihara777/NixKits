# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md)

> Installer that deploys NixKits skills to coding agent directories.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-skills/SKILL.md` |

## Features

- **Local install**: copy skills from NixKits source directory
- **Online install**: clone from GitHub then install
- **Update check**: compare installed skills against source, prompt user

## Supported Agents

`~/.opencode/skills/` `~/.codewhale/skills/` `~/.claude/skills/` `~/.openclaw/skills/` `~/.agents/skills/`

## Workflow

1. Detect existing agent directories
2. Check installed NixKits skills for updates
3. Ask user when differences are found
4. Auto-select mode (local/online)
5. Install and verify
