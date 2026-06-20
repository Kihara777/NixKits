# codewhale

[中文](../../zh/codewhale.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | [偽中国語](../pcn/codewhale.md)

ｱ terminal ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ built ﾌｫｱ DeepSeek V4.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.8.62 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| ﾀｲﾌﾟ | Pre-built binaries (GitHub Releases) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## ﾕｰｾｰｼﾞ

```bash
codewhale                              # interactive TUI
codewhale "explain this function"      # one-shot prompt
codewhale --model auto "fix this bug"  # auto-select model
codewhale --yolo                       # auto-approve tools
codewhale doctor                       # check setup
codewhale auth set --provider deepseek # save API key
```

Requires ｱ [DeepSeek ｴｰﾋﾟｰｱｲ ｷｰ](https://platform.deepseek.com/api_keys) ｵﾝ first run.