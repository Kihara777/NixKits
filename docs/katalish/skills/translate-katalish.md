# translate-katalish (ｽｷﾙ)

[中文](../../zh/skills/translate-katalish.md) | [English](translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md)

> Extra natural-language ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ document-writing ｽｷﾙ.  Adds ｻﾞ ｶﾀﾘｯｼｭ (Katakana English) ﾗﾝｹﾞｰｼﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ (ﾗﾝｹﾞｰｼﾞ ﾊﾞｯｸｴﾝﾄﾞ) |
| ﾊﾟｽ | `skills/translate-katalish/SKILL.md` |
| ｺｰﾙﾄﾞ ﾊﾞｲ | write-project-docs (primary), nixkits-check-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- ﾆｭｰ ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ — mechanical word-level English→halfwidth-katakana substitution
- Built-in dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback ﾌｫｱ words ﾉｯﾄ ｲﾝ ｻﾞ dictionary
- Markdown syntax ｱﾝﾄﾞ ｺｰﾄﾞ blocks preserved
- ﾌｧｲﾙ naming convention: `docs/katalish/<name>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked ﾊﾞｲ write-project-docs ｳｪﾝ producing ｶﾀﾘｯｼｭ ﾄﾞｷｭﾒﾝﾄｽﾞ; ｷｬﾝ ｵﾙｿ ﾋﾞｰ ｺｰﾙﾄﾞ directly:

- "ｼﾞｪﾈﾚｲﾄ ｱ katakana-english ﾊﾞｰｼﾞｮﾝ ｵﾌﾞ ｻﾞ ﾄﾞｷｭﾒﾝﾄ"
- "ｱﾄﾞ ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ variant"
- "Translate ﾄｩ katakana english"

## ｴｸﾞｻﾞﾝﾌﾟﾙ

```
NixKits — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙｽﾞ.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```