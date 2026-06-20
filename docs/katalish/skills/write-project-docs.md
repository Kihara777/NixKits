# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/write-project-docs.md)

> Generates complete multi-ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ in ｻﾞ NixKits style — concise, table-driven.

## Auto-Discovery Contract

Language extension skills ｱｰ discovered via ｻﾞ `translate-*` naming convention: scan `skills/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them as ｱﾌﾞｴｲﾗﾌﾞﾙ languages in ｻﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ generation pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses project metadata ｱﾝﾄﾞ extracts ﾓｼﾞｭｰﾙ information
- Classifies modules ﾊﾞｲ function (infra/services/proxy/skills)
- Creates `docs/{zh,en,ja}/` directory structure
- Auto-discovers ﾗﾝｹﾞｰｼﾞ extensions via `translate-*` naming convention in `skills/translate-*/`
- Writes categorized READMEs ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers
- Writes ﾊﾟｰ-ﾓｼﾞｭｰﾙ docs (info table + ｲﾝｽﾄｰﾙ + usage)
- Writes skill docs using ｻﾞ unified template (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- Supports sub-ｴｰｼﾞｪﾝﾄ parallelization ﾊﾞｲ ﾓｼﾞｭｰﾙ category

## Skill Doc Sync Rules

When `SKILL.md` changes, ｵｰﾙ corresponding ﾗﾝｹﾞｰｼﾞ versions must be updated.
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

Update order: Chinese baseline → English ﾄﾗｱﾝｽﾙｱｼｮﾝ → Japanese ﾄﾗｱﾝｽﾙｱｼｮﾝ → 偽中国語 ﾄﾗｱﾝｽﾙｱｼｮﾝ.
Column mapping: `基本信息` → `ｲﾝﾌｫ` / `基本情報` / `基本情報`, `功能` → `ﾌｨｰﾁｬｰｽﾞ` / `機能` / `機能`.

- Zero fluff, tables over prose, copy-paste-ready code blocks
- Technical terms stay in English; warnings ﾕｰｽﾞ blockquote format
- Chinese section titles ﾕｰｽﾞ 2- ｵﾗ 4-character words ﾌｫｱ visual rhythm
- Target ~40-60 lines; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ docs ﾌｫﾛｰ ｻﾞ 4-section standard (ｲﾝﾌｫ → Changes → ｲﾝｽﾄｰﾙ → Notes)
- No standalone technical detail, troubleshooting, ｵﾗ reference sections — compress ｲﾝﾄｩ `## Notes` bullets
- All four READMEs must be updated together
- Root dir ｵﾝﾘｰ holds Chinese suffix-less `.md`; localized versions (`*.en.md`, `*.ja.md`) live under `docs/`
- Every ﾗﾝｹﾞｰｼﾞ must ｲﾝｸﾙｰﾄﾞ ｱ basic info section: `## 基本信息` (zh), `## ｲﾝﾌｫ` (en), `## 基本情報` (ja)
- After ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ source changes, ｻﾞ "Changes"/"ﾌｨｰﾁｬｰｽﾞ" list must be synced — each bullet maps to an actual change

## Bidirectional Auto-Discovery

This skill ｱﾝﾄﾞ `translate-*` ﾄﾗｱﾝｽﾙｱｼｮﾝ skills discover each other via naming conventions:

| Direction | Mechanism |
|-----------|----------|
| Doc generation → translate skill | Scans `skills/translate-*/`, reads `language_code`/`display_name`/`base_language` ﾌﾛﾑ each SKILL.md frontmatter |
| Translate skill → This project | Each skill declares ｱ "Relationship ｳｨｽﾞ other skills" table in its SKILL.md, specifying ｻﾞ call chain |
| Language code → Path | `language_code` → directory naming, file extension; `display_name` → ﾗﾝｹﾞｰｼﾞ switcher label |

Translate skill docs themselves ﾌｫﾛｰ ﾃﾞｨｽ template, closing ｻﾞ loop: doc generation → ﾄﾗｱﾝｽﾙｱｼｮﾝ invocation → translate skill doc generation.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ user asks to "write ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" ｵﾗ "generate docs in NixKits style".
