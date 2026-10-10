# nixkits-package-upstream (Skill)

[中文](../../zh/skills/nixkits-package-upstream.md) | English | [日本語](../../ja/skills/nixkits-package-upstream.md)  | [偽中国語](../../pcn/skills/nixkits-package-upstream.md)

> The NixKits adaptation layer for upstreaming to nixpkgs: the feasibility ledger for 13 packages, establishing a licence basis, four-language synchronisation, and registering self-checks.

## Basic information

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-package-upstream/SKILL.md` |
| Dependencies | [`nixpkgs-package-upstream`](nixpkgs-package-upstream.md) (the general method) |

## Features

- **Feasibility ledger**: the current state of all 13 packages, each with "can it be submitted, and why" (evidence baseline: nixpkgs master `78f093ad1`)
- **The three most common missteps**: `mcp-searxng` is already in nixpkgs, `dsh` is called
  `deepseek-harness` there and already has 3 in-flight PRs, and `kitsfmt`'s upstream repository 404s
- **Correcting a stale self-description**: this repository once wrote that "nixpkgs no longer
  provides the ruyi package", when in fact it never did
- **Licence basis**: look first for SPDX headers in the sources and licence fields in manifest files **inside the artefact we fetch**; "there is no LICENSE file" does not mean "there is no licence"
- **Dry-run location**: `upstream/<package>/`, not `/tmp`
- **Registering and synchronising**: the four-language README index, the four-language skill
  documentation pages (including the language switcher), the maintenance log, and the self-check count

## Usage

Activated by an AI assistant when performing upstream contributions inside the NixKits
repository, and read **after** the general skill.

The remaining repository-specific steps (never committing `flake.lock`, running
`git fetch origin` to align with the remote, committing cross-language files as one group,
and keeping non-Japanese glyphs out of pcn) follow `AGENTS.md` and the existing skills.
