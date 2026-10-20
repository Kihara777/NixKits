# agent-self-maintenance (Skill)

[中文](../../zh/skills/agent-self-maintenance.md) | English | [日本語](../../ja/skills/agent-self-maintenance.md)  | [偽中国語](../../pcn/skills/agent-self-maintenance.md)

> Five small mechanisms that can fail, so an AI coding assistant keeps maintaining its own memory.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/agent-self-maintenance/SKILL.md` |
| Applies to | Any repository with a `journal/` and a self-check script |

## The five mechanisms

| Mechanism | Criterion | Boundary |
|---|---|---|
| Journal gate | A commit happened but today's journal entry was not touched → remind once | Silent when not configured |
| Journal catchup | Reads receipt / journal / facts; ok / red / stale never merged | "Never ran" must be said |
| Facts check | Every fact carries a probe; `unverifiable` is a third state | Data stays in the repository |
| Self-observation | What she said / what I measured / uncertain, recorded separately | Entries carry dates and evidence |
| Selfcheck receipt | Five states, only `ok` is quiet | The receipt is not committed |

## Data ownership

Mechanisms travel, **data does not**: fact entries, observation entries and thresholds belong to each repository.

## Reference implementation

The lampkeeper preset in dsh (`presets/lampkeeper/`) is a complete implementation of these five mechanisms.
