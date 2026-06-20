# write-ﾒﾝﾃﾅﾝｽ-log (Skill)

[中文](../../zh/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [偽中国語](../../pcn/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md)

> Write ｵﾗ update MAINTENANCE.md ﾊﾟｰ NixKits conventions. Supports ｿﾌﾄｳｪｱ updates ｱﾝﾄﾞ ﾊﾞｸﾞ fixes, sync across ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages.

## Auto-Discovery Contract

Language extension ｽｷﾙs are discovered ﾌﾞｲｱ ｻﾞ `translate-*` naming convention: scan `ｽｷﾙs/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them as ｱﾌﾞｴｲﾗﾌﾞﾙ languages ｲﾝ ｻﾞ multi-language sync pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Writes ｿﾌﾄｳｪｱ update records (summary + commit ID table + ﾊﾞｰｼﾞｮﾝ table)
- Writes ﾊﾞｸﾞ ﾌｨｯｸｽ records (summary + commit ID table)
- Sync across ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages (ｵｰﾄ-discovered ﾌﾞｲｱ translate-* ｽｷﾙs)
- Auto-extracts summary ﾌﾛﾑ preceding ｽｷﾙ (nixkits-ﾁｪｯｸ-updates) ｵﾗ git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: ｵｰﾄ-called after ｿﾌﾄｳｪｱ updates, ｵﾗ ｵﾝ "record ﾃﾞｨｽ ﾌｨｯｸｽ" / "记入维护记录"
- **Update Log**: ｵﾝ "update ﾒﾝﾃﾅﾝｽ log" / "补全维护记录" — scans git history ﾌｫｱ missing records ｱﾝﾄﾞ backfills

## ﾕｰｾｰｼﾞ

Activated automatically after ｿﾌﾄｳｪｱ updates, ｵﾗ ｵﾝ ﾕｰｻﾞｰ request ﾄｩ record a ﾌｨｯｸｽ.
