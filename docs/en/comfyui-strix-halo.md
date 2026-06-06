# ComfyUI Strix Halo Patch

[中文](../zh/comfyui-strix-halo.md) | [English](comfyui-strix-halo.md)

ROCm-accelerated ComfyUI support for AMD Strix Halo (gfx1151 / RDNA 3.5 APU).
**Verified** on Ryzen AI MAX+ 395 / Radeon 8060S.

## Background

Strix Halo (Ryzen AI MAX+ 395 / Radeon 8060S etc.) uses the gfx1151 GPU architecture.
As of ROCm 7.1, gfx1151 was **not in the official support matrix**; ROCm 7.2 adds
native support.

This patch modifies [comfyui-nix](https://github.com/utensils/comfyui-nix) in four places:

| File | Change |
|------|--------|
| `nix/versions.nix` | Adds ROCm 7.2 stable wheel definitions (torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0) |
| `nix/python-overrides.nix` | Auto-selects ROCm 7.2 when available (fallback: 7.1) |
| `nix/modules/comfyui.nix` | New `rocmGfxOverride` option + auto `--disable-xformers` in ROCm mode |

## Verified

| Item | Result |
|------|--------|
| Hardware | Ryzen AI MAX+ 395 / Radeon 8060S (128 GB VRAM) |
| GPU detection | **AMD Radeon 8060S : native** (no HSA_OVERRIDE_GFX_VERSION needed) |
| torch version | 2.12.0+rocm7.2 |
| Generation test | Z-Image 1024×1024, 10 steps — success (2.0 MB PNG) |

## Usage

### Option A: NixOS Module (recommended)

Apply the patch, then enable the NixKits module:

```nix
# flake.nix
{
  inputs = {
    nix-kits.url = "github:Kihara777/NixKits";
    # Use a patched comfyui-nix (local clone or fork):
    comfyui-nix.url = "/path/to/patched-comfyui-nix";
  };

  outputs = { nix-kits, comfyui-nix, ... }: {
    nixosConfigurations.xxx = nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nix-kits.nixosModules.comfyui-strix-halo
        {
          nixkits.comfyui-strix-halo.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
  };
}
```

The module automatically:
- Configures `hardware.graphics` with ROCm runtime libraries
- Sets `gpuSupport = "rocm"`
- Applies Strix Halo kernel parameters (`amdgpu.gttsize=131072`)
- Optionally sets `HSA_OVERRIDE_GFX_VERSION`

### Option B: Apply Patch Manually

```bash
cd comfyui-nix
patch -p1 < /path/to/NixKits/patches/comfyui-nix-strix-halo.patch
```

Then in system config:

```nix
inputs.comfyui-nix.url = "/path/to/patched-comfyui-nix";
services.comfyui.gpuSupport = "rocm";
```

The patch includes auto `--disable-xformers` for ROCm — no manual config needed.

### rocmGfxOverride

The module does **not** set `HSA_OVERRIDE_GFX_VERSION` by default. ROCm 7.2 has
native gfx1151 support — verified on real hardware. If GPU detection fails in the
future, enable the override:

```nix
services.comfyui.rocmGfxOverride = "11.0.0";  # gfx1100 compatibility path
```

| Value | Architecture | Notes |
|-------|-------------|-------|
| `"11.0.0"` | gfx1100 (RDNA 3) | Best compatibility for gfx1151 |
| `"11.5.1"` | gfx1151 (RDNA 3.5) | Native architecture |

## Troubleshooting

### GPU not detected by PyTorch

Symptoms: `Torch not compiled with ROCm enabled` or `No GPU detected` in logs.

1. Verify `/dev/kfd` and `/dev/dri/renderD128` exist
2. Check `rocminfo` output (requires `rocmPackages.rocminfo`)
3. Try `rocmGfxOverride = "11.0.0"`

### xformers error

Symptom: `NotImplementedError: No operator found for memory_efficient_attention_forward`

The patch auto-adds `--disable-xformers` in ROCm mode. If launching ComfyUI
manually without the module, add this flag yourself.

### Missing ROCm runtime

```
rocminfo: command not found
libamdhip64.so: cannot open shared object file
```

The NixKits module configures `hardware.graphics.extraPackages` automatically.
Manual setup:

```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.rocminfo
  ];
};
```

## Technical Details

### Architecture Support

| ROCm Version | gfx1151 Status |
|-------------|----------------|
| 7.1 | Preview — requires `HSA_OVERRIDE_GFX_VERSION` |
| 7.2 | Native — this patch's default, verified on hardware |

### How HSA_OVERRIDE_GFX_VERSION Works

The ROCm runtime selects precompiled kernels by GPU architecture. If gfx1151
kernels are unavailable, `HSA_OVERRIDE_GFX_VERSION=11.0.0` forces the runtime to
load gfx1100 (RDNA 3) kernels. The two are binary-compatible. ROCm 7.2 + PyTorch
2.12.0 already include native gfx1151 kernels — no override needed.

### xformers

The nixpkgs `xformers` package only ships a CUDA backend (no ROCm support).
The patch auto-adds `--disable-xformers` in ROCm mode, falling back to
PyTorch's native attention which performs equivalently on ROCm.

### Strix Halo Kernel Parameters

Strix Halo uses a unified memory architecture (UMA). Recommended:

```
amdgpu.gttsize=131072  # 128 GB GTT for large models
```

The NixKits module sets this automatically when enabled.

## References

- [ROCm Compatibility Matrix](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- [ROCm RDNA 3.5 Optimization Guide](https://rocm.docs.amd.com/en/latest/how-to/system-optimization/rdna3-5.html)
- [PyTorch ROCm 7.2 Wheels](https://download.pytorch.org/whl/rocm7.2/)
- [ROCm/ROCm Issue #5339 — gfx1151 Support Discussion](https://github.com/ROCm/ROCm/issues/5339)
