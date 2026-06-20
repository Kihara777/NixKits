# write-project-docs (Skill)

[中文](../../zh/ｽｷﾙs/write-project-docs.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-project-docs.md) | [偽中国語](../../pcn/ｽｷﾙs/write-project-docs.md)

> Generates complete multi-language ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ｲﾝ ｻﾞ NixKits style — concise, table-driven.

## Auto-Discovery Contract

Language extension ｽｷﾙs are discovered ﾌﾞｲｱ ｻﾞ `translate-*` naming convention: scan `ｽｷﾙs/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them as ｱﾌﾞｴｲﾗﾌﾞﾙ languages ｲﾝ ｻﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ generation pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses project metadata ｱﾝﾄﾞ extracts ﾓｼﾞｭｰﾙ information
- Classifies ﾓｼﾞｭｰﾙs ﾊﾞｲ function (infra/ｻｰﾋﾞｽs/proxy/ｽｷﾙs)
- Creates `docs/{zh,en,ja}/` directory structure
- Auto-discovers language extensions ﾌﾞｲｱ `translate-*` naming convention ｲﾝ `ｽｷﾙs/translate-*/`
- Writes categorized READMEs ｳｨｽﾞ language switchers
- Writes ﾊﾟｰ-ﾓｼﾞｭｰﾙ docs (info table + ｲﾝｽﾄｰﾙ + usage)
- Writes ｽｷﾙ docs using ｻﾞ unified ﾃﾝﾌﾟﾚｰﾄ (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- Supports sub-ｴｰｼﾞｪﾝﾄ parallelization ﾊﾞｲ ﾓｼﾞｭｰﾙ category

## Skill Doc Sync Rules

When `SKILL.md` changes, ｵｰﾙ corresponding language ﾊﾞｰｼﾞｮﾝs must be updated.
Use staleness ﾁｪｯｸ ﾄｩ locate outdated files:

```bash
ﾌｫｱ lang ｲﾝ zh en ja; do
  ﾌｫｱ skill ｲﾝ skills/*/SKILL.md; do
    ﾈｰﾑ=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$ﾈｰﾑ.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$ﾈｰﾑ"
  done
done
```

Update order: Chinese baseline → English translation → Japanese translation → 偽中国語 translation.
Column mapping: `基本信息` → `ｲﾝﾌｫ` / `基本情報` / `基本情報`, `功能` → `ﾌｨｰﾁｬｰｽﾞ` / `機能` / `機能`.

- Zero fluff, tables over prose, copy-paste-ready code blocks
- Technical terms stay ｲﾝ English; warnings ﾕｰｽﾞ blockquote format
- Chinese section titles ﾕｰｽﾞ 2- ｵﾗ 4-character words ﾌｫｱ visual rhythm
- Target ~40-60 lines; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ docs follow ｻﾞ 4-section standard (ｲﾝﾌｫ → Changes → ｲﾝｽﾄｰﾙ → Notes)
- No standalone technical detail, troubleshooting, ｵﾗ reference sections — compress into `## Notes` bullets
- All four READMEs must be updated together
- Root dir only holds Chinese suffix-less `.md`; localized ﾊﾞｰｼﾞｮﾝs (`*.en.md`, `*.ja.md`) live under `docs/`
- Every language must include a basic info section: `## 基本信息` (zh), `## ｲﾝﾌｫ` (en), `## 基本情報` (ja)
- After ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ source changes, ｻﾞ "Changes"/"ﾌｨｰﾁｬｰｽﾞ" ﾘｽﾄ must be synced — each bullet maps ﾄｩ an actual change

## Bidirectional Auto-Discovery

This ｽｷﾙ ｱﾝﾄﾞ `translate-*` translation ｽｷﾙs discover each other ﾌﾞｲｱ naming conventions:

| Direction | Mechanism |
|-----------|----------|
| Doc generation → translate ｽｷﾙ | Scans `ｽｷﾙs/translate-*/`, reads `language_code`/`display_name`/`base_language` ﾌﾛﾑ each SKILL.md frontmatter |
| Translate ｽｷﾙ → This project | Each ｽｷﾙ declares a "Relationship ｳｨｽﾞ other ｽｷﾙs" table ｲﾝ its SKILL.md, specifying ｻﾞ call chain |
| Language code → Path | `language_code` → directory naming, file extension; `display_name` → language switcher label |

Translate ｽｷﾙ docs themselves follow ﾃﾞｨｽ ﾃﾝﾌﾟﾚｰﾄ, closing ｻﾞ loop: doc generation → translation invocation → translate ｽｷﾙ doc generation.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "write ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" ｵﾗ "generate docs ｲﾝ NixKits style".
