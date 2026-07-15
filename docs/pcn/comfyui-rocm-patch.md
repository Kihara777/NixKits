# comfyui-rocm-patch

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md)  | 偽中国語

提供 ComfyUI ROCm 機能補丁。

含 **Strix Halo（gfx1151 / RDNA 3.5 APU）専用最適化**、Ryzen AI MAX+ 395 / Radeon 8060S 於実機検証済。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | overlay + NixOS 部品 |
| 選項 | `nixkits.comfyui-rocm-patch.enable` |
| 位置 | `modules/comfyui-rocm-patch.nix` + `patches/comfyui-nix-strix-halo.patch` |
| 対応 GPU | gfx1151（Strix Halo）— ROCm 7.1 於原生認識 |

## 機能

- **rocmGfxOverride 選項**: 宣言 `services.comfyui.rocmGfxOverride`、設定 `HSA_OVERRIDE_GFX_VERSION`
- **xformers 自動無効化**: `--disable-xformers`（nixpkgs 之 xformers 為 ROCm 後端非対応）
- **C 構築道具鎖**: 注入 `gcc`、`binutils`、`gnumake` 至 PATH、設定 `CC=gcc`
- **ROCm 実行時自動導入**: `hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo 核心媒介**: `amdgpu.gttsize=131072`
- **服務堅牢化**: GPU 機器接続権限（`/dev/kfd`、`/dev/dri/renderD128`）
- **PyTorch 7.2 wheel 選項昇級**

## 使用法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui = {
    enable = true;
    rocmGfxOverride = "11.0.0";  # 選項：GPU 目標版 自定
  };
}
```

## 導入（線上統合模式）

直接以上流 flake、於本地部品補丁覆写（推奨）：

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # 線上版、不要分叉
    nixkits.url = "github:Kihara777/NixKits";
  };

  outputs = { nixkits, comfyui-nix, ... }:
    nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nixkits.nixosModules.comfyui-rocm-patch
        {
          nixkits.comfyui-rocm-patch.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
}
```

## 緩衝

`cachix use nixkits`（至 flake input 使用時自 `nixConfig` 自動宣言）。

> ⚠️ 本条目為 overlay、修改上流 nixpkgs 包非独立構築、不在二進制緩衝中。

## 注意

- ROCm 7.1 原生認識 gfx1151、不需 `HSA_OVERRIDE_GFX_VERSION`
- GPU 未認識時試 `services.comfyui.rocmGfxOverride = "11.0.0"`
- xformers 錯誤時：部品自 `--disable-xformers` 於無効化
- 部品自設定 `amdgpu.gttsize=131072`（Strix Halo UMA 向最適化）
- C 道具鎖注入後、ComfyUI Manager 可線上編輯自定節点依存
