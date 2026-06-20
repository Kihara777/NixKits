# nixkits-skills (ｽｷﾙ)

[中文](../../zh/skills/nixkits-skills.md) | [English](nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md)

> Installs ｵｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ NixKits ｽｷﾙｽﾞ into ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ directories (opencode, codewhale, claude, openclaw, agents).

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/nixkits-skills/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Auto-discovers ｿｰｽ ﾃﾞｨﾚｸﾄﾘ ｱﾝﾄﾞ git remote ﾕｰｱｰﾙｴﾙ
- Detects installed ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ directories
- Compares local ｽｷﾙｽﾞ against NixKits ｿｰｽ ﾌｫｱ differences
- Supports local ｲﾝｽﾄｰﾙ (ﾌﾛﾑ ｿｰｽ) ｱﾝﾄﾞ online ｲﾝｽﾄｰﾙ (ﾌﾛﾑ GitHub ｸﾛｰﾝ)
- Shows ﾃﾞｨﾌ ﾋﾞﾌｫｱ applying ｱﾝﾄﾞ asks ﾌｫｱ ﾕｰｻﾞｰ confirmation
- Verifies ｺﾋﾟｰ consistency ｱﾌﾀｰ ｲﾝｽﾄｰﾙ

## Supported Agents

| ｴｰｼﾞｪﾝﾄ | ﾃﾞｨﾚｸﾄﾘ |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude ｺｰﾄﾞ | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ｲﾝｽﾄｰﾙ ｽｷﾙｽﾞ" ｵｱ "ｱｯﾌﾟﾃﾞｰﾄ NixKits ｽｷﾙｽﾞ".