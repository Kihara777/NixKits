# Maintenance Log

[中文](../MAINTENANCE.md) | English | [日本語](MAINTENANCE.ja.md) | [偽中国語](MAINTENANCE.pcn.md)

This file records changes on the `impure` branch. The rules match `main`: the same number
of entries in all four languages, second-precision timestamps, globally unique commit
SHAs, and list-style summaries.

> **The SHAs here are this branch's own** — they are a different set from `main`'s.

## 2026-10-22T15:59:01+09:00

**Summary**: document the pitfall that `nix flake metadata` fails without a lock

- `AGENTS.md` gains hard rule 4: add `--no-write-lock-file` when evaluating
- Includes the command that was actually verified (`llama-cpp-0.7.0`) and a note that downstream usage is unaffected

| Commit | Description |
|------|------|
| `43f6f44` | docs(impure): document the no-lock `nix flake metadata` failure |

## 2026-10-22T14:32:43+09:00

**Summary**: four-language security policy, and language switchers on the maintenance log

- `SECURITY.md` gains a switcher; `docs/SECURITY.{en,ja,pcn}.md` added
- Each of the four `MAINTENANCE.*` files gains a switcher (entries unchanged)

| Commit | Description |
|------|------|
| `4cb0059` | docs(impure): four-language security policy and maintenance-log switchers |

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
