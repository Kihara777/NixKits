# kitsfmt

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-x86_64.yml?branch=main&label=x86_64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-aarch64.yml?branch=main&label=aarch64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-kitsfmt-riscv64.yml?branch=main&label=riscv64%20v0.5.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/kitsfmt.md) | English | [日本語](../ja/kitsfmt.md)  | [偽中国語](../pcn/kitsfmt.md)

**Nix formatter** — AST-based with attribute sorting, comment preservation, and indentation normalization.

## Info

| Item | Value |
|------|-------|
| Version | 0.5.0 |
| Language | Rust |
| Source | This repo `packages/kitsfmt-src/` |

## Usage

```bash
kitsfmt file.nix             # output to stdout
kitsfmt --inplace file.nix   # in-place format
kitsfmt --check file.nix     # check formatting
kitsfmt --no-best-practices  # disable auto-fixes
kitsfmt file1.nix file2.nix  # multiple files
```

Env vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_STDIN=1`, `KITSFMT_BEST_PRACTICES=0`

## Install

```nix
# Direct
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.kitsfmt ];

# Default overlay (recommended)
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.kitsfmt

# As nix fmt formatter
# formatter.${system} = inputs.nixkits.formatter.${system};
# then: nix fmt
```

## Features

- Attribute sorting (including APC `a.b.c` collapse)
- **Comment preservation (leading comments only)**: a comment on the line **above** an attribute / `let` binding / list element travels with that node as it is sorted; see the limitation below
- Idempotent formatting
- **Best-practice auto-fixes** (default on, `-B` to disable):
  - Bare URL quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues`: `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`

### Comment preservation limits

"Comment preservation" applies to **leading comments above a node**: a comment on the line above an attribute / `let` binding / list element travels with that node as it is sorted. Measured against kitsfmt 0.5.0, the following positions are **dropped**:

| Comment position | Result |
|----------|------|
| Line **above** an attribute / `let` binding / list element | Preserved, following the node |
| Same line, trailing a non-last attribute | Relocated **above the next attribute** |
| Same line, trailing the **last** attribute | Dropped |
| File header (before the top-level expression) | Dropped |
| File footer (after the top-level expression) | Dropped |

> Before formatting, make sure comments in those positions carry nothing you cannot regenerate -- or move them above an attribute.

## Cache

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).
