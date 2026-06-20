# translate-pseudocn (Skill)

[中文](../../zh/skills/translate-pseudocn.md) | [English](translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md) | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> Pseudo-Chinese (pcn) language support for the document-writing skill. Auto-discovered by write-project-docs.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `skills/translate-pseudocn/SKILL.md` |
| Language code | pcn |
| Called by | write-project-docs (auto-discovered) |

## Features

- Pseudo-Chinese (pcn) translation — strips kana, adjusts word order (SOV→SVO)
- Particle replacement, punctuation conversion
- Built-in ~13 term dictionary (JA→ZH mapping)
- Code blocks, numbers, symbols preserved

## Usage

Auto-discovered by write-project-docs via `translate-*` naming convention:

- "Generate pseudo-Chinese document"
- "Add pcn language variant"
