# codewhale

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/codewhale.md)

A ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ built ﾌｫｱ ﾄﾞｴｴﾌﾟｽｴｴｸ V4.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.8.62 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-built binaries (ｷﾞｯﾄﾊﾌﾞ Releases) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
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

Requires ｱ [ﾄﾞｴｴﾌﾟｽｴｴｸ API Key](https://platform.deepseek.com/api_keys) on ﾌｧｰｽﾄ run.

## ｷｬｯｼｭ

NixKits ﾊﾞｲﾅﾘ ｷｬｯｼｭ ｶﾗ ｱﾌﾞｴｲﾗﾌﾞﾙ、ﾛｰｶﾙ ｺﾝﾊﾟｲﾙ 回避：

```bash
cachix use nixkits
```

或 NixOS 設定：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
