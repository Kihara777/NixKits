# nix-flake-update-check (Skill)

[中文](../../zh/skills/nix-flake-update-check.md) | English | [日本語](../../ja/skills/nix-flake-update-check.md)  | [偽中国語](../../pcn/skills/nix-flake-update-check.md)

> Checks upstream package updates in **any nix flake repository** and upgrades them — per-builder hash flows, an interactive clarification round before starting, chained parallel checks of same-account subprojects, GitHub Actions SHA-pin update checks, flake.lock handling, patch-embedded version checks, and nixpkgs drift traps.

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
- **GitHub Actions update checking**: self-implemented (`gh api` to resolve tags → take the commit SHA → write it back and sync the version comment), covering the blind spot that appears once actions are pinned to SHAs; **no reliance on external automation such as Dependabot**
- Hash gotchas: SRI format, `fetchFromGitHub` vs archive tarball mismatch, `lib.fakeHash`, npm's two build passes
- Rust packages must **sync `Cargo.lock`** (the most commonly missed step)
- Three-way `flake.lock` handling: already gitignored → skip; has dynamic versions → must exclude; otherwise → commit alongside hashes
- Identifying and updating versions hardcoded inside `.patch` files (version / url / hash)
- **Chained checks for same-account subprojects**: discover same-account sub-repos this repo references (thin wrapper / input / submodule), first verify no cycle, no dependency conflict, and independent upgradability, then run them chained and in parallel; subproject results count as the main repo's results, each is recorded in its own repository's log, and the main repo links to the subproject's entry
  - **The follow-up criterion is field-level**: when a sub-repo's `rev` differs from the pinned value you must not simply upgrade — judge whether the change lands on a **build input**. Release metadata (`publishConfig` / `repository` / `keywords`) and docs are not semantic inputs, so **do not follow up**; `dependencies` / `files` / `main` / `exports` / `version` are semantic inputs, so you **must follow up**. When unsure, treat it as "follow up"
- **Handling external-automation PRs**: their npm update PRs always fail because they cannot know `npmDepsHash`; check the branch out, patch the hash, then merge
- **Interactive clarification**: settle every open decision in one batched round of questions before starting (cross-major upgrades, dependency-conflict remedies, channel choice, whether to deploy), avoiding the "guess → get corrected → redo" loop; agents without interactive questions should emit the open list once and stop
- nixpkgs drift traps: `inputs.*.follows`, `doInstallCheck`, `pythonRuntimeDepsCheckHook`, bare `nix flake lock`
- **Fail-closed runtime dependency verification**: upstream compares exact versions at startup, so a successful build is not a working binary — always run it once to verify

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
| Subproject list | Which same-account sub-repos this repo references, their build systems, and the sub-repo log's path and language conventions |

When the two conflict, **the adapter layer wins**.

## Usage

Activated when the user asks to "check for updates" or "update package versions".
If the current repository has an adapter-layer skill, load the adapter first, then run this skill.
