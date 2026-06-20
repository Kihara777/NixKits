# kitsfmt

[中文](../zh/kitsfmt.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../katalish/kitsfmt.md) | [偽中国語](../pcn/kitsfmt.md)

**Nix ﾌｫｰﾏｯﾀｰ** — AST-based ｳｨｽﾞ attribute sorting, comment preservation, ｱﾝﾄﾞ indentation normalization.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.5.0 |
| Language | Rust |
| Source | This repo `ﾊﾟｯｹｰｼﾞs/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt file.nix             # output ﾄｩ stdout
kitsfmt --inplace file.nix   # ｲﾝ-place format
kitsfmt --check file.nix     # check formatting
kitsfmt --ﾉｰ-best-practices  # ﾃﾞｨｽｴｲﾌﾞﾙ ｵｰﾄ-fixes
kitsfmt file1.nix file2.nix  # multiple files
```

Env vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# Direct
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# Default overlay (recommended)
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];  # → pkgs.kitsfmt

# As nix fmt formatter
# formatter.${system} = inputs.nix-kits.formatter.${system};
# then: nix fmt
```

## Features

- Attribute sorting (including APC `a.b.c` collapse)
- Comment preservation
- Idempotent formatting
- **Best-practice ｵｰﾄ-fixes** (ﾃﾞﾌｫﾙﾄ ｵﾝ, `-B` ﾄｩ ﾃﾞｨｽｴｲﾌﾞﾙ):
  - Bare URL quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-ｲﾝ`: `rec { a = 1; }` → `let a=1; ｲﾝ { inherit a; }`
  - `ｳｨｽﾞ` → `ﾌﾞｳｲﾙﾄins.attrValues`: `ｳｨｽﾞ pkgs; [ a b ]` → `ﾌﾞｳｲﾙﾄins.attrValues { inherit (pkgs) a b; }`
