# comfyui-strix-halo

[中文](../../zh/comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md) | [日本語](comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-strix-halo.md) | [偽中国語](../pcn/comfyui-strix-halo.md)

AMD Strix Halo（gfx1151 / RDNA 3.5 APU）向け ComfyUI ROCm アクセラレーション。
**Ryzen AI MAX+ 395 / Radeon 8060S** で実機検証済み。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | comfyui-nix に追従 |
| アップストリーム | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| パッチ | 本リポジトリ `patches/comfyui-nix-strix-halo.patch` |
| 対応 GPU | gfx1151（Strix Halo）— ROCm 7.2 でネイティブサポート |

## 修正内容

- **ROCm 7.2 stable wheel**: torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0 を追加
- **バージョン自動選択**: rocm72 定義があれば 7.2、なければ 7.1 にフォールバック
- **rocmGfxOverride オプション**: 未対応 GPU アーキテクチャの上書き（`HSA_OVERRIDE_GFX_VERSION`）
- **xformers 自動無効化**: nixpkgs の xformers は ROCm バックエンド非対応のため
- **C ビルドツールチェーン**: `stdenv.cc`、`binutils`、`gnumake` を注入、`CC=gcc` を設定し ComfyUI Manager のカスタムノードコンパイルに対応


## インストール

NixKits モジュールを使用（推奨）：

```nix
# flake.nix — パッチ済み comfyui-nix が必要
{
  nixkits.comfyui-strix-halo.enable = true;
  services.comfyui.enable = true;
}
```

または手動パッチ：

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## 注意

- ROCm 7.2 では gfx1151 がネイティブサポート済みのため、`HSA_OVERRIDE_GFX_VERSION` は不要
- GPU 未認識の場合は `rocmGfxOverride = "11.0.0"` を試行
- ROCm ランタイム不足時：`hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers エラー発生時：本パッチが自動的に `--disable-xformers` を追加
- モジュールが自動で `amdgpu.gttsize=131072` を設定（Strix Halo UMA 用）
