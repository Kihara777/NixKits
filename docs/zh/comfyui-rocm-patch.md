# comfyui-rocm-patch

中文 | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

为 ComfyUI 提供 ROCm 功能补丁。

## 基本信息

- **功能**：修补 ComfyUI 的 ROCm 支持，启用自定义节点构建工具链（通过 `gfxOverride` 指定自定义 GPU 目标版本）
- **位置**：`modules/comfyui-rocm-patch.nix`

## 使用

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # 自定义 GPU 目标版本
}
```

设置 `rocmGfxOverride` 后，该模块会将 `HSA_OVERRIDE_GFX_VERSION` 环境变量注入 ComfyUI 服务。
