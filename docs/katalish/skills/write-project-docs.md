# write-project-docs (Skill)

[ 中文 [](../../] ｾﾞｯﾄｴｲﾁ / ｽｷﾙｽﾞ / [write-project-docs] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [write-project-docs] . md ) | [ [日本語] [](../../] ｼﾞｪｲｴｲ / ｽｷﾙｽﾞ / [write-project-docs] . md )

> [Generates] [complete] [multi-language] ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ [following] ｻﾞ NixKits [style] — [trilingual] ( ｾﾞｯﾄｴｲﾁ / ｴﾇ / ｼﾞｪｲｴｲ ), [concise] , [table-driven] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾀｲﾌﾟ|ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ
ﾊﾟｽ|` ｽｷﾙｽﾞ / ﾗｲﾄ - ﾌﾟﾛｼﾞｪｸﾄ - ﾄﾞｷｭｽﾞ / ｽｷﾙ . md `

## Features

- [Assesses] ﾌﾟﾛｼﾞｪｸﾄ [metadata] ｱﾝﾄﾞ [extracts] ﾓｼﾞｭｰﾙ [information]
- [Classifies] ﾓｼﾞｭｰﾙｽﾞ ﾊﾞｲ [function] ( [infra] / [services] / [proxy] / ｽｷﾙｽﾞ )
- [Creates] ` ﾄﾞｷｭｽﾞ /{ ｾﾞｯﾄｴｲﾁ , ｴﾇ , ｼﾞｪｲｴｲ }/` ﾃﾞｨﾚｸﾄﾘ [structure]
- [Auto-discovers] ﾗﾝｹﾞｰｼﾞ [extensions] [via] ` [translate-] *` [naming] [convention] ｲﾝ ` ｽｷﾙｽﾞ / [translate-] */`
- [Writes] [categorized] [READMEs] ｳｨｽﾞ ﾗﾝｹﾞｰｼﾞ [switchers]
- [Writes] [per-module] ﾄﾞｷｭｽﾞ ( ｲﾝﾌｫ ﾃｰﾌﾞﾙ + ｲﾝｽﾄｰﾙ + ﾕｰｾｰｼﾞ )
- [Writes] ｽｷﾙ ﾄﾞｷｭｽﾞ ﾕｰｼﾞﾝｸﾞ ｻﾞ [unified] ﾃﾝﾌﾟﾚｰﾄ ( ｲﾝﾌｫ → ﾌｨｰﾁｬｰｽﾞ → ﾕｰｾｰｼﾞ )
- [Supports] [sub-agent] [parallelization] ﾊﾞｲ ﾓｼﾞｭｰﾙ [category]

## Skill Doc Sync Rules

ｳｪﾝ ` ｽｷﾙ . md ` [changes] , ｻﾞ [corresponding] [quadrilingual] ﾄﾞｷｭｽﾞ ﾏｽﾄ ﾋﾞｰ [updated] .
ﾕｰｽﾞ [staleness] ﾁｪｯｸ ﾄｩ [locate] [outdated] ﾌｧｲﾙｽﾞ :

```bash
ﾌｫｱ [lang] ｲﾝ ｾﾞｯﾄｴｲﾁ ｴﾇ ｼﾞｪｲｴｲ ; do
ﾌｫｱ ｽｷﾙ ｲﾝ ｽｷﾙｽﾞ [/*/] ｽｷﾙ . md ; do
ﾈｰﾑ [=$(] [basename] $( [dirname] $ ｽｷﾙ ))
ﾄﾞｷｭ =" ﾄﾞｷｭｽﾞ /$ [lang] / ｽｷﾙｽﾞ /$ ﾈｰﾑ . md "
[ "$ ｽｷﾙ " [-nt] "$ ﾄﾞｷｭ " ] && [echo] " [STALE] : $ [lang] /$ ﾈｰﾑ "
[done]
[done]
```

ｱｯﾌﾟﾃﾞｰﾄ [order] : ﾁｬｲﾆｰｽﾞ [baseline] → ｲﾝｸﾞﾘｯｼｭ [translation] → ｼﾞｬﾊﾟﾆｰｽﾞ [translation] → [Pseudo-Chinese] [translation] .
[Column] ﾏｯﾋﾟﾝｸﾞ : ` [基本信息] ` → ` ｲﾝﾌｫ ` / ` [基本情報] ` / ` [基本情報] `, ` 功能 ` → ` ﾌｨｰﾁｬｰｽﾞ ` / ` 機能 ` / ` 機能 `.

- [Zero] [fluff] , [tables] [over] [prose] , [copy-paste-ready] ｺｰﾄﾞ [blocks]
- [Technical] [terms] [stay] ｲﾝ ｲﾝｸﾞﾘｯｼｭ ; [warnings] ﾕｰｽﾞ [blockquote] ﾌｫｰﾏｯﾄ
- ﾁｬｲﾆｰｽﾞ ｾｸｼｮﾝ [titles] ﾕｰｽﾞ 2- ｵｱ [4-character] [words] ﾌｫｱ [visual] [rhythm]
- [Target] ~ [40-60] ﾗｲﾝｽﾞ ; ﾊﾟｯﾁ / ﾓｼﾞｭｰﾙ ﾄﾞｷｭｽﾞ [follow] ｻﾞ [4-section] [standard] ( ｲﾝﾌｫ → [Changes] → ｲﾝｽﾄｰﾙ → ﾉｰﾂ )
- ﾉｰ [standalone] [technical] [detail] , [troubleshooting] , ｵｱ [reference] [sections] — [compress] [into] `## ﾉｰﾂ ` [bullets]
- ｵｰﾙ [four] [READMEs] ﾏｽﾄ ﾋﾞｰ [updated] [together]
- ﾙｰﾄ [dir] ｵﾝﾘｰ [holds] ﾁｬｲﾆｰｽﾞ [suffix-less] `. md `; [localized] [versions] (`*. ｴﾇ . md `, `*. ｼﾞｪｲｴｲ . md `) [live] [under] ` ﾄﾞｷｭｽﾞ /`
- [Every] ﾗﾝｹﾞｰｼﾞ ﾏｽﾄ [include] ｱ [basic] ｲﾝﾌｫ ｾｸｼｮﾝ : `## [基本信息] ` ( ｾﾞｯﾄｴｲﾁ ), `## ｲﾝﾌｫ ` ( ｴﾇ ), `## [基本情報] ` ( ｼﾞｪｲｴｲ )
- ｱﾌﾀｰ ﾊﾟｯﾁ / ﾓｼﾞｭｰﾙ ｿｰｽ [changes] , ｻﾞ " [Changes] ["/"] ﾌｨｰﾁｬｰｽﾞ " ﾘｽﾄ ﾏｽﾄ ﾋﾞｰ [synced] — ｲｰﾁ [bullet] [maps] ﾄｩ ｱﾝ [actual] [change]

## Usage

[Activated] ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ [asks] ﾄｩ " ﾗｲﾄ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ " ｵｱ " [generate] ﾄﾞｷｭｽﾞ ｲﾝ NixKits [style] ".