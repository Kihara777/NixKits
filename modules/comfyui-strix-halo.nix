# NixOS module: comfyui-strix-halo
#
# Strix Halo (gfx1151 / RDNA 3.5 APU) optimizations for ComfyUI ROCm.
# Verified on Ryzen AI MAX+ 395 / Radeon 8060S (128 GB VRAM).
#
# This module:
#   - Configures hardware.graphics with ROCm runtime libraries (clr, rocminfo)
#   - Sets services.comfyui.gpuSupport = "rocm"
#   - Optionally sets HSA_OVERRIDE_GFX_VERSION via gfxOverride (default: 11.0.0)
#   - Adds recommended Strix Halo kernel parameters (amdgpu.gttsize)
#
# The companion patch (../patches/comfyui-nix-strix-halo.patch) must be applied
# to comfyui-nix first — it adds:
#   - ROCm 7.2 stable wheels (torch 2.12.0, torchvision 0.27.0, torchaudio 2.11.0)
#   - ROCm version auto-selection (7.2 preferred, 7.1 fallback)
#   - rocmGfxOverride module option
#   - Auto --disable-xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
#   - CC=gcc + C build toolchain (gcc, binutils, make) for custom node compilation
#
# Full documentation: ../docs/zh/comfyui-strix-halo.md
#
# Quick start:
#   nixkits.comfyui-strix-halo.enable = true;

{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.nixkits.comfyui-strix-halo = {
    enable = lib.mkEnableOption "Strix Halo (gfx1151) optimizations for ComfyUI";

    gfxOverride = lib.mkOption {
      type = lib.types.str;
      default = "11.0.0";
      description = ''
        GPU architecture version to override via HSA_OVERRIDE_GFX_VERSION.
        - "11.0.0": gfx1100 (RDNA3) — most compatible for gfx1151
        - "11.5.1": gfx1151 native — try if ROCm runtime supports it
      '';
    };
  };

  config = lib.mkIf config.nixkits.comfyui-strix-halo.enable {
    assertions = [
      {
        assertion = config.services ? comfyui;
        message = ''
          nixkits.comfyui-strix-halo requires services.comfyui, but it was
          not found. Import the comfyui-nix module in your flake first.
        '';
      }
      {
        assertion = builtins.compareVersions pkgs.glibc.version "2.42" >= 0;
        message = ''
          comfyui-strix-halo: ROCm 7.2 requires glibc >= 2.42 for GPU support
          (hsa-runtime needs GLIBC_ABI_GNU2_TLS symbol). Current glibc:
          ${pkgs.glibc.version}. Update your nixpkgs input.
        '';
      }
    ];

    # Configure comfyui service for Strix Halo
    services.comfyui = {
      gpuSupport = lib.mkDefault "rocm";
      rocmGfxOverride = lib.mkDefault config.nixkits.comfyui-strix-halo.gfxOverride;
    };

    # Ensure ROCm runtime is available
    hardware.graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.rocminfo
      ];
    };

    # Systemd service hardening for ROCm
    systemd.services.comfyui.serviceConfig = {
      # Allow access to GPU devices
      DeviceAllow = [
        "/dev/kfd"
        "/dev/dri/renderD128"
      ];
    };

    # Recommended kernel parameters for Strix Halo (shared memory APU)
    # These improve GPU memory allocation for the unified memory architecture
    boot.kernelParams = lib.mkAfter [
      "amdgpu.gttsize=131072"  # 128GB GTT for large model support
    ];
  };
}