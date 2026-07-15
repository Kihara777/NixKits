# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-x86_64.yml?branch=main&label=x86_64%20v2.1.2)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-aarch64.yml?branch=main&label=aarch64%20v2.1.2)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio Bilibili ﾗｲﾌﾞ ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ.

## ｲﾝﾌｫ

| Item | Value |
|------|-----|
| ﾊﾞｰｼﾞｮﾝ | 2.1.2 |
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