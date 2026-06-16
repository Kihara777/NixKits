# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md)

> Write or update MAINTENANCE.md following NixKits conventions. Supports software update and bug fix record types.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/write-maintenance-log/SKILL.md` |

## Features

- Writes software update records (summary + commit ID table + version table)
- Writes bug fix records (summary + commit ID table)
- Trilingual sync (zh/en/ja) of maintenance logs
- Auto-extracts summary from preceding skill (nixkits-check-updates) or git commit message
- Unified format: ISO 8601 precise time, LIFO order, omit unchanged hashes

## Triggers

- **Auto**: after nixkits-check-updates completes
- **Manual**: "record this fix", "write to maintenance log", "update MAINTENANCE"

## Usage

Activated automatically after software updates, or on user request to record a fix.