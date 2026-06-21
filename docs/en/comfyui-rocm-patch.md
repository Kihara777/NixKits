# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | English | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

ROCm function patch for ComfyUI.

## Info

| Item | Value |
|------|-------|
| Option | `nixkits.comfyui-rocm-patch.enable` |
| File | `modules/comfyui-rocm-patch.nix` |

## Usage

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # optional: custom GPU target
}
```

When `rocmGfxOverride` is set, the module injects the `HSA_OVERRIDE_GFX_VERSION` environment variable into the ComfyUI service. It also auto-disables xformers (nixpkgs version lacks ROCm backend) and injects the C build toolchain.
