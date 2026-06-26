{
  description = "NixKits - A comprehensive NixOS flake repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    llama-cpp-ver.url = "path:./ci/llama-cpp-ver.json";
    llama-cpp-ver.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    llama-cpp-ver,
  } @ inputs:
  let
    allSystems = flake-utils.lib.defaultSystems ++ [ "riscv64-linux" ];
  in flake-utils.lib.eachSystem allSystems (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    kitsfmtDrv = pkgs.callPackage ./packages/kitsfmt.nix { };
  in {
    packages = rec {
      codewhale            = pkgs.callPackage ./packages/codewhale.nix { };
      kitsfmt              = kitsfmtDrv;
      opencode-telegram    = pkgs.callPackage ./packages/opencode-telegram.nix { };
      mcp-searxng          = pkgs.callPackage ./packages/mcp-searxng.nix { };
      obs-bilibili-stream  = pkgs.callPackage ./packages/obs-bilibili-stream.nix { };
      ruyi                 = pkgs.callPackage ./packages/ruyi/ruyi.nix { };
      ruyi-beta            = pkgs.callPackage ./packages/ruyi/ruyi-beta.nix { };
      ruyi-alpha           = pkgs.callPackage ./packages/ruyi/ruyi-alpha.nix { };
    };

    formatter = pkgs.writeShellScriptBin "kitsfmt-fmt" ''
      exec ${kitsfmtDrv}/bin/kitsfmt -i "$@"
    '';

    devShells = let
      ruyiDrv = pkgs.callPackage ./packages/ruyi/ruyi.nix { };
      ruyiBetaDrv = pkgs.callPackage ./packages/ruyi/ruyi-beta.nix { };
      ruyiAlphaDrv = pkgs.callPackage ./packages/ruyi/ruyi-alpha.nix { };
      # Apply ruyi-nixos-compat overlay so devShell also gets NixOS compat
      ruyiOverlay = import ./overlays/ruyi-nixos-compat.nix;
      ruyiWithCompat = (ruyiOverlay (pkgs // { ruyi = ruyiDrv; }) (pkgs // { ruyi = ruyiDrv; })).ruyi;
    in {
      ruyi = pkgs.mkShell {
        name = "ruyi-dev";
        packages = [ ruyiWithCompat ];
        shellHook = ''
          echo "RuyiSDK $(ruyi --version 2>/dev/null | head -1)"
        '';
      };

      ruyi-beta = pkgs.mkShell { name = "ruyi-beta-dev"; packages = [ ruyiBetaDrv ]; };
      ruyi-alpha = pkgs.mkShell { name = "ruyi-alpha-dev"; packages = [ ruyiAlphaDrv ]; };
    };
  }) // {

    nixosModules.obs-bilibili-stream   = import ./modules/obs-bilibili-stream.nix;
    nixosModules.opencode-telegram     = import ./modules/opencode-telegram.nix;
    nixosModules.llama-cpp-rocm        = import ./modules/llama-cpp-rocm.nix;
    nixosModules.comfyui-rocm-patch    = import ./modules/comfyui-rocm-patch.nix;
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

  # Cachix binary cache configuration.
  # Placed at flake top level (not inside `outputs`) to avoid
  # `nix flake check` warning about unknown flake output.
  nixConfig = {
    extra-substituters = [ "https://nixkits.cachix.org" ];
    extra-trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
  };
}
