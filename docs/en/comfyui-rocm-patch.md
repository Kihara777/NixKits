# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

> Adds a `rocmGfxOverride` option and ROCm environment variable injection to `services.comfyui`, enabling ComfyUI to run on AMD ROCm GPUs on NixOS.

## Info

| Item | Value |
|------|------|
| Type | NixOS Module |
| Module path | `nix-kits.nixosModules.comfyui-rocm-patch` |
| Dependency | comfyui-strix-halo |

## Features

- `services.comfyui.rocmGfxOverride` option — sets `HSA_OVERRIDE_GFX_VERSION`
- Injects `--disable-xformers` flag (ROCm does not support xformers)
- Adds C build toolchain (gcc, binutils, make) for custom node compilation

## Installation

```nix
{
  nixpkgs.overlays = [ nix-kits.overlays.default ];
}

services.comfyui = {
  enable = true;
  rocmGfxOverride = "11.5.1";
};
```

## Notes

- `rocmGfxOverride` defaults to `null` (no HSA_OVERRIDE_GFX_VERSION set)
- Auto-configured by `comfyui-strix-halo` module via `nixkits.comfyui-strix-halo.gfxOverride`
