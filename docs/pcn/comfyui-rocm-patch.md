# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

> `services.comfyui` `rocmGfxOverride` 選項 ROCm 環境変数注入追加NixOS 上 AMD ROCm GPU ComfyUI 実行可能

## 基本情報

|項目|値|
|------|-----|
|種類|NixOS 模塊|
|模塊|`nix-kits.nixosModules.comfyui-rocm-patch`|
|依存|comfyui-strix-halo|

## 功能

- `services.comfyui.rocmGfxOverride` 選項 — `HSA_OVERRIDE_GFX_VERSION` 設定
- `--disable-xformers` 注入ROCm xformers 非対応
- 用 C 構建工具gccbinutilsmake

## 安裝

```nix
{
nixpkgs.overlays = [ nix-kits.overlays.default ];
}

services.comfyui = {
enable = true;
rocmGfxOverride = "11.5.1";
};
```

## 注意

- `rocmGfxOverride` 默認 `null`HSA_OVERRIDE_GFX_VERSION 未設定
- `comfyui-strix-halo` 模塊 `nixkits.comfyui-strix-halo.gfxOverride` 経由自動設定