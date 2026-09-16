# comfyui

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui.md) | [English](../en/comfyui.md) | [日本語](../ja/comfyui.md)  | 偽中国語

ComfyUI 向 ROCm 機能補丁提供。

含 **Strix Halo（gfx1151 / RDNA 3.5 APU）専用最適化**、Ryzen AI MAX+ 395 / Radeon 8060S 於実機検証済。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | 純 NixOS 部品（**補丁不再付属**） |
| 選項 | `nixkits.comfyui.enable` |
| 位置 | `modules/comfyui.nix` |
| 対応 GPU | gfx1151（Strix Halo）— ROCm 7.1 於原生認識 |

## 機能

- **rocmGfxOverride 選項**: 宣言 `services.comfyui.rocmGfxOverride`、設定 `HSA_OVERRIDE_GFX_VERSION`
- **xformers 自動無効化**: `--disable-xformers`（nixpkgs 之 xformers 為 ROCm 後端非対応）
- **C 構築道具鎖**: 注入 `gcc`、`binutils`、`gnumake` 至 PATH、設定 `CC=gcc`
- **ROCm 実行時自動導入**: `hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo 核心媒介**: `amdgpu.gttsize=131072`
- **服務堅牢化**: GPU 機器接続権限（`/dev/kfd`、`/dev/dri/renderD128`）

## 上流互換性之件（2026-09-15 清理）

本部品**曾附帯三個補丁、今已全部除去**：

| 已除去的補丁 | 除去理由 |
|--------------|----------|
| `comfyui-nix-strix-halo` | 上流已自帯等效之 ROCm 7.1 / PyTorch 2.10.0 wheels（版、URL、hash 完全一致） |
| `comfyui-nix-stdenv-api` | 上流已自行移行至 `stdenv.hostPlatform.*`（旧写法 0 処） |
| `comfyui-nix-nixpkgs-compat` | 以前判定「依然必要 有 可能」、**該判定 既 覆** —— 詳見下方警示 |

> ⚠️ **`nixpkgs-compat` 之判定曾出錯、值得引以為戒。**
> 初次評価之「完整構築検証」（717 個 derivation 全成功）中、`scipy` 実為
> **緩衝命中、従未真実構築**；昇級後即因 `test_support_moments_sample`
> 浮点断言失敗 —— 当時 誤認 正是該補丁欲跳過之測試。
>
> **真因 本機 残留 一 余分 pin**：`comfyui-nix` 之 `inputs.nixpkgs`
> 釘死 旧 rev、一方 top level 追 rolling `nixos-unstable`。
> top level 命中公共緩衝、釘死 子 flake 則 需現建 —— 故「緩衝 本可解決
> 之問題」見做「補丁 必要 之問題」。**該 pin 行 削除 後 構築全通過、補丁 一切 不要。**
>
> **教訓一：構築検証必須確認目標 derivation 真実被構築。** 日誌中出現
> `building '…'` 才算数；「構築成功」無法区別「構築通過」與「無需構築」。
>
> **教訓二：余分 `inputs.*` pin 子 flake 主 nixpkgs 緩衝被覆 切離。**
> 加 前 先問 其 何 解決；問題 消 後 削除 忘 無。

**完整記録見倉庫根目録 [`DEPRECATED.md`](../../DEPRECATED.md)。**

> **分叉不再必要**：此前建議「fork comfyui-nix 並適用補丁」、今已無必要 ——
> 直接將 `comfyui-nix` input 指向上流即可。
>
> ⚠️ 同時除去了一個給 `pkgs.comfyui` 打補丁之上乗。其作用已被上流
> `disabledModules` + 自帯 package 取代；若保留、会因補丁書類不存在而
> **於構築期失敗**（求值期不報錯、故不易察覚）。

## 使用

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
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
        nixkits.nixosModules.comfyui
        {
          nixkits.comfyui.enable = true;
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
