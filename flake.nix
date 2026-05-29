{
  description = "NixKits - A comprehensive NixOS flake repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    llama-cpp-ver.url = "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest";
    llama-cpp-ver.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    llama-cpp-ver,
  } @ inputs:
  flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    kitsfmtDrv = pkgs.callPackage ./packages/kitsfmt.nix { };
  in {
    packages = rec {
      codewhale            = pkgs.callPackage ./packages/codewhale.nix { };
      kitsfmt              = kitsfmtDrv;
      opencode-telegram    = pkgs.callPackage ./packages/opencode-telegram.nix { };
      mcp-searxng          = pkgs.callPackage ./packages/mcp-searxng.nix { };
      obs-bilibili-stream  = pkgs.callPackage ./packages/obs-bilibili-stream.nix { };
      default              = codewhale;
    };

    formatter = pkgs.writeShellScriptBin "kitsfmt-fmt" ''
      exec ${kitsfmtDrv}/bin/kitsfmt -i "$@"
    '';
  }) // {

    nixosModules.obs-bilibili-stream = import ./modules/obs-bilibili-stream.nix;

    overlays = {
      default           = import ./overlays/default.nix;
      llama-cpp-rocm    = import ./overlays/llama-cpp-rocm.nix { inherit llama-cpp-ver; };
      rcc-fix           = import ./overlays/rog-control-center-fix.nix;
    };

  };
}
