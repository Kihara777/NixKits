# Maintenance Log

This file records changes on the `impure` branch. The rules match `main`: the same number
of entries in all four languages, second-precision timestamps, globally unique commit
SHAs, and list-style summaries.

> **The SHAs here are this branch's own** — they are a different set from `main`'s.

## 2026-10-22T14:05:07+09:00

**Summary**: add AGENTS, SECURITY, four-language README and the maintenance log

- New `AGENTS.md` (branch-specific rules only) and `SECURITY.md` (the non-reproducibility risk and its mitigations)
- Language switcher added to `README.md`; `docs/README.{en,ja,pcn}.md` added
- The branch's maintenance log is created (recording 9c50e5e and 0f15570)

| Commit | Description |
|------|------|
| `3c5da27` | docs(impure): add AGENTS / SECURITY / four-language README and the maintenance log |

## 2026-10-22T06:18:45+09:00

**Summary**: the four-language llama-cpp-rocm docs move here together with the component

- `docs/{zh,en,ja,pcn}/llama-cpp-rocm.md` moved from `main` to this branch
- `main` keeps no copy, so the two can never drift

| Commit | Description |
|------|------|
| `0f15570` | docs(impure): the four-language llama-cpp-rocm docs move here with the component |

## 2026-10-21T23:53:50+09:00

**Summary**: the from-scratch impure channel is created

- orphan branch (no shared history with `main`), containing only `llama-cpp-rocm`
- `llama-cpp-ver` is a floating URL input; `nixpkgs` follows `nixos-unstable`
- `.gitignore` pins `flake.lock` — this branch deliberately does not lock

| Commit | Description |
|------|------|
| `9c50e5e` | feat(impure): a from-scratch impure channel — llama-cpp-rocm only |
