# kitsfmt

[中文](../zh/kitsfmt.md) | English | [日本語](../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../katalish/kitsfmt.md) | [偽中国語](../pcn/kitsfmt.md)

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

Env vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

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
- Comment preservation
- Idempotent formatting
- **Best-practice auto-fixes** (default on, `-B` to disable):
  - Bare URL quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues`: `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`

## Cache

Available via the NixKits binary cache, avoiding local compilation:

```bash
cachix use nixkits
```

或 NixOS 設定：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
