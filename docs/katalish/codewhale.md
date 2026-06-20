# codewhale

[中文](../../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](codewhale.md) | [偽中国語](../../pcn/codewhale.md)

ｱ ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ built ﾌｫｱ DeepSeek V4.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.8.60 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| ﾀｲﾌﾟ | Pre-built binaries (GitHub Releases) |

## ｲﾝｽﾄｰﾙ

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.codewhale ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.codewhale
nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
```

## ﾕｰｾｰｼﾞ

```bash
codewhale                              # interactive TUI
codewhale "explain ﾃﾞｨｽ function"      # one-shot prompt
codewhale --model ｵｰﾄ "ﾌｨｯｸｽ ﾃﾞｨｽ ﾊﾞｸﾞ"  # auto-select ﾓﾃﾞﾙ
codewhale --yolo                       # auto-approve ﾂｰﾙｽﾞ
codewhale doctor                       # ﾁｪｯｸ ｾｯﾄｱｯﾌﾟ
codewhale auth set --provider deepseek # ｾｰﾌﾞ ｴｰﾋﾟｰｱｲ ｷｰ
```

ﾘｸﾜｲｱｽﾞ ｱ [DeepSeek API Key](https://platform.deepseek.com/api_keys) ｵﾝ ﾌｧｰｽﾄ ﾗﾝ.