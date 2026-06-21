# comfyui-rocm-patch

中文 | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

为 ComfyUI 提供 ROCm 功能补丁。

## 基本信息

| 项目 | 值 |
|------|-----|
| 选项 | `nixkits.comfyui-rocm-patch.enable` |
| 位置 | `modules/comfyui-rocm-patch.nix` |

## 使用

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # 可选：自定义 GPU 目标版本
}
```

设置 `rocmGfxOverride` 后，该模块会将 `HSA_OVERRIDE_GFX_VERSION` 环境变量注入 ComfyUI 服务。同时自动禁用 xformers（nixpkgs 版本缺少 ROCm 后端）并注入 C 构建工具链。
