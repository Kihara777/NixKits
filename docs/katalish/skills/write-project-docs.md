# write-project-docs (ｽｷﾙ)

[中文](../../zh/skills/write-project-docs.md) | [English](write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-project-docs.md)

> ｼﾞｪﾈﾚｲﾂ complete multi-language ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ﾌｫﾛｰｲﾝｸﾞ ｻﾞ NixKits style — trilingual (zh/en/ja), concise, table-driven.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/write-project-docs/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Assesses ﾌﾟﾛｼﾞｪｸﾄ metadata ｱﾝﾄﾞ extracts ﾓｼﾞｭｰﾙ information
- Classifies ﾓｼﾞｭｰﾙｽﾞ ﾊﾞｲ function (infra/services/proxy/ｽｷﾙｽﾞ)
- Creates `docs/{zh,en,ja}/` ﾃﾞｨﾚｸﾄﾘ structure
- Auto-discovers ﾗﾝｹﾞｰｼﾞ extensions via `translate-*` naming convention ｲﾝ `skills/translate-*/`
- Writes categorized READMEs ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ switchers
- Writes per-module ﾄﾞｷｭｽﾞ (ｲﾝﾌｫ ﾃｰﾌﾞﾙ + ｲﾝｽﾄｰﾙ + ﾕｰｾｰｼﾞ)
- Writes ｽｷﾙ ﾄﾞｷｭｽﾞ ﾕｰｼﾞﾝｸﾞ ｻﾞ unified ﾃﾝﾌﾟﾚｰﾄ (ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ)
- Supports sub-agent parallelization ﾊﾞｲ ﾓｼﾞｭｰﾙ category

## ｽｷﾙ ﾄﾞｷｭ Sync ﾙｰﾙｽﾞ

ｳｪﾝ `SKILL.md` ﾁｪﾝｼﾞｰｽﾞ, ｻﾞ corresponding quadrilingual ﾄﾞｷｭｽﾞ ﾏｽﾄ ﾋﾞｰ updated.
ﾕｰｽﾞ staleness ﾁｪｯｸ ﾄｩ locate outdated ﾌｧｲﾙｽﾞ:

```bash
ﾌｫｱ lang ｲﾝ zh en ja; do
  ﾌｫｱ ｽｷﾙ ｲﾝ ｽｷﾙｽﾞ/*/ｽｷﾙ.md; do
    ﾈｰﾑ=$(basename $(dirname $ｽｷﾙ))
    ﾄﾞｷｭ="ﾄﾞｷｭｽﾞ/$lang/ｽｷﾙｽﾞ/$ﾈｰﾑ.md"
    [ "$ｽｷﾙ" -nt "$ﾄﾞｷｭ" ] && echo "STALE: $lang/$ﾈｰﾑ"
  done
done
```

ｱｯﾌﾟﾃﾞｰﾄ order: Chinese baseline → English translation → Japanese translation → Pseudo-Chinese translation.
Column ﾏｯﾋﾟﾝｸﾞ: `基本信息` → `Info` / `基本情報` / `基本情報`, `功能` → `Features` / `機能` / `機能`.

- Zero fluff, tables over prose, copy-paste-ready ｺｰﾄﾞ blocks
- Technical terms stay ｲﾝ English; warnings ﾕｰｽﾞ blockquote ﾌｫｰﾏｯﾄ
- Chinese ｾｸｼｮﾝ titles ﾕｰｽﾞ 2- ｵｱ 4-character words ﾌｫｱ visual rhythm
- Target ~40-60 ﾗｲﾝｽﾞ; ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ ﾌｫﾛｰ ｻﾞ 4-section standard (ｲﾝﾌｫ → ﾁｪﾝｼﾞｰｽﾞ → ｲﾝｽﾄｰﾙ → ﾉｰﾂ)
- ﾉｰ standalone technical detail, troubleshooting, ｵｱ ﾘﾌｧﾚﾝｽ ｾｸｼｮﾝｽﾞ — compress into `## Notes` bullets
- ｵｰﾙ four READMEs ﾏｽﾄ ﾋﾞｰ updated together
- ﾙｰﾄ dir ｵﾝﾘｰ holds Chinese suffix-less `.md`; localized versions (`*.en.md`, `*.ja.md`) live under `docs/`
- Every ﾗﾝｹﾞｰｼﾞ ﾏｽﾄ ｲﾝｸﾙｰﾄﾞ ｱ basic ｲﾝﾌｫ ｾｸｼｮﾝ: `## 基本信息` (zh), `## Info` (en), `## 基本情報` (ja)
- ｱﾌﾀｰ ﾊﾟｯﾁ/ﾓｼﾞｭｰﾙ ｿｰｽ ﾁｪﾝｼﾞｰｽﾞ, ｻﾞ "ﾁｪﾝｼﾞｰｽﾞ"/"ﾌｨｰﾁｬｰｽﾞ" ﾘｽﾄ ﾏｽﾄ ﾋﾞｰ synced — ｲｰﾁ bullet maps ﾄｩ ｱﾝ actual ﾁｪﾝｼﾞ

## ﾕｰｾｰｼﾞ

Activated ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ asks ﾄｩ "ﾗｲﾄ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ" ｵｱ "ｼﾞｪﾈﾚｲﾄ ﾄﾞｷｭｽﾞ ｲﾝ NixKits style".