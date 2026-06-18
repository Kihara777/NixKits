# NixKits module: comfyui-rocm-patch
#
# Extends upstream comfyui-nix NixOS module without forking.
# Declares rocmGfxOverride option and applies ROCm-specific tweaks:
#   - rocmGfxOverride option (HSA_OVERRIDE_GFX_VERSION)
#   - --disable-xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
#   - C build toolchain (gcc, binutils, make) for custom node compilation
#   - CC=gcc environment variable
#
# Companion module: comfyui-strix-halo.nix (uses rocmGfxOverride)
# Companion overlay: overlays/comfyui-rocm-wheels.nix (optional ROCm 7.2 wheels)
{ config, lib, pkgs, ... }:
let
  cfg = config.services.comfyui;
  useRocm = cfg.gpuSupport == "rocm";
in
{
  options.services.comfyui.rocmGfxOverride = lib.mkOption {
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

  config = lib.mkIf cfg.enable {
    # Disable xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
    services.comfyui.extraArgs = lib.optionals useRocm [ "--disable-xformers" ];

    # Environment: GFX override + C compiler for custom node builds
    services.comfyui.environment = lib.mkMerge [
      (lib.mkIf (useRocm && cfg.rocmGfxOverride != null) {
        HSA_OVERRIDE_GFX_VERSION = cfg.rocmGfxOverride;
      })
      {
        CC = "gcc";
      }
    ];

    # C build toolchain in service PATH for custom node builds
    systemd.services.comfyui.path = [
      pkgs.stdenv.cc
      pkgs.binutils
      pkgs.gnumake
    ];
  };
}
