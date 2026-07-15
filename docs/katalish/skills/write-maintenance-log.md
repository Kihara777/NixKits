# write-ﾒﾝﾃﾅﾝｽ-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> Write ｵﾗ update MAINTENANCE.md ﾊﾟｰ NixKits conventions. Supports ｿﾌﾄｳｪｱ updates ｱﾝﾄﾞ bug fixes, sync across ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages.

## Auto-Discovery Contract

Language extension skills ｱｰ discovered via ｻﾞ `translate-*` naming convention: scan `skills/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), ｱﾝﾄﾞ register them as ｱﾌﾞｴｲﾗﾌﾞﾙ languages in ｻﾞ multi-ﾗﾝｹﾞｰｼﾞ sync pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/write-ﾒﾝﾃﾅﾝｽ-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Writes ｿﾌﾄｳｪｱ update records (summary + commit ID table + ﾊﾞｰｼﾞｮﾝ table)
- Writes bug fix records (summary + commit ID table)
- Sync across ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ languages (auto-discovered via translate-* skills)
- Auto-extracts summary ﾌﾛﾑ preceding skill (nixkits-check-updates) ｵﾗ git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: auto-called after ｿﾌﾄｳｪｱ updates, ｵﾗ on "record fix"
- **Update Log**: on "update maintenance log" — scans git history ﾌｫｱ missing records ｱﾝﾄﾞ backfills

## ﾕｰｾｰｼﾞ

Activated ｵｰﾄﾏﾃｨｯｸﾘｰ after ｿﾌﾄｳｪｱ updates, ｵﾗ on user request to record ｱ fix.