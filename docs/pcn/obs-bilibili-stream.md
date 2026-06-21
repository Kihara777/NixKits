# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | 偽中国語

OBS Studio 用 Bilibili 生放送配信插件。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 2.1.0 |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| 平台 | Linux 限定 |

## 参照

**推奨：NixOS 模块**

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**手動**

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

## 緩存

NixKits 二進制緩存可用、回避本地編譯：

```bash
cachix use nixkits
```

或 NixOS 設定：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
