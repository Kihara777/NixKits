# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | English | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

ROCm capability patch for ComfyUI.

## Info

- **Feature**: Patches ComfyUI ROCm support, enables custom node build toolchain (via `gfxOverride` for custom GPU target)
- **Location**: `modules/comfyui-rocm-patch.nix`

## Usage

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # custom GPU target version
}
```

When `rocmGfxOverride` is set, the module injects `HSA_OVERRIDE_GFX_VERSION` into the ComfyUI service.
