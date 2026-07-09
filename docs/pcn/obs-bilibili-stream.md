# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20obs-bilibili-stream%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20obs-bilibili-stream%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-stream.md) | 偽中国語

OBS Studio Bilibili 生配信拡張。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 2.1.1 |
| 上流 | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| 基盤 | Linux only |

## 参照

**推奨：NixOS 部品**

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

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
