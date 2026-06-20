# codewhale

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/codewhale.md)

ｱ ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ﾌﾞｳｲﾙﾄ ﾌｫｱ ﾄﾞｴｴﾌﾟｽｴｴｸ ﾌﾞ4.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.8.62 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ﾎﾑﾌﾞｵｳﾝ/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| ﾀｲﾌﾟ | ﾌﾟﾗｴ-ﾌﾞｳｲﾙﾄ ﾌﾞｲﾝｱﾗｲｽﾞ (GitHub ﾗｴﾙｴｱｽｽﾞ) |

## ｲﾝｽﾄｰﾙ

```nix
environment.ｽｲｽﾄｴﾑﾌﾟｱｯｸｱｸﾞｽﾞ = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
```

## ﾕｰｾｰｼﾞ

```bash
codewhale                              # ｲﾝﾄｴﾗｱｸﾄｲﾌﾞｴ ﾃｨｰﾕｰｱｲ
codewhale "ｴｸｽﾌﾟﾙｱｲﾝ ﾃﾞｨｽ ﾌｳﾝｸｼｮﾝ"      # ｵﾝｴ-ｼｵﾄ ﾌﾟﾗｵﾑﾌﾟﾄ
codewhale --ﾓﾃﾞﾙ ｵｰﾄ "ﾌｨｯｸｽ ﾃﾞｨｽ ﾊﾞｸﾞ"  # ｵｰﾄ-ｽｴﾙｴｸﾄ ﾓﾃﾞﾙ
codewhale --ｲｵﾙｵ                       # ｵｰﾄ-ｱﾌﾟﾌﾟﾗｵﾌﾞｴ ﾂｰﾙｽﾞ
codewhale ﾄﾞｵｸﾄｵﾗ                       # ﾁｪｯｸ ｾｯﾄｱｯﾌﾟ
codewhale ｱｳｽ ｾｯﾄ --ﾌﾟﾗｵﾌﾞｲﾄﾞｴﾗ ﾄﾞｴｴﾌﾟｽｴｴｸ # ｾｰﾌﾞ ｴｰﾋﾟｰｱｲ ｷｰ
```

ﾘｸﾜｲｱｽﾞ ｱ [ﾄﾞｴｴﾌﾟｽｴｴｸ ｴｰﾋﾟｰｱｲ ｷｰ](https://platform.deepseek.com/api_keys) ｵﾝ ﾌｧｰｽﾄ ﾗﾝ.