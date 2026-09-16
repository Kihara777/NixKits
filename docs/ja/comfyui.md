# comfyui

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui.md) | [English](../en/comfyui.md) | 日本語  | [偽中国語](../pcn/comfyui.md)

ComfyUI 向け ROCm 機能パッチ。

**Strix Halo（gfx1151 / RDNA 3.5 APU）専用最適化**を含み、Ryzen AI MAX+ 395 / Radeon 8060S で実機検証済み。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | 純粋な NixOS モジュール（**パッチは同梱しない**） |
| オプション | `nixkits.comfyui.enable` |
| 位置 | `modules/comfyui.nix` |
| 対応 GPU | gfx1151（Strix Halo）— ROCm 7.1 でネイティブ認識 |

## 機能

- **rocmGfxOverride オプション**: `services.comfyui.rocmGfxOverride` を宣言し、`HSA_OVERRIDE_GFX_VERSION` を設定
- **xformers 自動無効化**: `--disable-xformers`（nixpkgs の xformers は ROCm バックエンド非対応）
- **C ビルドツールチェーン**: `gcc`、`binutils`、`gnumake` を PATH に注入、`CC=gcc` を設定
- **ROCm ランタイム自動インストール**: `hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo カーネルパラメータ**: `amdgpu.gttsize=131072`
- **サービス堅牢化**: GPU デバイスアクセス権限（`/dev/kfd`、`/dev/dri/renderD128`）

## 上流互換性について（2026-09-15 整理）

本モジュールは**かつて 3 つのパッチを同梱していたが、現在はすべて削除済み**：

| 削除したパッチ | 削除理由 |
|----------------|----------|
| `comfyui-nix-strix-halo` | 上流が同等の ROCm 7.1 / PyTorch 2.10.0 wheel を同梱済み（バージョン・URL・hash が完全一致） |
| `comfyui-nix-stdenv-api` | 上流が自ら `stdenv.hostPlatform.*` へ移行済み（旧記法は残り 0 箇所） |
| `comfyui-nix-nixpkgs-compat` | **nixpkgs の組み合わせ次第** —— 下記の警告を参照 |

> ⚠️ **`nixpkgs-compat` の判定はかつて誤っていた。戒めとして残す。**
> 初回評価の「完全ビルド検証」（717 個の derivation がすべて成功）では、
> `scipy` は実は**バイナリキャッシュから供給されており、一度も実際にはビルドされていなかった**。
> アップグレード後は直ちに `test_support_moments_sample` で失敗した ——
> 浮動小数点のアサーションであり、まさにこのパッチがスキップしようとしていたテストである。
> 根因は nixpkgs の組み合わせの違いにある：上流は `nixos-unstable` を使い公共キャッシュに
> ヒットするが、下流は nixpkgs をローカルに固定したリビジョンへ `follow` することが多く、
> そちらは現にビルドする必要がある。
>
> **教訓：ビルド検証は、対象の derivation が本当にビルドされたことを確認しなければならない。**
> ログに `building '…'` の行が現れて初めて証明となる。「ビルド成功」だけでは
> 「ビルドを通過した」と「ビルドが不要だった」を区別できない。

**詳細な記録はリポジトリルートの [`DEPRECATED.md`](../../DEPRECATED.md) を参照。**

> **fork は不要に**：以前は「comfyui-nix をフォークしてパッチを適用」を推奨していたが、現在は不要 ——
> `comfyui-nix` input を上流に向けるだけでよい。
>
> ⚠️ 併せて `pkgs.comfyui` にパッチを当てる overlay も削除した。その役割は上流の
> `disabledModules` + 同梱 package に取って代わられており、残すとパッチファイルが
> 存在しないため**ビルド時に失敗する**（評価時にはエラーが出ないため気付きにくい）。

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
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
        nixkits.nixosModules.comfyui
        {
          nixkits.comfyui.enable = true;
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
