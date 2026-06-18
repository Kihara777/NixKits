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
      ruyi                 = pkgs.callPackage ./packages/ruyi.nix { };
    };

    formatter = pkgs.writeShellScriptBin "kitsfmt-fmt" ''
      exec ${kitsfmtDrv}/bin/kitsfmt -i "$@"
    '';

    devShells = let
      ruyiDrv = pkgs.callPackage ./packages/ruyi.nix { };
    in {
      ruyi = pkgs.mkShell {
        name = "ruyi-dev";
        packages = [ ruyiDrv ];
        shellHook = ''
          echo "RuyiSDK $(ruyi --version 2>/dev/null | head -1)"
        '';
      };
    };
  }) // {

    nixosModules.obs-bilibili-stream   = import ./modules/obs-bilibili-stream.nix;
    nixosModules.opencode-telegram     = import ./modules/opencode-telegram.nix;
    nixosModules.llama-cpp-rocm        = import ./modules/llama-cpp-rocm.nix;
    nixosModules.comfyui-strix-halo    = import ./modules/comfyui-strix-halo.nix;
    nixosModules.rog-control-center-fix = import ./modules/rog-control-center-fix.nix;
    nixosModules.ruyi                 = import ./modules/ruyi.nix;

    overlays = {
      default           = import ./overlays/default.nix;
      llama-cpp-rocm    = import ./overlays/llama-cpp-rocm.nix { inherit llama-cpp-ver; };
      rcc-fix           = import ./overlays/rog-control-center-fix.nix;
      ruyi-nixos-compat = import ./overlays/ruyi-nixos-compat.nix;
    };

  };
}
