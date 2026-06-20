# translate-katalish (Skill)

[中文](../../zh/skills/translate-katalish.md) | [English](../../en/skills/translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/translate-katalish.md)

> Extra natural-ﾗﾝｹﾞｰｼﾞ ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ document-writing skill.  Adds ｻﾞ ｶﾀﾘｯｼｭ (Katakana English) ﾗﾝｹﾞｰｼﾞ.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (ﾗﾝｹﾞｰｼﾞ backend) |
| Path | `skills/translate-katalish/SKILL.md` |
| Called ﾊﾞｲ | write-project-docs (primary), nixkits-check-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- New ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ — mechanical word-level English→halfwidth-katakana substitution
- Built-in dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback ﾌｫｱ words ﾉｯﾄ in ｻﾞ dictionary
- Markdown syntax ｱﾝﾄﾞ code blocks preserved
- File naming convention: `docs/katalish/<name>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked ﾊﾞｲ write-project-docs ｳｪﾝ producing ｶﾀﾘｯｼｭ documents; ｷｬﾝ ｵﾙｿ be called directly:

- "Generate ｱ katakana-english ﾊﾞｰｼﾞｮﾝ ｵﾌﾞ ｻﾞ document"
- "Add ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ variant"
- "Translate to katakana english"

## Example

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
