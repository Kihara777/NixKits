# comfyui-strix-halo

[中文](../../zh/comfyui-strix-halo.md) | [English](../../en/comfyui-strix-halo.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/comfyui-strix-halo.md) | [偽中国語](../../pcn/comfyui-strix-halo.md)

AMD Strix Halogfx1151 / RDNA 3.5 APU向 ComfyUI ROCm 加速
**Ryzen AI MAX+ 395 / Radeon 8060S** 実機検証済

## 基本情報

|項目|値|
|------|-----|
|版本|comfyui-nix 追従|
||[utensils/comfyui-nix](https://github.com/utensils/comfyui-nix)|
|補丁|本倉庫 `patches/comfyui-nix-strix-halo.patch`|
|対応 GPU|gfx1151Strix Halo— ROCm 7.2 支持|

## 修正内容

- **ROCm 7.2 stable wheel**: torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0 追加
- **版本自動選択**: rocm72 定義 7.2 7.1
- **rocmGfxOverride 選項**: 未対応 GPU 架構上書`HSA_OVERRIDE_GFX_VERSION`
- **xformers 自動無効化**: nixpkgs xformers ROCm 非対応
- **C 構建工具**: `stdenv.cc``binutils``gnumake` 注入`CC=gcc` 設定 ComfyUI Manager 対応


## 安裝

NixKits 模塊使用推奨：

```nix
# flake.nix — 補丁済 comfyui-nix 必要
{
nixkits.comfyui-strix-halo.enable = true;
services.comfyui.enable = true;
}
```

手動補丁：

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## 注意

- ROCm 7.2 gfx1151 支持済`HSA_OVERRIDE_GFX_VERSION` 不要
- GPU 未認識場合 `rocmGfxOverride = "11.0.0"` 試行
- ROCm 運行時不足時：`hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers 発生時：本補丁自動的 `--disable-xformers` 追加
- 模塊自動 `amdgpu.gttsize=131072` 設定Strix Halo UMA 用