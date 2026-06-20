# kitsfmt

[中文](../../zh/kitsfmt.md) | [English](kitsfmt.md) | [日本語](../../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../../katalish/kitsfmt.md) | [偽中国語](../../pcn/kitsfmt.md)

**ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ** — AST-based ｳｨｽﾞ attribute sorting, comment preservation, ｱﾝﾄﾞ indentation normalization.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.5.0 |
| ﾗﾝｹﾞｰｼﾞ | Rust |
| ｿｰｽ | ﾃﾞｨｽ repo `packages/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt file.nix             # output to stdout
kitsfmt --inplace file.nix   # in-place format
kitsfmt --check file.nix     # check formatting
kitsfmt --no-best-practices  # disable auto-fixes
kitsfmt file1.nix file2.nix  # multiple files
```

env vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# Direct
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ (recommended)
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];  # → pkgs.kitsfmt

# ｱｽﾞ ﾆｯｸｽ fmt ﾌｫｰﾏｯﾀｰ
# ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ} = inputs.ﾆｯｸｽ-kits.ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ};
# then: ﾆｯｸｽ fmt
```

## ﾌｨｰﾁｬｰｽﾞ

- Attribute sorting (including APC `a.b.c` collapse)
- Comment preservation
- Idempotent formatting
- **Best-practice ｵｰﾄ-fixes** (ﾃﾞﾌｫﾙﾄ ｵﾝ, `-B` ﾄｩ disable):
  - Bare ﾕｰｱｰﾙｴﾙ quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues`: `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`