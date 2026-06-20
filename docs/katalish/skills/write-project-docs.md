# write-project-docs (Skill)

[中文](../../zh/ｽｷﾙs/write-project-docs.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-project-docs.md) | [偽中国語](../../pcn/ｽｷﾙs/write-project-docs.md)

> Generates complete multi-ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ｲﾝ ｻﾞ NixKits style — concise, table-driven.

## Auto-Discovery Contract

Language ｴｸｽﾃﾝｼｮﾝ ｽｷﾙs ｱｰ discovered ﾌﾞｲｱ ｻﾞ `translate-*` naming ｺﾝﾌﾞｴﾝｼｮﾝ: scan `ｽｷﾙs/translate-*/`, read ｲｰﾁ SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register ｾﾞﾑ ｱｽﾞ ｱﾌﾞｴｲﾗﾌﾞﾙ languages ｲﾝ ｻﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ｼﾞｪﾈﾗｴｰｼｮﾝ pipeline.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill |
| Path | `ｽｷﾙs/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses project metadata ｱﾝﾄﾞ extracts ﾓｼﾞｭｰﾙ information
- Classifies ﾓｼﾞｭｰﾙs ﾊﾞｲ ﾌｧﾝｸｼｮﾝ (infra/ｻｰﾋﾞｽs/proxy/ｽｷﾙs)
- Creates `docs/{zh,en,ja}/` ﾃﾞｨﾚｸﾄﾘ ｽﾄﾗｸﾁｬｰ
- Auto-discovers ﾗﾝｹﾞｰｼﾞ extensions ﾌﾞｲｱ `translate-*` naming ｺﾝﾌﾞｴﾝｼｮﾝ ｲﾝ `ｽｷﾙs/translate-*/`
- Writes categorized READMEs ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers
- Writes ﾊﾟｰ-ﾓｼﾞｭｰﾙ docs (info table + ｲﾝｽﾄｰﾙ + usage)
- Writes ｽｷﾙ docs using ｻﾞ unified ﾃﾝﾌﾟﾚｰﾄ (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- Supports sub-ｴｰｼﾞｪﾝﾄ parallelization ﾊﾞｲ ﾓｼﾞｭｰﾙ category

## Skill Doc Sync Rules

When `SKILL.md` changes, ｵｰﾙ corresponding ﾗﾝｹﾞｰｼﾞ ﾊﾞｰｼﾞｮﾝs ﾑｽﾄ ﾋﾞｰ updated.
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

Update ｵﾗﾄﾞｴﾗ: Chinese baseline → English ﾄﾗｱﾝｽﾙｱｼｮﾝ → Japanese ﾄﾗｱﾝｽﾙｱｼｮﾝ → 偽中国語 ﾄﾗｱﾝｽﾙｱｼｮﾝ.
Column ﾏｯﾋﾟﾝｸﾞ: `基本信息` → `ｲﾝﾌｫ` / `基本情報` / `基本情報`, `功能` → `ﾌｨｰﾁｬｰｽﾞ` / `機能` / `機能`.

- Zero fluff, tables over prose, copy-paste-ready ｺｰﾄﾞ blocks
- Technical terms stay ｲﾝ English; warnings ﾕｰｽﾞ blockquote format
- Chinese section titles ﾕｰｽﾞ 2- ｵﾗ 4-character words ﾌｫｱ visual rhythm
- Target ~40-60 lines; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ docs ﾌｫﾛｰ ｻﾞ 4-section standard (ｲﾝﾌｫ → Changes → ｲﾝｽﾄｰﾙ → Notes)
- No standalone technical detail, troubleshooting, ｵﾗ reference sections — compress ｲﾝﾄｩ `## Notes` bullets
- All four READMEs ﾑｽﾄ ﾋﾞｰ updated together
- Root dir ｵﾝﾘｰ holds Chinese suffix-less `.md`; localized ﾊﾞｰｼﾞｮﾝs (`*.en.md`, `*.ja.md`) live ｱﾝﾀﾞｰ `docs/`
- Every ﾗﾝｹﾞｰｼﾞ ﾑｽﾄ ｲﾝｸﾙｰﾄﾞ ｱ basic info section: `## 基本信息` (zh), `## ｲﾝﾌｫ` (en), `## 基本情報` (ja)
- After ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ ｿｰｽ changes, ｻﾞ "Changes"/"ﾌｨｰﾁｬｰｽﾞ" ﾘｽﾄ ﾑｽﾄ ﾋﾞｰ synced — ｲｰﾁ bullet maps ﾄｩ an actual change

## Bidirectional Auto-Discovery

This ｽｷﾙ ｱﾝﾄﾞ `translate-*` ﾄﾗｱﾝｽﾙｱｼｮﾝ ｽｷﾙs discover ｲｰﾁ ｱｻﾞｰ ﾌﾞｲｱ naming conventions:

| Direction | Mechanism |
|-----------|----------|
| Doc ｼﾞｪﾈﾗｴｰｼｮﾝ → translate ｽｷﾙ | Scans `ｽｷﾙs/translate-*/`, reads `language_code`/`display_name`/`base_language` ﾌﾛﾑ ｲｰﾁ SKILL.md frontmatter |
| Translate ｽｷﾙ → This project | Each ｽｷﾙ declares ｱ "Relationship ｳｨｽﾞ ｱｻﾞｰ ｽｷﾙs" table ｲﾝ its SKILL.md, specifying ｻﾞ ｺｰﾙ chain |
| Language ｺｰﾄﾞ → Path | `language_code` → ﾃﾞｨﾚｸﾄﾘ naming, ﾌｧｲﾙ ｴｸｽﾃﾝｼｮﾝ; `display_name` → ﾗﾝｹﾞｰｼﾞ switcher label |

Translate ｽｷﾙ docs themselves ﾌｫﾛｰ ﾃﾞｨｽ ﾃﾝﾌﾟﾚｰﾄ, closing ｻﾞ loop: doc ｼﾞｪﾈﾗｴｰｼｮﾝ → ﾄﾗｱﾝｽﾙｱｼｮﾝ invocation → translate ｽｷﾙ doc ｼﾞｪﾈﾗｴｰｼｮﾝ.

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "write ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" ｵﾗ "generate docs ｲﾝ NixKits style".
