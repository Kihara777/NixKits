{
  description = "NixKits - A comprehensive NixOS flake repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    # Input for OBS Bilibili Stream plugin (non-flake source)
    obs-bilibili-src = {
      url = "github:Zarosmm/obs-bilibili-stream";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    obs-bilibili-src,
  } @inputs:
  {
    # NixOS modules
    nixosModules.obs-bilibili-stream = import ./modules/obs-bilibili-stream.nix;

    # Overlays
    overlays = {
      # OBS Bilibili Stream plugin overlay
      obs-bilibili-stream = import ./overlays/obs-bilibili-stream.nix { src = inputs.obs-bilibili-src; };

      # RCC-FIX overlay for ASUS ROG Control Center
      rcc-fix = import ./overlays/rog-control-center-fix.nix;

      # kitsfmt formatter overlay
      kitsfmt = import ./overlays/kitsfmt.nix;
    };

    # Per-system packages
    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      obsBiliStream = pkgs.callPackage ./packages/obs-bilibili-stream.nix {
        src = inputs.obs-bilibili-src;
      };
      kitsfmt = pkgs.callPackage ./packages/kitsfmt.nix { };
    in {
      obs-bilibili-stream = obsBiliStream;
      kitsfmt = kitsfmt;
      default = kitsfmt;
    };
  };
}
