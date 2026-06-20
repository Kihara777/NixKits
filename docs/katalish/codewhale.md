# codewhale

[中文](../zh/codewhale.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | [偽中国語](../pcn/codewhale.md)

ｱ ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ﾌﾞｳｲﾙﾄ ﾌｫｱ ﾄﾞｴｴﾌﾟｽｴｴｸ V4.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.8.62 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-ﾌﾞｳｲﾙﾄ binaries (ｷﾞｯﾄﾊﾌﾞ Releases) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## ﾕｰｾｰｼﾞ

```bash
codewhale                              # interactive ﾃｨｰﾕｰｱｲ
codewhale "explain ﾃﾞｨｽ function"      # one-shot ﾌﾟﾗｵﾑﾌﾟﾄ
codewhale --ﾓﾃﾞﾙ ｵｰﾄ "ﾌｨｯｸｽ ﾃﾞｨｽ ﾊﾞｸﾞ"  # ｵｰﾄ-ｾﾙｴｸﾄ ﾓﾃﾞﾙ
codewhale --yolo                       # ｵｰﾄ-ｱﾌﾟﾙｰﾌﾞ ﾂｰﾙｽﾞ
codewhale ﾄﾞｸﾀｰ                       # check ｾｯﾄｱｯﾌﾟ
codewhale ｵｰｽ set --provider deepseek # ｾｰﾌﾞ API key
```

ﾘｸﾜｲｱｽﾞ a [ﾄﾞｴｴﾌﾟｽｴｴｸ API Key](https://platform.deepseek.com/api_keys) ｵﾝ ﾌｧｰｽﾄ ﾗﾝ.
