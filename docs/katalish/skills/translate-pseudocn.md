# translate-pseudocn (Skill)

[中文](../../zh/skills/translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> 偽中国語 (Pseudo-Chinese / pcn) ﾗﾝｹﾞｰｼﾞ ｻﾎﾟｰﾄ ﾌｫｱ ｻﾞ document-writing skill. Auto-discovered ﾊﾞｲ write-project-docs.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (ﾗﾝｹﾞｰｼﾞ backend) |
| Path | `skills/translate-pseudocn/SKILL.md` |
| Language code | pcn |
| Called ﾊﾞｲ | write-project-docs (auto-discovered) |

## ﾌｨｰﾁｬｰｽﾞ

- 偽中国語 (Pseudo-Chinese) ﾄﾗｱﾝｽﾙｱｼｮﾝ — strips kana, adjusts word order (SOV→SVO)
- Particle replacement, punctuation conversion
- Built-in ~13 term dictionary (JA→ZH mapping)
- Code blocks, numbers, symbols preserved

## ﾕｰｾｰｼﾞ

Auto-discovered ﾊﾞｲ write-project-docs via `translate-*` naming convention:

- "Generate pseudo-Chinese document"
- "Add pcn ﾗﾝｹﾞｰｼﾞ variant"
