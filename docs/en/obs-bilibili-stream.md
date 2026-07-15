# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-x86_64.yml?branch=main&label=x86_64)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-aarch64.yml?branch=main&label=aarch64)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | English | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | [偽中国語](../pcn/obs-bilibili-stream.md)

Bilibili live streaming plugin for OBS Studio.

## Info

| Item | Value |
|------|-------|
| Version | 2.1.2 |
| Upstream | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| Platform | Linux only |

## Install

**Recommended: NixOS module**

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

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).
