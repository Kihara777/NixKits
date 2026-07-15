# nixkits-skills (Skill)

[中文](../../zh/skills/nixkits-skills.md) | English | [日本語](../../ja/skills/nixkits-skills.md)  | [偽中国語](../../pcn/skills/nixkits-skills.md)

> Installs or updates NixKits skills into coding agent directories (opencode, codewhale, codex, openclaw, agents).

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-skills/SKILL.md` |

## Features

- Auto-discovers source directory and git remote URL
- Detects installed coding agent skill directories
- Compares local skills against NixKits source for differences
- Supports local install (from source) and online install (from GitHub clone)
- Shows diff before applying and asks for user confirmation
- Verifies copy consistency after install

## Supported Agents

| Agent | Directory |
|-------|-----------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Codex | `~/.codex/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| Generic | `~/.agents/skills/` |

## Usage

Activated when the user asks to "install skills" or "update NixKits skills".

## Risk Advisory

**Claude Code** was removed in 2026-07 for the following reason:

> While Claude Code, as a company, has the right to KYC and to choose which users and regions to serve, the act of embedding business logic that infers user nationality from data mining—regardless of purpose or justification—has severely crossed the security model boundary and broken fundamental user trust.
>
> For this reason, this repository strongly advises any user of that software to reassess its necessity and consider migrating their workflow where possible. This repository fully respects the diversity of user needs and individual choice, but has an obligation to inform users of this risk. Should any anomaly or loss occur to your Anthropic account as a result of using this repository's content, you acknowledge that this event is unrelated to this repository.
