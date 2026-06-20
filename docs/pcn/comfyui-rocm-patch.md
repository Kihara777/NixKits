# comfyui-rocm-patch

[中文](../../zh/comfyui-rocm-patch.md) | [English](../../en/comfyui-rocm-patch.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/comfyui-rocm-patch.md) | [偽中国語](../../pcn/comfyui-rocm-patch.md)

ComfyUI ROCm 機能補丁提供

## 基本情報

- **機能**：ComfyUI ROCm 支持補丁当構建工具有効化`gfxOverride` GPU 指定
- **位置**：`modules/comfyui-rocm-patch.nix`

## 使方

```nix
{
services.comfyui.rocmGfxOverride = "gfx1100"; # GPU 版本
}
```

`rocmGfxOverride` 設定`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI 服務注入