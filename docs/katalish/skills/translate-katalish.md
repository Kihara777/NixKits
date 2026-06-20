# translate-katalish (Skill)

[中文](../../zh/ｽｷﾙs/translate-katalish.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/translate-katalish.md) | [偽中国語](../../pcn/ｽｷﾙs/translate-katalish.md)

> Extra natural-language ｻﾎﾟｰﾄ for the document-writing ｽｷﾙ.  Adds the ｶﾀﾘｯｼｭ (Katakana English) language.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `ｽｷﾙs/translate-katalish/SKILL.md` |
| Called by | write-project-docs (primary), nixkits-ﾁｪｯｸ-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- New ｶﾀﾘｯｼｭ language — mechanical word-level English→halfwidth-katakana substitution
- Built-in dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback for words not in the dictionary
- Markdown syntax and code blocks preserved
- File naming convention: `docs/katalish/<name>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked by write-project-docs when producing ｶﾀﾘｯｼｭ documents; can also be called directly:

- "Generate a katakana-english ﾊﾞｰｼﾞｮﾝ of the document"
- "Add ｶﾀﾘｯｼｭ language variant"
- "Translate to katakana english"

## Example

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
