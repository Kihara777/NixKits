# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md)

> Generates complete multi-language documentation following the NixKits style — trilingual (zh/en/ja), concise, table-driven.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/write-project-docs/SKILL.md` |

## Features

- Assesses project metadata and extracts module information
- Classifies modules by function (infra/services/proxy/skills)
- Creates `docs/{zh,en,ja}/` directory structure
- Writes categorized READMEs with language switchers
- Writes per-module docs (info table + install + usage)
- Writes skill docs using the unified template (Info → Features → Usage)
- Supports sub-agent parallelization by module category

## Skill Doc Sync Rules

When `SKILL.md` changes, the corresponding trilingual docs must be updated.
Use staleness check to locate outdated files:

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

Update order: Chinese baseline → English translation → Japanese translation.
Column mapping: `基本信息` → `Info` / `基本情報`, `功能` → `Features` / `機能`.

## Writing Rules

- Zero fluff, tables over prose, copy-paste-ready code blocks
- Technical terms stay in English; warnings use blockquote format
- Chinese section titles use 2- or 4-character words for visual rhythm
- Target ~40-60 lines; patch/module docs follow the 4-section standard (Info → Changes → Install → Notes)
- No standalone technical detail, troubleshooting, or reference sections — compress into `## Notes` bullets
- All three READMEs must be updated together
- Japanese docs must include a `## 基本情報` table

## Usage

Activated when the user asks to "write documentation" or "generate docs in NixKits style".
