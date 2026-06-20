# comfyui-strix-halo

[中文](../zh/comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md) | [日本語](../ja/comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-strix-halo.md) | 偽中国語

AMD Strix Halo(gfx1151 / RDNA 3.5 APU)向 ComfyUI ROCm アクセラレーション。
**Ryzen AI MAX+ 395 / Radeon 8060S** 実機検証済。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | comfyui-nix 追従 |
| アップストリーム | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| パッチ | 本リポジトリ `patches/comfyui-nix-strix-halo.patch` |
| 対応 GPU | gfx1151(Strix Halo)— ROCm 7.2 ネイティブサポート |

## 修正内容

- **ROCm 7.2 stable wheel**: torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0 追加
- **バージョン自動選択**: rocm72 定義 7.2， 7.1 フォールバック
- **rocmGfxOverride オプション**: 未対応 GPU アーキテクチャ上書(`HSA_OVERRIDE_GFX_VERSION`)
- **xformers 自動無効化**: nixpkgs  xformers  ROCm バックエンド非対応
- **C ビルドツールチェーン**: `stdenv.cc`，`binutils`，`gnumake` 注入，`CC=gcc` 設定 ComfyUI Manager カスタムノードコンパイル対応


## インストール

NixKits モジュール使用(推奨)：

```nix
# flake.nix — パッチ済 comfyui-nix 必要
{
  nixkits.comfyui-strix-halo.enable = true;
  services.comfyui.enable = true;
}
```

手動パッチ：

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## 注意

- ROCm 7.2  gfx1151 ネイティブサポート済，`HSA_OVERRIDE_GFX_VERSION` 不要
- GPU 未認識場合 `rocmGfxOverride = "11.0.0"` 試行
- ROCm ランタイム不足時：`hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers エラー発生時：本パッチ自動的 `--disable-xformers` 追加
- モジュール自動 `amdgpu.gttsize=131072` 設定(Strix Halo UMA 用)
