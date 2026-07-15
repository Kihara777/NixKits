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

## Risk Advisory

**Claude Code** was removed in 2026-07 ﾌｫｱ ｻﾞ following reason:

> While Claude Code, as a company, has the right to KYC and to choose which users and regions to serve, the act of embedding business logic that infers user nationality from data mining—regardless of purpose or justification—has severely crossed the security model boundary and broken fundamental user trust.
>
> For this reason, this repository strongly advises any user of that software to reassess its necessity and consider migrating their workflow where possible. This repository fully respects the diversity of user needs and individual choice, but has an obligation to inform users of this risk. Should any anomaly or loss occur to your Anthropic account as a result of using this repository's content, you acknowledge that this event is unrelated to this repository.
