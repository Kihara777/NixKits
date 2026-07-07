# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20obs-bilibili-stream%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20obs-bilibili-stream%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio Bilibili ﾗｲﾌﾞ ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ.

## ｲﾝﾌｫ

| Item | Value |
|------|-----|
| ﾊﾞｰｼﾞｮﾝ | 2.1.0 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| Platform | Linux only |

## Usage

**Recommended: NixOS ﾓｼﾞｭｰﾙ**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**Manual**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**

```nix
home.packages = [ inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream ];
```

## Cache

`cachix use nixkits` (declared automatically via `nixConfig` in ｻﾞ flake; prompted on first use).