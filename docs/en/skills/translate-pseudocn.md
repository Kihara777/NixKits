# translate-pseudocn (Skill)

[中文](../../zh/skills/translate-pseudocn.md) | English | [日本語](../../ja/skills/translate-pseudocn.md)  | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> 偽中国語 (Pseudo-Chinese / pcn) language support for the document-writing skill. Auto-discovered by write-project-docs.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `skills/translate-pseudocn/` (`SKILL.md` + `dictionary.md`) |
| Companion | `dictionary.md` -- the built-in katakana-to-kanji mapping dictionary (measured: **75** entries); consult it while translating and when self-checking for leftover kana |
| Language code | pcn |
| Called by | write-project-docs (auto-discovered) |

## Features

- 偽中国語 (Pseudo-Chinese) translation — strips kana, adjusts word order (SOV→SVO)
- Particle replacement, punctuation conversion
- Built-in katakana-to-kanji dictionary (`dictionary.md`, **75** entries: everyday terms like software/hardware/version/upstream plus IT terminology)
- Code blocks, numbers, symbols preserved

## Usage

Auto-discovered by write-project-docs via `translate-*` naming convention:

- "Generate pseudo-Chinese document"
- "Add pcn language variant"
