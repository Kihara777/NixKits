# translate-katalish (Skill)

[中文](../../zh/ｽｷﾙs/translate-katalish.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/translate-katalish.md) | [偽中国語](../../pcn/ｽｷﾙs/translate-katalish.md)

> Extra natural-ﾗﾝｹﾞｰｼﾞ ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ ﾄﾞｷｭﾒﾝﾄ-writing ｽｷﾙ.  Adds ｻﾞ ｶﾀﾘｯｼｭ (Katakana English) ﾗﾝｹﾞｰｼﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill (ﾗﾝｹﾞｰｼﾞ backend) |
| Path | `ｽｷﾙs/translate-katalish/SKILL.md` |
| Called ﾊﾞｲ | write-project-docs (primary), nixkits-ﾁｪｯｸ-updates (indirect) |

## ﾌｨｰﾁｬｰｽﾞ

- New ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ — ﾑｴﾁｱﾝｲｸｱﾙ ﾜｰﾄﾞ-ﾚﾍﾞﾙ English→halfwidth-katakana ｻﾌﾞｽﾃｨﾃｭｰｼｮﾝ
- Built-ｲﾝ dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback ﾌｫｱ words ﾉｯﾄ ｲﾝ ｻﾞ dictionary
- Markdown syntax ｱﾝﾄﾞ ｺｰﾄﾞ blocks preserved
- File naming ｺﾝﾌﾞｴﾝｼｮﾝ: `docs/katalish/<ﾈｰﾑ>.md`

## ﾕｰｾｰｼﾞ

Automatically invoked ﾊﾞｲ write-project-docs ｳｪﾝ producing ｶﾀﾘｯｼｭ documents; ｷｬﾝ ｵﾙｿ ﾋﾞｰ called directly:

- "Generate ｱ katakana-english ﾊﾞｰｼﾞｮﾝ ｵﾌﾞ ｻﾞ ﾄﾞｷｭﾒﾝﾄ"
- "Add ｶﾀﾘｯｼｭ ﾗﾝｹﾞｰｼﾞ variant"
- "Translate ﾄｩ katakana english"

## Example

```
NixKits — software, patches, NixOS modules ｱﾝﾄﾞ coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
