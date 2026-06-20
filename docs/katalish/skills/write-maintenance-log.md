# write-maintenance-log (ｽｷﾙ)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](write-maintenance-log.md) | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> ﾗｲﾄ ｵｱ ｱｯﾌﾟﾃﾞｰﾄ ﾒﾝﾃﾅﾝｽ.md ﾌｫﾛｰｲﾝｸﾞ NixKits conventions. Supports ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ ｱﾝﾄﾞ ﾊﾞｸﾞ ﾌｨｯｸｽ record ﾀｲﾌﾟｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/write-maintenance-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Writes ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ records (ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ + ﾊﾞｰｼﾞｮﾝ ﾃｰﾌﾞﾙ)
- Writes ﾊﾞｸﾞ ﾌｨｯｸｽ records (ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ)
- Trilingual sync (zh/en/ja) ｵﾌﾞ ﾒﾝﾃﾅﾝｽ logs
- Auto-extracts ｻﾏﾘｰ ﾌﾛﾑ preceding ｽｷﾙ (nixkits-check-updates) ｵｱ git ｺﾐｯﾄ message
- Unified ﾌｫｰﾏｯﾄ: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record ﾌｨｯｸｽ**: auto-called ｱﾌﾀｰ ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ, ｵｱ ｵﾝ "record ﾃﾞｨｽ ﾌｨｯｸｽ" / "记入维护记录"
- **ｱｯﾌﾟﾃﾞｰﾄ ﾛｸﾞ**: ｵﾝ "ｱｯﾌﾟﾃﾞｰﾄ ﾒﾝﾃﾅﾝｽ ﾛｸﾞ" / "补全维护记录" — scans git history ﾌｫｱ missing records ｱﾝﾄﾞ backfills

## ﾕｰｾｰｼﾞ

Activated automatically ｱﾌﾀｰ ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ, ｵｱ ｵﾝ ﾕｰｻﾞｰ request ﾄｩ record ｱ ﾌｨｯｸｽ.