# nix-packaging (Skill)

[中文](../../zh/skills/nix-packaging.md) | English | [日本語](../../ja/skills/nix-packaging.md)  | [偽中国語](../../pcn/skills/nix-packaging.md)

> Package an upstream piece of software as a Nix expression from scratch.

## Info

| Item | Value |
|------|-------|
| Type | Coding Agent Skill |
| Path | `skills/nix-packaging/SKILL.md` |
| Applies to | The first step when "this software has no package yet" |

## Four-layer acceptance

| Layer | Criterion | The trap |
|---|---|---|
| Evaluate | `nix eval` yields the expected version | evaluating ≠ building |
| Build | the log shows `building`, not all-cache | a cache hit means nothing was built |
| Artifact | `$out/bin` is non-empty | empty bin = a wasted build |
| Run | `--help` exits 0 | a node package without a wrapper only fails here |

## Covers

- Routing by source type (GitHub source / npm / Rust / prebuilt binaries / Gitea / PyPI)
- The two-stage hash ( `lib.fakeHash` → read `got:` → backfill → **build again to accept** )
- Generating a vendored lock (npm; `--legacy-peer-deps` is the trap)
- When a wrapper is needed
- This repository's conventions (`__structuredAttrs` conflicts with cross-compilation) and six measured traps

## Does not cover

- Version bumps of existing packages → `nix-flake-update-check`
- Submitting upstream → `upstream-audit`
