# nix-flake-update-check (Skill)

[中文](../../zh/skills/nix-flake-update-check.md) | English | [日本語](../../ja/skills/nix-flake-update-check.md)  | [偽中国語](../../pcn/skills/nix-flake-update-check.md)

> Checks upstream package updates in **any nix flake repository** and upgrades them — per-builder hash flows, flake.lock handling, patch-embedded version checks, and nixpkgs drift traps.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nix-flake-update-check/SKILL.md` |
| Scope | **Generic** (bound to no specific repository) |
| Companion | Repo-specific steps come from an adapter-layer skill (NixKits uses `nixkits-check-updates`) |

## Features

- **Dynamically discovers** external packages from `flake.nix`, excluding self-hosted / dynamic-version / nixpkgs-following / patch-embedded ones
- Per-builder hash update flows (npm / cmake / Rust `buildRustPackage` / `fetchurl` / python)
- Hash gotchas: SRI format, `fetchFromGitHub` vs archive tarball mismatch, `lib.fakeHash`, npm's two build passes
- Rust packages must **sync `Cargo.lock`** (the most commonly missed step)
- Three-way `flake.lock` handling: already gitignored → skip; has dynamic versions → must exclude; otherwise → commit alongside hashes
- Identifying and updating versions hardcoded inside `.patch` files (version / url / hash)
- nixpkgs drift traps: `inputs.*.follows`, `doInstallCheck`, `pythonRuntimeDepsCheckHook`, bare `nix flake lock`

## Design: why two skills

This skill was formerly named `nixkits-check-updates` and was tightly coupled to the NixKits repository (hardcoded four-language doc paths, dsh plugin inventory, maintenance-log skill), which made it **unusable as-is** for other nix flake repositories.

After splitting into a "generic core + repo adapter layer":

- The generic method (this skill) can be reused directly by any nix flake repository
- NixKits' specific experience (incident lessons, doc conventions) stays in the adapter layer and **need not be diluted for portability**

## Adapter-layer contract

This skill covers the flow up to "record the change"; repo-specific steps come from an adapter. An adapter should document:

| Step | What the adapter must state |
|------|-----------------------------|
| Doc sync | Doc paths, language list, special sections to sync |
| Change record | The recording skill or file the repo uses |
| Dynamic version inputs | Whether the repo has an unlockable floating input |
| Known incident lessons | Past update-induced failures and their workarounds |
| Extra sync items | Built-in inventories, generated files, etc. |

When the two conflict, **the adapter layer wins**.

## Usage

Activated when the user asks to "check for updates" or "update package versions".
If the current repository has an adapter-layer skill, load the adapter first, then run this skill.
