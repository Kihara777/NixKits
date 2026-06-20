# nixkits-ｽｷﾙs (Skill)

[中文](../../zh/ｽｷﾙs/nixkits-ｽｷﾙs.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixkits-ｽｷﾙs.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixkits-ｽｷﾙs.md) | [偽中国語](../../pcn/ｽｷﾙs/nixkits-ｽｷﾙs.md)

> ｲﾝｽﾄｰﾙs or updates NixKits ｽｷﾙs into ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ directories (opencode, codewhale, claude, openclaw, ｴｰｼﾞｪﾝﾄs).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/nixkits-ｽｷﾙs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers source directory and git remote URL
- Detects ｲﾝｽﾄｰﾙed ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ directories
- Compares local ｽｷﾙs against NixKits source for differences
- Supports local ｲﾝｽﾄｰﾙ (from source) and online ｲﾝｽﾄｰﾙ (from GitHub clone)
- Shows diff before applying and asks for user confirmation
- Verifies copy consistency after ｲﾝｽﾄｰﾙ

## Supported Agents

| Agent | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/ｽｷﾙs/` |
| CodeWhale | `~/.codewhale/ｽｷﾙs/` |
| Claude Code | `~/.claude/ｽｷﾙs/` |
| OpenClaw | `~/.openclaw/ｽｷﾙs/` |
| Generic | `~/.ｴｰｼﾞｪﾝﾄs/ｽｷﾙs/` |

## ﾕｰｾｰｼﾞ

Activated when the user asks to "ｲﾝｽﾄｰﾙ ｽｷﾙs" or "update NixKits ｽｷﾙs".
