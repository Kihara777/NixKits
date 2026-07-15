# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/nixkits-skills.md)

> Installs ｵﾗ updates NixKits skills ｲﾝﾄｩ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ directories (opencode, codewhale, codex, openclaw, agents).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-skills/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers source directory ｱﾝﾄﾞ git remote URL
- Detects installed ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ skill directories
- Compares local skills against NixKits source ﾌｫｱ differences
- Supports local ｲﾝｽﾄｰﾙ (ﾌﾛﾑ source) ｱﾝﾄﾞ online ｲﾝｽﾄｰﾙ (ﾌﾛﾑ ｷﾞｯﾄﾊﾌﾞ clone)
- Shows diff before applying ｱﾝﾄﾞ asks ﾌｫｱ user confirmation
- Verifies copy consistency after ｲﾝｽﾄｰﾙ

## Supported Agents

| Agent | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Codex | `~/.codex/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ user asks to "ｲﾝｽﾄｰﾙ skills" ｵﾗ "update NixKits skills".

## Known Removals

**Claude Code** removed 2026-07:

> Claude Code embedded nationality-inference business logic via user data mining, crossing security model boundary and breaking fundamental user trust. This repository strongly advises reassessment and workflow migration where possible. Repository assumes no liability for Anthropic account anomalies or losses from use of this content.
