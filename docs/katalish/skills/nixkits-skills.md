# nixkits-ｽｷﾙｽﾞ (ｽｷﾙ)

[中文](../../zh/skills/nixkits-skills.md) | [English](nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) | [偽中国語](../../pcn/skills/nixkits-skills.md)

> Installs or updates NixKits skills into coding agent directories (opencode, codewhale, claude, openclaw, agents).

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixkits-skills/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰｽﾞ ｿｰｽ directory ｱﾝﾄﾞ git remote ﾕｰｱｰﾙｴﾙ
- Detects ｲﾝｽﾄｰﾙﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ directories
- Compares local ｽｷﾙｽﾞ against NixKits ｿｰｽ ﾌｫｱ differences
- ｻﾎﾟｰﾄｽﾞ local ｲﾝｽﾄｰﾙ (ﾌﾛﾑ ｿｰｽ) ｱﾝﾄﾞ online ｲﾝｽﾄｰﾙ (ﾌﾛﾑ GitHub clone)
- Shows diff before applying ｱﾝﾄﾞ asks ﾌｫｱ ﾕｰｻﾞｰ confirmation
- Verifies copy consistency after ｲﾝｽﾄｰﾙ

## ｻﾎﾟｰﾄﾄﾞ ｴｰｼﾞｪﾝﾄｽﾞ

| ｴｰｼﾞｪﾝﾄ | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude ｺｰﾄﾞ | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## ﾕｰｾｰｼﾞ

Activated when ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ｲﾝｽﾄｰﾙ ｽｷﾙｽﾞ" ｵｱ "ｱｯﾌﾟﾃﾞｰﾄ NixKits ｽｷﾙｽﾞ".