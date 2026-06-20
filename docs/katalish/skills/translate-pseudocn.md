# translate-pseudocn (ｽｷﾙ)

[中文](../../zh/skills/translate-pseudocn.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../../ja/skills/translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md) | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> Pseudo-Chinese (pcn) language support for the document-writing skill. Auto-discovered by write-project-docs.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ (ﾗﾝｹﾞｰｼﾞ ﾊﾞｯｸｴﾝﾄﾞ) |
| ﾊﾟｽ | `skills/translate-pseudocn/SKILL.md` |
| ﾗﾝｹﾞｰｼﾞ ｺｰﾄﾞ | ﾋﾟｰｼｰｴﾇ |
| Called ﾊﾞｲ | ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs (ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰﾄﾞ) |

## ﾌｨｰﾁｬｰｽﾞ

- Pseudo-ﾁｬｲﾆｰｽﾞ (ﾋﾟｰｼｰｴﾇ) ﾄﾗﾝｽﾚｰｼｮﾝ — strips kana, adjusts word order (SOV→SVO)
- Particle replacement, punctuation conversion
- Built-ｲﾝ ~13 term dictionary (ｼﾞｪｲｴｲ→ｾﾞｯﾄｴｲﾁ ﾏｯﾋﾟﾝｸﾞ)
- ｺｰﾄﾞ blocks, ﾅﾝﾊﾞｰｽﾞ, symbols preserved

## ﾕｰｾｰｼﾞ

ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰﾄﾞ ﾊﾞｲ ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs via `translate-*` naming convention:

- "Generate pseudo-ﾁｬｲﾆｰｽﾞ document"
- "ｱﾄﾞ ﾋﾟｰｼｰｴﾇ ﾗﾝｹﾞｰｼﾞ variant"