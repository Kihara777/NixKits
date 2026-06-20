# comfyui-rocm-patch

[中文](comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

> 为 `services.comfyui` 添加 `rocmGfxOverride` 选项和 ROCm 环境变量注入，使 ComfyUI 可在 NixOS 上使用 AMD ROCm GPU 运行。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | NixOS 模块 |
| 模块路径 | `nix-kits.nixosModules.comfyui-rocm-patch` |
| 依赖 | comfyui-strix-halo |

## 功能

- `services.comfyui.rocmGfxOverride` 选项 — 设置 `HSA_OVERRIDE_GFX_VERSION`
- 注入 `--disable-xformers` 标志（ROCm 不支持 xformers）
- 添加 C 构建工具链（gcc、binutils、make）用于自定义节点编译

## 安装

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

- `rocmGfxOverride` 默认为 `null`（不设置 HSA_OVERRIDE_GFX_VERSION）
- 由 `comfyui-strix-halo` 模块通过 `nixkits.comfyui-strix-halo.gfxOverride` 自动配置
