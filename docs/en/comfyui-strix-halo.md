# comfyui-strix-halo

[中文](../../zh/comfyui-strix-halo.md) | [English](comfyui-strix-halo.md) | [日本語](../../ja/comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../../katalish/comfyui-strix-halo.md)

ROCm-accelerated ComfyUI support for AMD Strix Halo (gfx1151 / RDNA 3.5 APU).
**Verified** on Ryzen AI MAX+ 395 / Radeon 8060S.

## Info

| Item | Value |
|------|-------|
| Version | Tracks comfyui-nix |
| Upstream | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| Patch | This repo `patches/comfyui-nix-strix-halo.patch` |
| Target GPU | gfx1151 (Strix Halo) — natively supported in ROCm 7.2 |

## Changes

- **ROCm 7.2 stable wheels**: adds torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0
- **Auto version selection**: prefers 7.2 when rocm72 definitions exist, falls back to 7.1
- **rocmGfxOverride option**: override for unrecognized GPU architectures (`HSA_OVERRIDE_GFX_VERSION`)
- **Auto --disable-xformers**: nixpkgs xformers lacks a ROCm backend
- **C build toolchain**: injects `stdenv.cc`, `binutils`, `gnumake`, sets `CC=gcc` for ComfyUI Manager custom node compilation


## Install

NixKits module (recommended):

```nix
# flake.nix — requires a patched comfyui-nix
{
  nixkits.comfyui-strix-halo.enable = true;
  services.comfyui.enable = true;
}
```

Or apply the patch manually:

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## Notes

- ROCm 7.2 natively supports gfx1151 — no `HSA_OVERRIDE_GFX_VERSION` needed
- If GPU is not detected, try `rocmGfxOverride = "11.0.0"`
- Missing ROCm runtime: `hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers errors: the patch auto-adds `--disable-xformers`
- The module auto-sets `amdgpu.gttsize=131072` for Strix Halo UMA
