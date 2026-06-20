# translate-katakana (Skill)

[中文](../../zh/skills/translate-katakana.md) | [English](translate-katakana.md) | [日本語](../../ja/skills/translate-katakana.md)

> Extra natural-language support for the document-writing skill.  Adds the kata-en (Katakana English) language.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `skills/translate-katakana/SKILL.md` |
| Called by | write-project-docs (primary), nixkits-check-updates (indirect) |

## Features

- New kata-en language — mechanical word-level English→halfwidth-katakana substitution
- Built-in dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback for words not in the dictionary
- Markdown syntax and code blocks preserved
- File naming convention: `docs/kata/<name>.md`

## Usage

Automatically invoked by write-project-docs when producing kata-en documents; can also be called directly:

- "Generate a katakana-english version of the document"
- "Add kata-en language variant"
- "Translate to katakana english"

## Example

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
