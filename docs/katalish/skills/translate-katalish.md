# translate-katalish (Skill)

[中文](../../zh/ｽｷﾙs/translate-katalish.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/translate-katalish.md) | [偽中国語](../../pcn/ｽｷﾙs/translate-katalish.md)

> Extra natural-language ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ document-writing ｽｷﾙ.  Adds ｻﾞ ｶﾀﾘｯｼｭ (Katakana English) language.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `ｽｷﾙs/translate-katalish/SKILL.md` |
| Called ﾊﾞｲ | write-project-docs (primary), nixkits-ﾁｪｯｸ-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- New ｶﾀﾘｯｼｭ language — mechanical word-level English→halfwidth-katakana substitution
- Built-ｲﾝ dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback ﾌｫｱ words ﾉｯﾄ ｲﾝ ｻﾞ dictionary
- Markdown syntax ｱﾝﾄﾞ code blocks preserved
- File naming convention: `docs/katalish/<ﾈｰﾑ>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked ﾊﾞｲ write-project-docs ｳｪﾝ producing ｶﾀﾘｯｼｭ documents; ｷｬﾝ also be called directly:

- "Generate a katakana-english ﾊﾞｰｼﾞｮﾝ of ｻﾞ document"
- "Add ｶﾀﾘｯｼｭ language variant"
- "Translate ﾄｩ katakana english"

## Example

```
NixKits — software, patches, NixOS modules ｱﾝﾄﾞ coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
