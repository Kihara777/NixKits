# kitsfmt

[中文](../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/kitsfmt.md)

**Nix ﾌｫｰﾏｯﾀｰ** — AST-based ｳｨｽﾞ attribute sorting, comment preservation, ｱﾝﾄﾞ indentation normalization.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.5.0 |
| Language | Rust |
| Source | This repo `packages/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt file.nix             # output to stdout
kitsfmt --inplace file.nix   # in-place format
kitsfmt --check file.nix     # check formatting
kitsfmt --no-best-practices  # disable auto-fixes
kitsfmt file1.nix file2.nix  # multiple files
```

Env vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# Direct
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.kitsfmt ];

# Default overlay (recommended)
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.kitsfmt

# As nix fmt formatter
# formatter.${system} = inputs.nixkits.formatter.${system};
# then: nix fmt
```

## ﾌｨｰﾁｬｰｽﾞ

- Attribute sorting (including APC `a.b.c` collapse)
- Comment preservation
- Idempotent formatting
- **Best-practice auto-fixes** (default on, `-B` to disable):
  - Bare URL quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { ｱ = 1; }` → `let a=1; in { inherit a; }`
  - `ｳｨｽﾞ` → `builtins.attrValues`: `ｳｨｽﾞ pkgs; [ ｱ b ]` → `builtins.attrValues { inherit (pkgs) ｱ b; }`
