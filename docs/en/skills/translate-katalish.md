# translate-katalish (Skill)

[中文](../../zh/skills/translate-katalish.md) | [English](translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md)

> Extra natural-language support for the document-writing skill.  Adds the ｶﾀﾘｯｼｭ (Katakana English) language.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill (language backend) |
| Path | `skills/translate-katalish/SKILL.md` |
| Called by | write-project-docs (primary), nixkits-check-updates (indirect) |

## Features

- New ｶﾀﾘｯｼｭ language — mechanical word-level English→halfwidth-katakana substitution
- Built-in dictionary (~20 common tech-doc words)
- Rule-based phonetic fallback for words not in the dictionary
- Markdown syntax and code blocks preserved
- File naming convention: `docs/katalish/<name>.md`

## Usage

Automatically invoked by write-project-docs when producing ｶﾀﾘｯｼｭ documents; can also be called directly:

- "Generate a katakana-english version of the document"
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
