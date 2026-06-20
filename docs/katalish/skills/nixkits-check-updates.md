# nixkits-check-updates (Skill)

[ 中文 [](../../] ｾﾞｯﾄｴｲﾁ / ｽｷﾙｽﾞ / [nixkits-check-updates] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [nixkits-check-updates] . md ) | [ [日本語] [](../../] ｼﾞｪｲｴｲ / ｽｷﾙｽﾞ / [nixkits-check-updates] . md )

> [Checks] ｵｰﾙ NixKits ﾊﾟｯｹｰｼﾞｰｽﾞ ｱﾝﾄﾞ ﾊﾟｯﾁｰｽﾞ ﾌｫｱ [upstream] [updates] , [applies] ﾊﾞｰｼﾞｮﾝ [bumps] ｱﾝﾄﾞ ﾄﾞｷｭ [sync] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾀｲﾌﾟ|ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ
ﾊﾟｽ|` ｽｷﾙｽﾞ / nixkits - ﾁｪｯｸ - updates / ｽｷﾙ . md `

## Features

- [Auto-discovers] ｵｰﾙ [external] ﾊﾟｯｹｰｼﾞｰｽﾞ ﾌﾛﾑ ` ﾌﾚｲｸ . ﾆｯｸｽ ` ｱﾝﾄﾞ [checks] [latest] GitHub [Releases]
- [Updates] ﾋﾞﾙﾄﾞ [configs] ( ﾊﾞｰｼﾞｮﾝ , ｿｰｽ ﾊｯｼｭ , [npmDepsHash] )
- [Syncs] ﾊﾞｰｼﾞｮﾝ [numbers] [across] ｵｰﾙ 3 ﾗﾝｹﾞｰｼﾞ ﾄﾞｷｭｽﾞ
- [Auto-invokes] ` [write-maintenance-log] ` ｽｷﾙ ﾄｩ ﾗｲﾄ ﾒﾝﾃﾅﾝｽ [records] ｱﾌﾀｰ [updates]
- [Reports] [locally] [installed] [versions]
- [Identifies] [hardcoded] [versions] [inside] ﾊﾟｯﾁ ﾌｧｲﾙｽﾞ ｱﾝﾄﾞ [provides] ﾁｪｯｸ [guidance]

## Hash Gotchas

- [SRI] ﾊｯｼｭ ﾏｽﾄ ﾕｰｽﾞ [standard] [base64] (`+` `/` `=`), ﾉｯﾄ [URL-safe] [variant] (` - ` ` _ `)
- ` [fetchFromGitHub] ` ｿｰｽ ﾊｯｼｭ ** [cannot] ** ﾋﾞｰ [precomputed] ﾌﾛﾑ ｻﾞ GitHub [archive] [tarball] — ﾏｽﾄ [come] ﾌﾛﾑ ` ﾆｯｸｽ ﾋﾞﾙﾄﾞ ` ﾊｯｼｭ [mismatch] ｴﾗｰ
- ﾕｰｽﾞ ` ﾘﾌﾞ . [fakeHash] ` ﾌｫｱ [empty] ` [npmDepsHash] `, ﾉｯﾄ ｻﾞ [empty] [string] `""`
- [npm] ﾊﾟｯｹｰｼﾞｰｽﾞ [need] [two] ` ﾆｯｸｽ ﾋﾞﾙﾄﾞ ` [passes] : ﾌｧｰｽﾄ ﾌｫｱ ｿｰｽ ﾊｯｼｭ , [second] ﾌｫｱ [npmDepsHash]

## Scope

[Reads] ` ﾌﾚｲｸ . ﾆｯｸｽ ` → ` ﾊﾟｯｹｰｼﾞｰｽﾞ `, [excluding] :
- [Self-hosted] ﾊﾟｯｹｰｼﾞｰｽﾞ ( ｿｰｽ ｲﾝ [repo] )
- ﾀﾞｲﾅﾐｯｸ ﾊﾞｰｼﾞｮﾝ [tracking] ( [fetches] [latest] ｱｯﾄ ﾋﾞﾙﾄﾞ [time] )
- [nixpkgs-following] ( ﾊﾟｯﾁ [overlays] )
- [Patch-embedded] [versions] ( [manual] ﾁｪｯｸ , e . g . ` [comfyui-strix-halo] `)

ｵｰﾙ [remaining] [external] ﾊﾟｯｹｰｼﾞｰｽﾞ ｱｰ [checked] [automatically] .

## Usage

[Activated] ｳｪﾝ ｻﾞ ﾕｰｻﾞｰ [asks] ﾄｩ " ﾁｪｯｸ ﾌｫｱ [updates] " ｵｱ " ｱｯﾌﾟﾃﾞｰﾄ ﾊﾟｯｹｰｼﾞ [versions] ".