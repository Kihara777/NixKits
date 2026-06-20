# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | English | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> Write or update MAINTENANCE.md per NixKits conventions. Supports software updates and bug fixes, sync across all available languages.

## Auto-Discovery Contract

Language extension skills are discovered via the `translate-*` naming convention: scan `skills/translate-*/`, read each SKILL.md's frontmatter fields (`language_code` / `display_name` / `base_language`), and register them as available languages in the multi-language sync pipeline.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/write-maintenance-log/SKILL.md` |

## Features

- Writes software update records (summary + commit ID table + version table)
- Writes bug fix records (summary + commit ID table)
- Sync across all available languages (auto-discovered via translate-* skills)
- Auto-extracts summary from preceding skill (nixkits-check-updates) or git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: auto-called after software updates, or on "record this fix" / "记入维护记录"
- **Update Log**: on "update maintenance log" / "补全维护记录" — scans git history for missing records and backfills

## Usage

Activated automatically after software updates, or on user request to record a fix.