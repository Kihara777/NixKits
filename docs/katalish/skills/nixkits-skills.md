# nixkits-ｽｷﾙs (Skill)

[中文](../../zh/ｽｷﾙs/nixkits-ｽｷﾙs.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/nixkits-ｽｷﾙs.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/nixkits-ｽｷﾙs.md) | [偽中国語](../../pcn/ｽｷﾙs/nixkits-ｽｷﾙs.md)

> ｲﾝｽﾄｰﾙs ｵﾗ updates NixKits ｽｷﾙs into ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ directories (opencode, codewhale, claude, openclaw, ｴｰｼﾞｪﾝﾄs).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/nixkits-ｽｷﾙs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers source directory ｱﾝﾄﾞ git remote URL
- Detects ｲﾝｽﾄｰﾙed ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ directories
- Compares local ｽｷﾙs against NixKits source ﾌｫｱ differences
- Supports local ｲﾝｽﾄｰﾙ (ﾌﾛﾑ source) ｱﾝﾄﾞ online ｲﾝｽﾄｰﾙ (ﾌﾛﾑ ｷﾞｯﾄﾊﾌﾞ clone)
- Shows diff before applying ｱﾝﾄﾞ asks ﾌｫｱ ﾕｰｻﾞｰ confirmation
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

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ｲﾝｽﾄｰﾙ ｽｷﾙs" ｵﾗ "update NixKits ｽｷﾙs".
