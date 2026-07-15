# comfyui-rocm-patch

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui-rocm-patch%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui-rocm-patch.md) | English | [日本語](../ja/comfyui-rocm-patch.md)  | [偽中国語](../pcn/comfyui-rocm-patch.md)

ROCm feature patch for ComfyUI.

Includes **Strix Halo (gfx1151 / RDNA 3.5 APU) exclusive optimizations**, tested on Ryzen AI MAX+ 395 / Radeon 8060S.

## Overview

| Item | Value |
|------|-----|
| Type | overlay + NixOS module |
| Option | `nixkits.comfyui-rocm-patch.enable` |
| Location | `modules/comfyui-rocm-patch.nix` + `patches/comfyui-nix-strix-halo.patch` |
| Supported GPU | gfx1151 (Strix Halo) — natively recognized by ROCm 7.1 |

## Features

- **rocmGfxOverride option**: Declares `services.comfyui.rocmGfxOverride`, sets `HSA_OVERRIDE_GFX_VERSION`
- **Auto-disable xformers**: `--disable-xformers` (nixpkgs xformers lacks ROCm backend)
- **C build toolchain**: Injects `gcc`, `binutils`, `gnumake` into PATH, sets `CC=gcc`
- **ROCm runtime auto-install**: `hardware.graphics.extraPackages` (clr + rocminfo)
- **Strix Halo kernel params**: `amdgpu.gttsize=131072`
- **Service hardening**: GPU device access permissions (`/dev/kfd`, `/dev/dri/renderD128`)
- **PyTorch 7.2 wheel optional upgrade**

## Usage

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui = {
    enable = true;
    rocmGfxOverride = "11.0.0";  # Optional: custom GPU target version
  };
}
```

## Installation (online integration mode)

Use upstream flake directly, overridden by local module patch (recommended):

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # Online, no fork needed
    nixkits.url = "github:Kihara777/NixKits";
  };

  outputs = { nixkits, comfyui-nix, ... }:
    nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nixkits.nixosModules.comfyui-rocm-patch
        {
          nixkits.comfyui-rocm-patch.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
}
```

## Cache

`cachix use nixkits` (auto-declared via `nixConfig` when used as a flake input).

> ⚠️ This entry is an overlay — it modifies upstream nixpkgs packages rather than being an independent build, and is not in the binary cache.

## Notes

- ROCm 7.1 natively recognizes gfx1151; `HSA_OVERRIDE_GFX_VERSION` is not required
- If GPU is not detected, try `services.comfyui.rocmGfxOverride = "11.0.0"`
- xformers errors: the module auto-disables xformers via `--disable-xformers`
- Module auto-sets `amdgpu.gttsize=131072` (optimized for Strix Halo UMA)
- After C toolchain injection, ComfyUI Manager can build custom node dependencies online
