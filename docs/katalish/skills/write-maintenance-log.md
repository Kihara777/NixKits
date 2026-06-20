# ﾗｲﾄ-maintenance-log (ｽｷﾙ)

[中文](../../zh/skills/write-maintenance-log.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> Write or update MAINTENANCE.md per NixKits conventions. Supports software updates and bug fixes, sync across all available languages.

## ｵｰﾄ-ﾃﾞｨｽｶﾊﾞﾘｰ ｺﾝﾄﾗｸﾄ

ﾗﾝｹﾞｰｼﾞ ｴｸｽﾃﾝｼｮﾝ ｽｷﾙｽﾞ ｱｰ ﾃﾞｨｽｶﾊﾞｰﾄﾞ via ｻﾞ `translate-*` naming convention: scan `skills/translate-*/`, ﾘｰﾄﾞ ｲｰﾁ ｽｷﾙ.md's ﾌﾛﾝﾄﾏﾀｰ fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them ｱｽﾞ available ﾗﾝｹﾞｰｼﾞｽﾞ ｲﾝ ｻﾞ multi-ﾗﾝｹﾞｰｼﾞ sync pipeline.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ |
| ﾊﾟｽ | `skills/write-maintenance-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- ﾗｲﾄｽﾞ ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ records (ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ + ﾊﾞｰｼﾞｮﾝ ﾃｰﾌﾞﾙ)
- ﾗｲﾄｽﾞ bug fix records (ｻﾏﾘｰ + ｺﾐｯﾄ ID ﾃｰﾌﾞﾙ)
- Sync across ｵｰﾙ available ﾗﾝｹﾞｰｼﾞｽﾞ (ｵｰﾄ-ﾃﾞｨｽｶﾊﾞｰﾄﾞ via translate-* ｽｷﾙｽﾞ)
- ｵｰﾄ-extracts ｻﾏﾘｰ ﾌﾛﾑ preceding ｽｷﾙ (nixkits-check-updates) ｵｱ git ｺﾐｯﾄ message
- Unified ﾌｫｰﾏｯﾄ: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: ｵｰﾄ-called after ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ, ｵｱ ｵﾝ "record ﾃﾞｨｽ fix" / "记入维护记录"
- **ｱｯﾌﾟﾃﾞｰﾄ Log**: ｵﾝ "ｱｯﾌﾟﾃﾞｰﾄ maintenance log" / "补全维护记录" — scans git history ﾌｫｱ missing records ｱﾝﾄﾞ backfills

## ﾕｰｾｰｼﾞ

Activated automatically after ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ, ｵｱ ｵﾝ ﾕｰｻﾞｰ request ﾄｩ record ｱ fix.