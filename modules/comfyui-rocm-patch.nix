# ComfyUI ROCm Patch Module — extends upstream comfyui-nix without forking
#
# Applies the module-level changes from NixKits patches/comfyui-nix-strix-halo.patch:
#   - rocmGfxOverride option (HSA_OVERRIDE_GFX_VERSION)
#   - --disable-xformers in ROCm mode (nixpkgs xformers lacks ROCm backend)
#   - C build toolchain (gcc, binutils, make) for custom node compilation
#   - CC=gcc environment variable
#
# Wheel version upgrades (ROCm 7.2 / PyTorch 2.12.0) are handled by
# the accompanying patch applied to comfyui-nix via nixpkgs overlay.
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
    # Apply the Strix Halo patch to comfyui package
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