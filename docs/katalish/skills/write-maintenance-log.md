# write-ﾒﾝﾃﾅﾝｽ-log (Skill)

[中文](../../zh/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [偽中国語](../../pcn/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md)

> Write ｵﾗ ｱｯﾌﾟﾃﾞｰﾄ MAINTENANCE.md ﾊﾟｰ NixKits conventions. Supports ｿﾌﾄｳｪｱ updates ｱﾝﾄﾞ ﾊﾞｸﾞ fixes, sync ｱｸﾛｽ ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages.

## Auto-Discovery Contract

Language ｴｸｽﾃﾝｼｮﾝ ｽｷﾙs ｱｰ discovered ﾌﾞｲｱ ｻﾞ `translate-*` naming ｺﾝﾌﾞｴﾝｼｮﾝ: scan `ｽｷﾙs/translate-*/`, read ｲｰﾁ SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register ｾﾞﾑ ｱｽﾞ ｱﾌﾞｴｲﾗﾌﾞﾙ languages ｲﾝ ｻﾞ multi-ﾗﾝｹﾞｰｼﾞ sync pipeline.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾀｲﾌﾟ | Coding Agent Skill |
| Path | `ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Writes ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄ records (summary + commit ID table + ﾊﾞｰｼﾞｮﾝ table)
- Writes ﾊﾞｸﾞ ﾌｨｯｸｽ records (summary + commit ID table)
- Sync ｱｸﾛｽ ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages (ｵｰﾄ-discovered ﾌﾞｲｱ translate-* ｽｷﾙs)
- Auto-extracts summary ﾌﾛﾑ preceding ｽｷﾙ (nixkits-ﾁｪｯｸ-updates) ｵﾗ git commit message
- Unified format: ISO 8601 precise time, LIFO ｵﾗﾄﾞｴﾗ, omit unchanged hashes

## Entry Points

- **Record Fix**: ｵｰﾄ-called ｱﾌﾀｰ ｿﾌﾄｳｪｱ updates, ｵﾗ ｵﾝ "record ﾃﾞｨｽ ﾌｨｯｸｽ" / "记入维护记录"
- **Update Log**: ｵﾝ "ｱｯﾌﾟﾃﾞｰﾄ ﾒﾝﾃﾅﾝｽ log" / "补全维护记录" — scans git history ﾌｫｱ missing records ｱﾝﾄﾞ backfills

## ﾕｰｾｰｼﾞ

Activated ｵｰﾄﾏﾃｨｯｸﾘｰ ｱﾌﾀｰ ｿﾌﾄｳｪｱ updates, ｵﾗ ｵﾝ ﾕｰｻﾞｰ request ﾄｩ record ｱ ﾌｨｯｸｽ.
