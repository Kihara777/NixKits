# nix-flake-update-check (Skill)

[中文](../../zh/skills/nix-flake-update-check.md) | English | [日本語](../../ja/skills/nix-flake-update-check.md)  | [偽中国語](../../pcn/skills/nix-flake-update-check.md)

> Checks upstream package updates in **any nix flake repository** and upgrades them — per-builder hash flows, an interactive clarification round before starting, chained parallel checks of same-account subprojects, rewriting (not mechanically substituting) docs when version semantics change, dead-link audits of documented external links, GitHub Actions SHA-pin update checks, flake.lock handling, patch-embedded version checks, and nixpkgs drift traps.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nix-flake-update-check/` (`SKILL.md` + `builders.md` + `traps.md`) |
| Scope | **Generic** (bound to no specific repository) |
| Companion | Repo-specific steps come from an adapter-layer skill (NixKits uses `nixkits-check-updates`) |

## Features

- **Dynamically discovers** external packages from `flake.nix`, excluding self-hosted / dynamic-version / nixpkgs-following / patch-embedded ones
- Per-builder hash update flows (npm / cmake / Rust `buildRustPackage` / `fetchurl` / python)
- **GitHub Actions update checking**: self-implemented (`gh api` to resolve tags → take the commit SHA → write it back and sync the version comment), covering the blind spot that appears once actions are pinned to SHAs; **no reliance on external automation**, so anyone with read access can run it (a maintainer's routine check, a contributor verifying before a CI-related PR, or someone assessing the cost of taking over). The commands are read-only, and **finding ≠ being obliged to upgrade** — without write access, or when it is unrelated to the task at hand, just report it; upgrades go through a PR
- **Dead-link audit for documented external links**: extract every external link (including all languages) and probe each; a `404` is only confirmed after re-checking with `gh api` (a `curl` 404 can be permissions or rate limiting), and `403` is usually anti-scraping rather than a dead link; when fixing, **update the display text too** across every language, and never rewrite vendored third-party content
- **Triggers for rewriting docs instead of mechanically substituting**: dependencies moving from ranges to exact pins, new startup/build-time hard checks, added or removed dependencies, changed build method, narrowed platform requirements — hitting any one means a human must read the docs; it governs "when to rewrite" and explicitly disclaims "how to write"
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

## Structure: main flow + two companion references

A single file had grown to 918 lines, making it hard to find things while executing. It is now split per the "extract standalone data into companion files" rule:

| File | Contents | When to read |
|------|----------|--------------|
| `SKILL.md` | Interactive clarification + steps 1–9 + adapter contract | Always |
| `builders.md` | Per-builder hash flows, `flake.lock` handling | Step 4 |
| `traps.md` | nixpkgs drift traps, fail-closed checks, dead-link audit, Actions updates, patch-embedded versions | When a step-7 self-check hits |

**Step 7 gained a "six questions before committing" self-check**: multiple variants? dependency table consistent? source fetch still valid? actually ran it? doc wording still true? should `flake.lock` be committed? — all six distilled from incidents measured the same day; a hit leads into `traps.md` instead of reading the whole file.

**The closing step 10 is supplied by the adapter** (this skill itself ends at step 9): a process retrospective plus spec audit, defined by the adapter skill (for NixKits, see the "step 10 (closing)" section of `nixkits-check-updates`). It specifically requires that **generic lessons produced on a test branch be carried back into main immediately** — those branches are never merged by agreement, and the lessons must not be stranded with them.
