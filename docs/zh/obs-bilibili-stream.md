# obs-bilibili-stream

中文 | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | [偽中国語](../pcn/obs-bilibili-stream.md)

OBS Studio 的 Bilibili 直播推流插件。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 2.1.0 |
| 上游 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| 平台 | Linux only |

## 引用

**推荐：NixOS 模块**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**手动**

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

## 缓存

可通过 NixKits 二进制缓存获取，避免本地编译：

```bash
cachix use nixkits
```

或 NixOS 配置添加：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
