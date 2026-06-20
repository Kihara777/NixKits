# kitsfmt

[中文](../zh/kitsfmt.md) | [English](kitsfmt.md) | [日本語](../ja/kitsfmt.md)

**ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ** — AST-based ｳｨｽﾞ attribute sorting, comment preservation, ｱﾝﾄﾞ indentation normalization.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.5.0 |
| ﾗﾝｹﾞｰｼﾞ | Rust |
| ｿｰｽ | ﾃﾞｨｽ repo `packages/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt ﾌｧｲﾙ.ﾆｯｸｽ             # ｱｳﾄﾌﾟｯﾄ ﾄｩ stdout
kitsfmt --inplace ﾌｧｲﾙ.ﾆｯｸｽ   # in-place ﾌｫｰﾏｯﾄ
kitsfmt --check ﾌｧｲﾙ.ﾆｯｸｽ     # ﾁｪｯｸ ﾌｫｰﾏｯﾃｨﾝｸﾞ
kitsfmt --no-best-practices  # ﾃﾞｨｾｰﾌﾞﾙ auto-fixes
kitsfmt file1.ﾆｯｸｽ file2.ﾆｯｸｽ  # multiple ﾌｧｲﾙｽﾞ
```

ｴﾇﾌﾞｲ vars: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# Direct
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.kitsfmt ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ (recommended)
nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];  # → pkgs.kitsfmt

# ｱｽﾞ ﾆｯｸｽ fmt ﾌｫｰﾏｯﾀｰ
# ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ} = ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ};
# ｾﾞﾝ: ﾆｯｸｽ fmt
```

## ﾌｨｰﾁｬｰｽﾞ

- Attribute sorting (including APC `a.b.c` collapse)
- Comment preservation
- Idempotent ﾌｫｰﾏｯﾃｨﾝｸﾞ
- **Best-practice auto-fixes** (ﾃﾞﾌｫﾙﾄ ｵﾝ, `-B` ﾄｩ ﾃﾞｨｾｰﾌﾞﾙ):
  - Bare ﾕｰｱｰﾙｴﾙ quoting (RFC 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues`: `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`