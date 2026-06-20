# kitsfmt

[中文](../zh/kitsfmt.md) | [English](../en/kitsfmt.md) | [日本語](../ja/kitsfmt.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/kitsfmt.md)

**ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ** — ｴｰｴｽﾃｨｰ-ﾍﾞｰｽﾄﾞ ｳｨｽﾞ ｱﾄﾘﾋﾞｭｰﾄ ｿｰﾃｨﾝｸﾞ, ｺﾒﾝﾄ ﾌﾟﾗｴｽｴﾗﾌﾞｱｼｮﾝ, ｱﾝﾄﾞ ｲﾝﾃﾞﾝﾃｰｼｮﾝ ﾝｵﾗﾑｱﾙｲｽﾞｱｼｮﾝ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.5.0 |
| ﾗﾝｹﾞｰｼﾞ | Rust |
| ｿｰｽ | ﾃﾞｨｽ ﾗｴﾌﾟｵ `packages/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt ﾌｧｲﾙ.ﾆｯｸｽ             # ｱｳﾄﾌﾟｯﾄ ﾄｩ ｽﾄﾄﾞｵｳﾄ
kitsfmt --ｲﾝﾌﾟﾙｱｽｴ ﾌｧｲﾙ.ﾆｯｸｽ   # ｲﾝ-ﾌﾟﾙｱｽｴ ﾌｵﾗﾑｱﾄ
kitsfmt --ﾁｪｯｸ ﾌｧｲﾙ.ﾆｯｸｽ     # ﾁｪｯｸ ﾌｫｰﾏｯﾃｨﾝｸﾞ
kitsfmt --ﾉｰ-best-practices  # ﾃﾞｨｾｰﾌﾞﾙ ｵｰﾄ-ﾌｨｯｸｼｰｽﾞ
kitsfmt ﾌｧｲﾙ1.ﾆｯｸｽ ﾌｧｲﾙ2.ﾆｯｸｽ  # ﾑｳﾙﾄｲﾌﾟﾙｴ ﾌｧｲﾙｽﾞ
```

ｴﾇﾌﾞｲ ﾌﾞｱﾗｽﾞ: `KITSFMT_INPLACE=1` `KITSFMT_CHECK=1` `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# ﾀﾞｲﾚｸﾄ
environment.ｽｲｽﾄｴﾑﾌﾟｱｯｸｱｸﾞｽﾞ = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ (ﾗｴｸｵﾑﾑｴﾝﾄﾞﾄﾞ)
nixpkgs.overlays = [ inputs.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];  # → pkgs.kitsfmt

# ｱｽﾞ ﾆｯｸｽ ﾌﾑﾄ ﾌｫｰﾏｯﾀｰ
# ﾌｫｰﾏｯﾀｰ.${system} = inputs.nix-kits.ﾌｫｰﾏｯﾀｰ.${system};
# ｾﾞﾝ: ﾆｯｸｽ ﾌﾑﾄ
```

## ﾌｨｰﾁｬｰｽﾞ

- ｱﾄﾘﾋﾞｭｰﾄ ｿｰﾃｨﾝｸﾞ (ｲﾝｸﾙｳﾄﾞｲﾝｸﾞ ｱﾌﾟｸ `a.b.c` ｺﾗﾌﾟｽ)
- ｺﾒﾝﾄ ﾌﾟﾗｴｽｴﾗﾌﾞｱｼｮﾝ
- ｲﾃﾞﾝﾎﾟﾃﾝﾄ ﾌｫｰﾏｯﾃｨﾝｸﾞ
- **ﾌﾞｴｽﾄ-ﾌﾟﾗｱｸﾄｲｽｴ ｵｰﾄ-ﾌｨｯｸｼｰｽﾞ** (ﾃﾞﾌｫﾙﾄ ｵﾝ, `-B` ﾄｩ ﾃﾞｨｾｰﾌﾞﾙ):
  - ﾍﾞｱ ﾕｰｱｰﾙｴﾙ ｸｵﾄｲﾝｸﾞ (ﾗﾌｸ 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in` `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues` `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`