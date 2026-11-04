# bili-agent

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-x86_64.yml?branch=main&label=x86_64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-aarch64.yml?branch=main&label=aarch64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/bili-agent.md) | English | [日本語](../ja/bili-agent.md)  | [偽中国語](../pcn/bili-agent.md)

A Bilibili command-line tool designed for AI agents: every command prints **exactly one JSON
object** to stdout, needs no interaction, and guards account actions with rate limits, an audit
log and a DM allowlist. The command is `bili`.

## Basic information

| Item | Value |
|------|-------|
| Version | 1.3.0 |
| Upstream | [kukemc/bili-cli](https://github.com/kukemc/bili-cli) |
| Type | Python application (hatchling) |
| License | MIT |
| Platforms | x86_64 / aarch64 |
| Command | `bili` |

## Why this repository also ships a library

The upstream pins `bilibili-api-python==17.4.2`, and **nixpkgs does not have that library**
(checked package by package on 2026-11-04). So this repository also packages
`packages/bilibili-api-python.nix`: all 12 runtime dependencies come from nixpkgs, and the build
additionally needs `setuptools-scm` — putting it in the wrong layer fails the build with
`Unmet dependencies … setuptools-scm`.

Substituting a newer version from nixpkgs is **not an option**: `==` is a hard constraint, and
skipping the check surfaces as a runtime behaviour mismatch (the sibling package `blender-mcp`
was bitten by exactly this with `mcp<2`).

## Usage

```bash
bili auth status          # check the login state first
bili feed inbox           # what is new in this round
bili video watch <BV>     # info + AI summary + transcript + top comments + danmaku peaks + contact sheet
bili schema               # machine-readable description of every command
```

Write operations all support `--dry-run`. The full command table lives in the `bili-cli` skill
(inside lampkeeper mode) or in the upstream `skills/bili-cli/SKILL.md`.

## Login

One-time QR scan: `bili auth login` returns a `qr_image` (local PNG path) and a `qr_url` valid for
180 seconds; scan it with the Bilibili app, then `bili auth status --wait 120`. Credentials land in
`~/.config/bili-cli/` — **never in the nix store, never in the repository**.

## Known limits

- Only x86_64 and aarch64 are built. There is no riscv64 workflow: `curl-cffi` support on riscv64
  is unverified, and **not writing it means not promising it**.
- The upstream is MIT, but the `bilibili-api-python` in its closure is GPL-3.0-or-later; the
  distribution obligations of each apply separately.
