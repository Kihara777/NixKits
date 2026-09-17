# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | English | [日本語](../../ja/skills/nixkits-check-updates.md)  | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> The **package-update adapter layer** for the NixKits repository — on top of the generic `nix-flake-update-check` skill, it adds this repo's four-language doc sync, dsh built-in plugin inventory sync, same-account sub-repo chained-check coordinates, maintenance-log recording, and historical incident lessons.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nixkits-check-updates/SKILL.md` |
| Depends on | `nix-flake-update-check` (generic flow, load first) |

## Structure: generic core + repo adapter layer

Update checking is split into two skills with separated responsibilities:

| Skill | Responsibility | Portability |
|-------|----------------|-------------|
| `nix-flake-update-check` | Generic method: package discovery, per-builder hash flows, same-account subproject chained parallel checks, flake.lock handling, patch-embedded version checks, nixpkgs drift traps | Any nix flake repository |
| `nixkits-check-updates` | Repo adaptation: four-language docs, plugin inventory, sub-repo coordinates, maintenance log, historical incident lessons | NixKits only |

This split lets the generic method be reused directly by other nix flake repositories, while NixKits' specific experience (incident lessons, doc conventions) need not be diluted for portability's sake. When the two conflict, **the adapter layer wins**.

## Repo-specific steps

- **Four-language doc sync**: `docs/<lang>/<pkg>.md` (zh baseline + en/ja/pcn), zh written first then translated
- **dsh plugin inventory sync**: when upgrading `dsh`, sync the built-in `cordis.patch.yml` entry-id inventory
- **Maintenance log**: invokes the `write-maintenance-log` skill, synced across four languages
- **Same-account sub-repo chained check**: the `dsh-api-balance` thin wrapper references the sub-repo `Kihara777/dsh-api-balance`, whose own version changes must also be checked (coordinates below)
- **`llama-cpp-ver` floating input**: cannot be locked, so `flake.lock` is not committed
- **Generalisation duty**: when a generic improvement is found, update it back into `nix-flake-update-check`

## Sub-repo reference: dsh-api-balance

The generic method for chained checks (cycles, depth limit, dependency-conflict criteria)
is in `nix-flake-update-check` step 9; only the adapter knows this repo's concrete coordinates:

| Item | Value |
|---|---|
| Sub-repo | `Kihara777/dsh-api-balance` |
| Reference form | `fetchFromGitHub` pinned `rev` (**not** a flake input) |
| Sub-repo build system | plain JS npm package (`package.json`, no build script) |
| Chain length | 1 level (the sub-repo has no further same-account parent) |
| Distribution | **not published to npm** (the maintainer is visually impaired and cannot complete 2FA) |

Key points:

- The sub-repo is **not a nix flake** — do not run `nix flake check` or flake.lock handling against it
- Changing `rev` changes **both the `src` hash and `npmDepsHash`**, so two `nix build` passes are needed
- The sub-repo's `@deepseek-ai/dsh-*` deps are **peer-like**: a version lower than the host's is normal, and the criterion is whether the sub-repo requires a version **higher** than the host provides, not whether the two are equal
- Since extraction the sub-repo has received **docs-only** commits with no version change, which by the criterion does **not** trigger re-pinning the thin wrapper
## Scope

Reads `flake.nix` dynamically, excluding:

- Self-hosted packages (source in repo)
- Dynamic version tracking (fetches latest at build time)
- nixpkgs-following (patch overlays)
- Patch-embedded versions (manual check)

All remaining external packages are checked automatically.

## Hash Gotchas

Full rules live in `nix-flake-update-check`; the essentials:

- SRI hash must use standard base64 (`+` `/` `=`), not URL-safe variant (`-` `_`)
- `fetchFromGitHub` source hash **cannot** be precomputed from the GitHub archive tarball — must come from `nix build` hash mismatch error
- Use `lib.fakeHash` for empty `npmDepsHash`, not the empty string `""`
- npm packages need two `nix build` passes: first for source hash, second for npmDepsHash

## Usage

Activated when the user asks to "check for updates" or "update package versions".
Maintenance mode (`maintenance`) already injects this skill and `nix-flake-update-check`.
