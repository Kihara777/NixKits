# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/nixkits-skills.md)

> Installs or updates NixKits skills into ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ directories (opencode, codewhale, codex, openclaw, agents).

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-skills/SKILL.md` |

## Features

- Auto-discovers source directory ｱﾝﾄﾞ git remote URL
- Detects installed ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ skill directories
- Compares local skills against NixKits source for differences
- Supports local install (from source) ｱﾝﾄﾞ online install (from GitHub clone)
- Shows diff before applying ｱﾝﾄﾞ asks for user confirmation
- Verifies copy consistency after install

## Supported Agents

| Agent | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Codex | `~/.codex/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## Usage

Activated when ｻﾞ user asks to "install skills" or "update NixKits skills".

## Risk Advisory

**Claude Code** removed 2026-07:

> Claude Code, as a company, has KYC rights ｱﾝﾄﾞ rights to choose service regions — but embedding nationality-inference business logic via user data mining, regardless of purpose, has severely crossed ｻﾞ security model boundary ｱﾝﾄﾞ broken fundamental user trust.
>
> This repository strongly advises reassessing necessity ｱﾝﾄﾞ considering workflow migration. This repository respects user diversity ｱﾝﾄﾞ individual choice, but has an obligation to inform of this risk. Should any anomaly or loss occur to your Anthropic account from use of this content, you acknowledge this event is unrelated to this repository.