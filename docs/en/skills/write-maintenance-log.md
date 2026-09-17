# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | English | [日本語](../../ja/skills/write-maintenance-log.md)  | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> Write or update MAINTENANCE.md per NixKits conventions. Supports software updates, bug fixes, skill/doc changes, CI/CD changes and cross-repository subproject chained updates; syncs across all available languages.

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
- **Writes cross-repository chained-update records**: the main repo's entry records only the thin-wrapper coordinate change (`rev` / hash) and **links to the corresponding entry section in the sub-repo**; the sub-repo's entry records its own full version change — the two differ and are not duplicates
  - Anchor derivation: ISO 8601 timestamp **lowercased → every character except `-` `_` replaced with `-`** (so `:` and `+` each become one `-`, existing `-` are kept)
- Sync across all available languages (auto-discovered via translate-* skills)
- Auto-extracts summary from preceding skill (update check; nixkits-check-updates for NixKits) or git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Entry Points

- **Record Fix**: auto-called after software updates, or on "record this fix" / "记入维护记录"
- **Update Log**: on "update maintenance log" / "补全维护记录" — scans git history for missing records and backfills

## Usage

Activated automatically after software updates, or on user request to record a fix.