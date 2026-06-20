# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md)

> Installs or updates NixKits skills into coding agent directories (opencode, codewhale, claude, openclaw, agents).

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-skills/SKILL.md` |

## Features

- Auto-discovers source directory and git remote URL
- Detects installed coding agent skill directories
- Compares local skills against NixKits source for differences
- Supports local install (from source) and online install (from GitHub clone)
- Shows diff before applying and asks for user confirmation
- Verifies copy consistency after install

## Supported Agents

| Agent | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## Usage

Activated when the user asks to "install skills" or "update NixKits skills".
