# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)

Bilibili live streaming plugin for OBS Studio.

## Info

| Item | Value |
|------|-------|
| Version | 2.0.12 |
| Upstream | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| Platform | Linux only |

## Install

**Recommended: NixOS module**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  imports = [ inputs.nix-kits.nixosModules.obs-bilibili-stream ];
}
```

**Manual**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**Home Manager**

```nix
home.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
```
