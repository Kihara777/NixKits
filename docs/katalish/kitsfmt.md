# kitsfmt

[中文](../../zh/kitsfmt.md) | [ｲﾝｸﾞﾘｯｼｭ](kitsfmt.md) | [日本語](../../ja/kitsfmt.md) | [ｶﾀﾘｯｼｭ](../../katalish/kitsfmt.md) | [偽中国語](../../pcn/kitsfmt.md)

**ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ** — ｴｰｴｽﾃｨｰ-ﾍﾞｰｽﾄﾞ ｳｨｽﾞ ｱﾄﾘﾋﾞｭｰﾄ ｿｰﾃｨﾝｸﾞ, ｺﾒﾝﾄ ﾌﾟﾗｴｽｴﾗﾌﾞｱｼｮﾝ, ｱﾝﾄﾞ ｲﾝﾃﾞﾝﾃｰｼｮﾝ ﾝｵﾗﾑｱﾙｲｽﾞｱｼｮﾝ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.5.0 |
| ﾗﾝｹﾞｰｼﾞ | Rust |
| ｿｰｽ | ﾃﾞｨｽ ﾗｴﾌﾟｵ `packages/kitsfmt-src/` |

## ﾕｰｾｰｼﾞ

```bash
kitsfmt file.nix             # output to stdout
kitsfmt --inplace file.nix   # in-place format
kitsfmt --check file.nix     # check formatting
kitsfmt --no-best-practices  # disable auto-fixes
kitsfmt file1.nix file2.nix  # multiple files
```

ｴﾇﾌﾞｲ ﾌﾞｱﾗｽﾞ: `KITSFMT_INPLACE=1`, `KITSFMT_CHECK=1`, `KITSFMT_BEST_PRACTICES=0`

## ｲﾝｽﾄｰﾙ

```nix
# ﾀﾞｲﾚｸﾄ
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.kitsfmt ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ (ﾗｴｸｵﾑﾑｴﾝﾄﾞﾄﾞ)
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];  # → pkgs.kitsfmt

# ｱｽﾞ ﾆｯｸｽ ﾌﾑﾄ ﾌｫｰﾏｯﾀｰ
# ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ} = ｲﾝﾌﾟｯﾄｽﾞ.ﾆｯｸｽ-ｸｲﾄｽﾞ.ﾌｫｰﾏｯﾀｰ.${ｼｽﾃﾑ};
# ｾﾞﾝ: ﾆｯｸｽ ﾌﾑﾄ
```

## ﾌｨｰﾁｬｰｽﾞ

- ｱﾄﾘﾋﾞｭｰﾄ ｿｰﾃｨﾝｸﾞ (ｲﾝｸﾙｳﾄﾞｲﾝｸﾞ ｱﾌﾟｸ `a.b.c` ｺﾗﾌﾟｽ)
- ｺﾒﾝﾄ ﾌﾟﾗｴｽｴﾗﾌﾞｱｼｮﾝ
- ｲﾃﾞﾝﾎﾟﾃﾝﾄ ﾌｫｰﾏｯﾃｨﾝｸﾞ
- **ﾌﾞｴｽﾄ-ﾌﾟﾗｱｸﾄｲｽｴ ｵｰﾄ-ﾌｨｯｸｼｰｽﾞ** (ﾃﾞﾌｫﾙﾄ ｵﾝ, `-B` ﾄｩ ﾃﾞｨｾｰﾌﾞﾙ):
  - ﾍﾞｱ ﾕｰｱｰﾙｴﾙ ｸｵﾄｲﾝｸﾞ (ﾗﾌｸ 45): `https://x.com` → `"https://x.com"`
  - `rec` → `let-in`: `rec { a = 1; }` → `let a=1; in { inherit a; }`
  - `with` → `builtins.attrValues`: `with pkgs; [ a b ]` → `builtins.attrValues { inherit (pkgs) a b; }`