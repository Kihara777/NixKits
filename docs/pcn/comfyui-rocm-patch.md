# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI ROCm 功能提供。

## 基本情報

- **功能**：ComfyUI ROCm 支持当，構建工具有効化(`gfxOverride` GPU 指定)
- **位置**：`modules/comfyui-rocm-patch.nix`

## 使方

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # カスタム GPU ターゲットバージョン
}
```

`rocmGfxOverride` 設置，`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI 服務注入。
