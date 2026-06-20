# ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs (ｽｷﾙ)

[中文](../../zh/skills/write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/write-project-docs.md)

> Generates complete multi-language documentation in the NixKits style — concise, table-driven.

## ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ ｺﾝﾄﾗｸﾄ

ﾗﾝｹﾞｰｼﾞ ｴｸｽﾃﾝｼｮﾝ ｽｷﾙｽﾞ ｱｰ ﾃﾞｨｽｶﾊﾞｰﾄﾞ via ｻﾞ `translate-*` naming convention: scan `skills/translate-*/`, ﾘｰﾄﾞ ｲｰﾁ ｽｷﾙ.md's ﾌﾛﾝﾄﾏﾀｰ fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them ｱｽﾞ available ﾗﾝｹﾞｰｼﾞｽﾞ ｲﾝ ｻﾞ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ generation pipeline.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses ﾌﾟﾛｼﾞｪｸﾄ metadata ｱﾝﾄﾞ extracts ﾓｼﾞｭｰﾙ information
- Classifies ﾓｼﾞｭｰﾙｽﾞ ﾊﾞｲ function (infra/ｻｰﾋﾞｽｽﾞ/proxy/ｽｷﾙｽﾞ)
- ｸﾘｴｲﾄｽﾞ `docs/{zh,en,ja}/` directory structure
- ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰｽﾞ ﾗﾝｹﾞｰｼﾞ ｴｸｽﾃﾝｼｮﾝｽﾞ via `translate-*` naming convention ｲﾝ `skills/translate-*/`
- ﾗｲﾄｽﾞ categorized READMEs ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers
- ﾗｲﾄｽﾞ per-ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ (ｲﾝﾌｫ ﾃｰﾌﾞﾙ + ｲﾝｽﾄｰﾙ + ﾕｰｾｰｼﾞ)
- ﾗｲﾄｽﾞ ｽｷﾙ ﾄﾞｷｭｽﾞ using ｻﾞ unified ﾃﾝﾌﾟﾚｰﾄ (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- ｻﾎﾟｰﾄｽﾞ sub-ｴｰｼﾞｪﾝﾄ parallelization ﾊﾞｲ ﾓｼﾞｭｰﾙ category

## ｽｷﾙ ﾄﾞｷｭ Sync Rules

When `SKILL.md` changes, ｵｰﾙ corresponding ﾗﾝｹﾞｰｼﾞ ﾊﾞｰｼﾞｮﾝｽﾞ ﾏｽﾄ ﾋﾞｰ updated.
Use staleness check ﾄｩ locate outdated files:

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

ｱｯﾌﾟﾃﾞｰﾄ order: ﾁｬｲﾆｰｽﾞ baseline → ｲﾝｸﾞﾘｯｼｭ ﾄﾗﾝｽﾚｰｼｮﾝ → ｼﾞｬﾊﾟﾆｰｽﾞ ﾄﾗﾝｽﾚｰｼｮﾝ → Pseudo-ﾁｬｲﾆｰｽﾞ ﾄﾗﾝｽﾚｰｼｮﾝ.
Column ﾏｯﾋﾟﾝｸﾞ: `基本信息` → `Info` / `基本情報` / `基本情報`, `功能` → `Features` / `機能` / `機能`.

- Zero fluff, ﾃｰﾌﾞﾙｽﾞ over prose, copy-paste-ready ｺｰﾄﾞ blocks
- Technical terms stay ｲﾝ ｲﾝｸﾞﾘｯｼｭ; warnings use blockquote ﾌｫｰﾏｯﾄ
- ﾁｬｲﾆｰｽﾞ ｾｸｼｮﾝ ﾀｲﾄﾙｽﾞ use 2- ｵｱ 4-character words ﾌｫｱ visual rhythm
- Target ~40-60 ﾗｲﾝｽﾞ; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ follow ｻﾞ 4-section standard (ｲﾝﾌｫ → Changes → ｲﾝｽﾄｰﾙ → Notes)
- ﾉｰ standalone technical detail, troubleshooting, ｵｱ reference ｾｸｼｮﾝｽﾞ — compress into `## Notes` bullets
- ｵｰﾙ four READMEs ﾏｽﾄ ﾋﾞｰ updated together
- ﾙｰﾄ dir ｵﾝﾘｰ holds ﾁｬｲﾆｰｽﾞ suffix-less `.md`; localized ﾊﾞｰｼﾞｮﾝｽﾞ (`*.en.md`, `*.ja.md`) live under `docs/`
- Every ﾗﾝｹﾞｰｼﾞ ﾏｽﾄ include ｱ basic ｲﾝﾌｫ ｾｸｼｮﾝ: `## 基本信息` (ｾﾞｯﾄｴｲﾁ), `## Info` (ｴﾇ), `## 基本情報` (ｼﾞｪｲｴｲ)
- After ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ ｿｰｽ changes, ｻﾞ "Changes"/"ﾌｨｰﾁｬｰｽﾞ" ﾘｽﾄ ﾏｽﾄ ﾋﾞｰ synced — ｲｰﾁ bullet maps ﾄｩ ｱﾝ actual change

## Bidirectional ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ

ﾃﾞｨｽ ｽｷﾙ ｱﾝﾄﾞ `translate-*` ﾄﾗﾝｽﾚｰｼｮﾝ ｽｷﾙｽﾞ ﾃﾞｨｽｶﾊﾞｰ ｲｰﾁ ｱｻﾞｰ via naming conventions:

| Direction | Mechanism |
|-----------|----------|
| ﾄﾞｷｭ generation → translate ｽｷﾙ | Scans `skills/translate-*/`, ﾘｰﾄﾞｽﾞ `language_code`/`display_name`/`base_language` ﾌﾛﾑ ｲｰﾁ ｽｷﾙ.md ﾌﾛﾝﾄﾏﾀｰ |
| Translate ｽｷﾙ → ﾃﾞｨｽ ﾌﾟﾛｼﾞｪｸﾄ | ｲｰﾁ ｽｷﾙ declares ｱ "Relationship ｳｨｽﾞ ｱｻﾞｰ ｽｷﾙｽﾞ" ﾃｰﾌﾞﾙ ｲﾝ ｲｯﾂ ｽｷﾙ.md, specifying ｻﾞ call chain |
| ﾗﾝｹﾞｰｼﾞ ｺｰﾄﾞ → ﾊﾟｽ | `language_code` → directory naming, file ｴｸｽﾃﾝｼｮﾝ; `display_name` → ﾗﾝｹﾞｰｼﾞ switcher label |

Translate ｽｷﾙ ﾄﾞｷｭｽﾞ themselves follow ﾃﾞｨｽ ﾃﾝﾌﾟﾚｰﾄ, closing ｻﾞ loop: ﾄﾞｷｭ generation → ﾄﾗﾝｽﾚｰｼｮﾝ invocation → translate ｽｷﾙ ﾄﾞｷｭ generation.

## ﾕｰｾｰｼﾞ

Activated when ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ﾗｲﾄ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" ｵｱ "generate ﾄﾞｷｭｽﾞ ｲﾝ NixKits style".