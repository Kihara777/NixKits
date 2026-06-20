# write-project-docs (Skill)

[中文](../../zh/ｽｷﾙs/write-project-docs.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-project-docs.md) | [偽中国語](../../pcn/ｽｷﾙs/write-project-docs.md)

> Generates complete multi-language ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ in the NixKits style — concise, table-driven.

## Auto-Discovery Contract

Language extension ｽｷﾙs are discovered via the `translate-*` naming convention: scan `ｽｷﾙs/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), and register them as available languages in the ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ generation pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses project metadata and extracts ﾓｼﾞｭｰﾙ information
- Classifies ﾓｼﾞｭｰﾙs by function (infra/ｻｰﾋﾞｽs/proxy/ｽｷﾙs)
- Creates `docs/{zh,en,ja}/` directory structure
- Auto-discovers language extensions via `translate-*` naming convention in `ｽｷﾙs/translate-*/`
- Writes categorized READMEs with language switchers
- Writes per-ﾓｼﾞｭｰﾙ docs (info table + ｲﾝｽﾄｰﾙ + usage)
- Writes ｽｷﾙ docs using the unified ﾃﾝﾌﾟﾚｰﾄ (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- Supports sub-ｴｰｼﾞｪﾝﾄ parallelization by ﾓｼﾞｭｰﾙ category

## Skill Doc Sync Rules

When `SKILL.md` changes, all corresponding language ﾊﾞｰｼﾞｮﾝs must be updated.
Use staleness ﾁｪｯｸ to locate outdated files:

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

Update order: Chinese baseline → English translation → Japanese translation → 偽中国語 translation.
Column mapping: `基本信息` → `ｲﾝﾌｫ` / `基本情報` / `基本情報`, `功能` → `ﾌｨｰﾁｬｰｽﾞ` / `機能` / `機能`.

- Zero fluff, tables over prose, copy-paste-ready code blocks
- Technical terms stay in English; warnings use blockquote format
- Chinese section titles use 2- or 4-character words for visual rhythm
- Target ~40-60 lines; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ docs follow the 4-section standard (ｲﾝﾌｫ → Changes → ｲﾝｽﾄｰﾙ → Notes)
- No standalone technical detail, troubleshooting, or reference sections — compress into `## Notes` bullets
- All four READMEs must be updated together
- Root dir only holds Chinese suffix-less `.md`; localized ﾊﾞｰｼﾞｮﾝs (`*.en.md`, `*.ja.md`) live under `docs/`
- Every language must include a basic info section: `## 基本信息` (zh), `## ｲﾝﾌｫ` (en), `## 基本情報` (ja)
- After ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ source changes, the "Changes"/"ﾌｨｰﾁｬｰｽﾞ" list must be synced — each bullet maps to an actual change

## Bidirectional Auto-Discovery

This ｽｷﾙ and `translate-*` translation ｽｷﾙs discover each other via naming conventions:

| Direction | Mechanism |
|-----------|----------|
| Doc generation → translate ｽｷﾙ | Scans `ｽｷﾙs/translate-*/`, reads `language_code`/`display_name`/`base_language` from each SKILL.md frontmatter |
| Translate ｽｷﾙ → This project | Each ｽｷﾙ declares a "Relationship with other ｽｷﾙs" table in its SKILL.md, specifying the call chain |
| Language code → Path | `language_code` → directory naming, file extension; `display_name` → language switcher label |

Translate ｽｷﾙ docs themselves follow this ﾃﾝﾌﾟﾚｰﾄ, closing the loop: doc generation → translation invocation → translate ｽｷﾙ doc generation.

## ﾕｰｾｰｼﾞ

Activated when the user asks to "write ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" or "generate docs in NixKits style".
