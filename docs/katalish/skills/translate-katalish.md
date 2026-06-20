# translate-ｶﾀﾘｯｼｭ (ｽｷﾙ)

[中文](../../zh/skills/translate-katalish.md) | [English](translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md) | [偽中国語](../../pcn/skills/translate-katalish.md)

> Extra natural-language support for the document-writing skill.  Adds the ｶﾀﾘｯｼｭ (Katakana English) language.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ (ﾗﾝｹﾞｰｼﾞ ﾊﾞｯｸｴﾝﾄﾞ) |
| ﾊﾟｽ | `skills/translate-katalish/SKILL.md` |
| Called ﾊﾞｲ | ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs (primary), nixkits-check-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- ﾆｭｰ ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ — mechanical word-ﾚﾍﾞﾙ ｲﾝｸﾞﾘｯｼｭ→halfwidth-katakana substitution
- Built-ｲﾝ dictionary (~20 common tech-ﾄﾞｷｭ words)
- Rule-based phonetic fallback ﾌｫｱ words ﾉｯﾄ ｲﾝ ｻﾞ dictionary
- Markdown syntax ｱﾝﾄﾞ ｺｰﾄﾞ blocks preserved
- File naming convention: `docs/katalish/<name>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked ﾊﾞｲ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs when producing ｶﾀﾘｯｼｭ documents; ｷｬﾝ ｵﾙｿ ﾋﾞｰ called directly:

- "Generate ｱ katakana-ｲﾝｸﾞﾘｯｼｭ ﾊﾞｰｼﾞｮﾝ ｵﾌﾞ ｻﾞ document"
- "ｱﾄﾞ ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ variant"
- "Translate ﾄｩ katakana ｲﾝｸﾞﾘｯｼｭ"

## Example

```
NixKits — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙｽﾞ.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```