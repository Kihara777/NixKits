# ComfyUI ROCm module — ROCm support + Strix Halo (gfx1151) optimizations
#
# Merged from the former comfyui-rocm-patch and comfyui-strix-halo modules:
#
#   - rocmGfxOverride option (HSA_OVERRIDE_GFX_VERSION)
#   - --disable-xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
#   - C build toolchain (gcc, binutils, make) for custom node compilation
#   - CC=gcc environment variable
#   - Strix Halo ROCm runtime (clr, rocminfo) via hardware.graphics
#   - GPU device access (DeviceAllow) + amdgpu.gttsize kernel param
#
# Wheel version upgrades (ROCm 7.2 / PyTorch 2.12.0) are handled by the
# accompanying patch applied to comfyui-nix via nixpkgs overlay:
#   ../patches/comfyui-nix-strix-halo.patch
# and, for nixpkgs >= 2026-08-05:
#   ../patches/comfyui-nix-nixpkgs-compat.patch
#
# This module extends services.comfyui; enable with:
#
#   nixkits.comfyui-rocm.enable = true;
#   services.comfyui.enable = true;
#
{ config, lib, pkgs, ... }:
let
  comfyCfg = config.services.comfyui;
  cfg = config.nixkits.comfyui-rocm;
  useRocm = comfyCfg.gpuSupport == "rocm";
in
{
  options = {
    services.comfyui.rocmGfxOverride = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "11.0.0";
      description = ''
        Override the GPU architecture version reported to the ROCm runtime via
        the HSA_OVERRIDE_GFX_VERSION environment variable.

        This is useful for newer AMD GPUs that are not yet in the ROCm support
        matrix but are binary-compatible with an existing architecture.

        Common values:
        - "11.0.0": gfx1100 (RDNA 3) — recommended for gfx1151 (Strix Halo)
        - "11.5.1": gfx1151 native — may work if runtime recognizes it
        - "10.3.0": gfx1030 (RDNA 2) — fallback for older RDNA cards

        Only takes effect when gpuSupport = "rocm".
      '';
    };

    nixkits.comfyui-rocm = {
      enable = lib.mkEnableOption "ComfyUI ROCm support (GFX override, xformers bypass, C toolchain, Strix Halo optimizations)";

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
  };

  config = lib.mkIf (cfg.enable && comfyCfg.enable) {
    assertions = [
      {
        assertion = builtins.compareVersions pkgs.glibc.version "2.42" >= 0;
        message = ''
          nixkits.comfyui-rocm: ROCm 7.2 requires glibc >= 2.42 for GPU support
          (hsa-runtime needs GLIBC_ABI_GNU2_TLS symbol). Current glibc:
          ${pkgs.glibc.version}. Update your nixpkgs input.
        '';
      }
    ];

    # Apply the Strix Halo patch to the comfyui package
    nixpkgs.overlays = [
      (final: prev: {
        comfyui = prev.comfyui.overrideAttrs (old: {
          patches = (old.patches or []) ++ [
            # ROCm 7.2 wheels + Strix Halo (gfx1151/RDNA3.5) support
            ../patches/comfyui-nix-strix-halo.patch
          ];
        });
      })
    ];

    # Configure comfyui service for ROCm / Strix Halo
    services.comfyui = {
      gpuSupport = lib.mkDefault "rocm";
      rocmGfxOverride = lib.mkDefault cfg.gfxOverride;

      # Disable xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
      extraArgs = lib.optionals useRocm [ "--disable-xformers" ];

      # Environment: GFX override + C compiler for custom node builds
      environment = lib.mkMerge [
        (lib.mkIf (useRocm && comfyCfg.rocmGfxOverride != null) {
          HSA_OVERRIDE_GFX_VERSION = comfyCfg.rocmGfxOverride;
        })
        {
          CC = "gcc";
        }
      ];
    };

    # Ensure ROCm runtime is available
    hardware.graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        rocmPackages.clr
        rocmPackages.rocminfo
      ];
    };

    # C build toolchain in service PATH for custom node builds
    systemd.services.comfyui.path = [
      pkgs.stdenv.cc
      pkgs.binutils
      pkgs.gnumake
    ];

    # Systemd service hardening for ROCm — allow GPU device access
    systemd.services.comfyui.serviceConfig = {
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
