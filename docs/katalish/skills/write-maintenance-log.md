# write-maintenance-log (Skill)

[ 中文 [](../../] ｾﾞｯﾄｴｲﾁ / ｽｷﾙｽﾞ / [write-maintenance-log] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [write-maintenance-log] . md ) | [ [日本語] [](../../] ｼﾞｪｲｴｲ / ｽｷﾙｽﾞ / [write-maintenance-log] . md )

> ﾗｲﾄ ｵｱ ｱｯﾌﾟﾃﾞｰﾄ ﾒﾝﾃﾅﾝｽ . md [following] NixKits [conventions] . [Supports] ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ ｱﾝﾄﾞ ﾊﾞｸﾞ ﾌｨｯｸｽ [record] [types] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾀｲﾌﾟ|ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ
ﾊﾟｽ|` ｽｷﾙｽﾞ / ﾗｲﾄ - ﾒﾝﾃﾅﾝｽ - ﾛｸﾞ / ｽｷﾙ . md `

## Features

- [Writes] ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ [records] ( ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ + ﾊﾞｰｼﾞｮﾝ ﾃｰﾌﾞﾙ )
- [Writes] ﾊﾞｸﾞ ﾌｨｯｸｽ [records] ( ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ )
- [Trilingual] [sync] ( ｾﾞｯﾄｴｲﾁ / ｴﾇ / ｼﾞｪｲｴｲ ) ｵﾌﾞ ﾒﾝﾃﾅﾝｽ [logs]
- [Auto-extracts] ｻﾏﾘｰ ﾌﾛﾑ [preceding] ｽｷﾙ ( [nixkits-check-updates] ) ｵｱ [git] ｺﾐｯﾄ [message]
- [Unified] ﾌｫｰﾏｯﾄ : [ISO] 8601 [precise] [time] , [LIFO] [order] , [omit] [unchanged] [hashes]

## Entry Points

- ** [Record] ﾌｨｯｸｽ [**:] [auto-called] ｱﾌﾀｰ ｿﾌﾄｳｪｱ [updates] , ｵｱ ｵﾝ " [record] ﾃﾞｨｽ ﾌｨｯｸｽ " / " [记入维护记录] "
- ** ｱｯﾌﾟﾃﾞｰﾄ ﾛｸﾞ [**:] ｵﾝ " ｱｯﾌﾟﾃﾞｰﾄ ﾒﾝﾃﾅﾝｽ ﾛｸﾞ " / " [补全维护记录] " — [scans] [git] [history] ﾌｫｱ [missing] [records] ｱﾝﾄﾞ [backfills]

## Usage

[Activated] [automatically] ｱﾌﾀｰ ｿﾌﾄｳｪｱ [updates] , ｵｱ ｵﾝ ﾕｰｻﾞｰ [request] ﾄｩ [record] ｱ ﾌｨｯｸｽ .