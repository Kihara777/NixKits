{
  description = "NixKits - A comprehensive NixOS flake repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  } @inputs:
  {
    # NixOS modules
    nixosModules.obs-bilibili-stream = import ./modules/obs-bilibili-stream.nix;

    # Overlays
    overlays = {
      # OBS Bilibili Stream plugin overlay
      obs-bilibili-stream = import ./overlays/obs-bilibili-stream.nix;

      # MTP support (PR 22673) for llama-cpp-rocm
      llama-cpp-rocm = import ./overlays/llama-cpp-rocm.nix;

      # RCC-FIX overlay for ASUS ROG Control Center
      rcc-fix = import ./overlays/rog-control-center-fix.nix;

      # kitsfmt formatter overlay
      kitsfmt = import ./overlays/kitsfmt.nix;
    };

    # Per-system packages
    packages.x86_64-linux = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      obsBiliStream = pkgs.callPackage ./packages/obs-bilibili-stream.nix { };
      kitsfmt = pkgs.callPackage ./packages/kitsfmt.nix { };
    in {
      obs-bilibili-stream = obsBiliStream;
      kitsfmt = kitsfmt;
    };
  };
}
