# comfyui-rocm-patch

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | 日本語  | [偽中国語](../pcn/comfyui-rocm-patch.md)

ComfyUI 向け ROCm 機能パッチ。

**Strix Halo（gfx1151 / RDNA 3.5 APU）専用最適化**を含み、Ryzen AI MAX+ 395 / Radeon 8060S で実機検証済み。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | overlay + NixOS モジュール |
| オプション | `nixkits.comfyui-rocm-patch.enable` |
| 位置 | `modules/comfyui-rocm-patch.nix` + `patches/comfyui-nix-strix-halo.patch` + `patches/comfyui-nix-nixpkgs-compat.patch` |
| 対応 GPU | gfx1151（Strix Halo）— ROCm 7.1 でネイティブ認識 |

## 機能

- **rocmGfxOverride オプション**: `services.comfyui.rocmGfxOverride` を宣言し、`HSA_OVERRIDE_GFX_VERSION` を設定
- **xformers 自動無効化**: `--disable-xformers`（nixpkgs の xformers は ROCm バックエンド非対応）
- **C ビルドツールチェーン**: `gcc`、`binutils`、`gnumake` を PATH に注入、`CC=gcc` を設定
- **ROCm ランタイム自動インストール**: `hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo カーネルパラメータ**: `amdgpu.gttsize=131072`
- **サービス堅牢化**: GPU デバイスアクセス権限（`/dev/kfd`、`/dev/dri/renderD128`）
- **PyTorch 7.2 wheel オプションアップグレード**

## 互換性パッチ（nixpkgs ≥ 2026-08-05）

付属パッチ `patches/comfyui-nix-nixpkgs-compat.patch` は nixpkgs ドリフトによるビルド失敗を解決します：

- **`pythonRuntimeDepsCheckHook`**: vendored wheel の METADATA が宣言するランタイム依存は comfyui pythonRuntime が提供するため、ビルド時のチェックが失敗 → mkWheel に `dontCheckRuntimeDeps = true` を追加
- **flaky テスト**: jupyter-server / scipy / fastapi / einops 等のテストがサンドボックスで失敗 → `doInstallCheck = false`（pytestCheckHook は installCheckPhase で実行されるため `doCheck = false` は無効）

nixpkgs ≥ 2026-08-05 を使用する場合はこのパッチの適用が必要です。

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui = {
    enable = true;
    rocmGfxOverride = "11.0.0";  # オプション：GPU ターゲットバージョンをカスタム
  };
}
```

## インストール（オンライン統合モード）

上流 flake を直接使用し、ローカルモジュールパッチで上書き（推奨）：

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # オンライン版、フォーク不要
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

## キャッシュ

`cachix use nixkits`（flake input として使用時に `nixConfig` で自動宣言）。

> ⚠️ 本エントリは overlay であり、独立したビルドではなく上流 nixpkgs パッケージを変更するため、バイナリキャッシュに含まれません。

## 注意

- ROCm 7.1 は gfx1151 をネイティブ認識するため、`HSA_OVERRIDE_GFX_VERSION` は不要
- GPU が認識されない場合は `services.comfyui.rocmGfxOverride = "11.0.0"` を試す
- xformers エラー時：モジュールが自動的に `--disable-xformers` で無効化
- モジュールは自動的に `amdgpu.gttsize=131072` を設定（Strix Halo UMA 向け最適化）
- C ツールチェーン注入後、ComfyUI Manager でカスタムノード依存をオンラインコンパイル可能
