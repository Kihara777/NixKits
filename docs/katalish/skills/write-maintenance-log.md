# write-ﾒﾝﾃﾅﾝｽ-log (Skill)

[中文](../../zh/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | ｶﾀﾘｯｼｭ | [日本語](../../ja/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md) | [偽中国語](../../pcn/ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log.md)

> Write or update MAINTENANCE.md per NixKits conventions. Supports ｿﾌﾄｳｪｱ updates and bug fixes, sync across all available languages.

## Auto-Discovery Contract

Language extension ｽｷﾙs are discovered via the `translate-*` naming convention: scan `ｽｷﾙs/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), and register them as available languages in the multi-language sync pipeline.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `ｽｷﾙs/write-ﾒﾝﾃﾅﾝｽ-log/SKILL.md` |

## ﾌｨｰﾁｬｰｽﾞ

- Writes ｿﾌﾄｳｪｱ update records (summary + commit ID table + ﾊﾞｰｼﾞｮﾝ table)
- Writes bug fix records (summary + commit ID table)
- Sync across all available languages (auto-discovered via translate-* ｽｷﾙs)
- Auto-extracts summary from preceding ｽｷﾙ (nixkits-ﾁｪｯｸ-updates) or git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: auto-called after ｿﾌﾄｳｪｱ updates, or on "record this fix" / "记入维护记录"
- **Update Log**: on "update ﾒﾝﾃﾅﾝｽ log" / "补全维护记录" — scans git history for missing records and backfills

## ﾕｰｾｰｼﾞ

Activated automatically after ｿﾌﾄｳｪｱ updates, or on user request to record a fix.
