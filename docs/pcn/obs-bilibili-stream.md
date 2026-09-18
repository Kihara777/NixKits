# obs-bilibili-stream

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-x86_64.yml?branch=main&label=x86_64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-obs-bilibili-stream-aarch64.yml?branch=main&label=aarch64%20v2.1.5)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md)  | 偽中国語

OBS Studio Bilibili 生配信拡張。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 2.1.5 |
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

> 警告 -- **`home.packages` 依 導入 限定 場合 OBS 此 読込 不**：OBS `OBS_PLUGINS_PATH` 依 plugin 探索、此 変数 nixpkgs `wrapOBS`（即 `programs.obs-studio.plugins`）限定 注入。`home.packages` `.so` profile 置 限定、OBS 該 path 走査 不。故：
>
> - **NixOS 上** 上記 module 或 `programs.obs-studio.plugins` 使用（推奨）
> - **非 NixOS / Home Manager 限定** 場合、OBS plugin 探索 path `.../lib/obs-plugins` 包含 様 自力 確保 要（`wrapOBS` 包装、或 `.so` 手動 配置）

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
