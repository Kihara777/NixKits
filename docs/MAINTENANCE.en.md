# Maintenance Log

This file records changes on the `impure` branch. The rules match `main`: the same number
of entries in all four languages, second-precision timestamps, globally unique commit
SHAs, and list-style summaries.

> **The SHAs here are this branch's own** — they are a different set from `main`'s.

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
