# codewhale

[中文](../zh/codewhale.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/codewhale.md) | [ｶﾀﾘｯｼｭ](../katalish/codewhale.md) | [偽中国語](../pcn/codewhale.md)

A ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ﾌﾞｳｲﾙﾄ for DeepSeek V4.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.8.62 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-ﾌﾞｳｲﾙﾄ binaries (GitHub Releases) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
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

Requires a [DeepSeek API Key](https://platform.deepseek.com/api_keys) on first run.
