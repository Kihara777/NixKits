# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | English | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | [偽中国語](../pcn/obs-bilibili-stream.md)

Bilibili live streaming plugin for OBS Studio.

## Info

| Item | Value |
|------|-------|
| Version | 2.1.0 |
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

Available via the NixKits binary cache, avoiding local compilation:

```bash
cachix use nixkits
```

或 NixOS 設定：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
