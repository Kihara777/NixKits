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
  let
    allSystems = flake-utils.lib.defaultSystems ++ [ "riscv64-linux" ];
  in flake-utils.lib.eachSystem allSystems (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    # godot-ai needs fastmcp >= 3.4 (3.3.x has circular-import bug)
    godotPkgs = pkgs.extend self.overlays.fastmcp;
    kitsfmtDrv = pkgs.callPackage ./packages/kitsfmt.nix { };
  in {
    packages = rec {
      blender-mcp          = pkgs.callPackage ./packages/blender-mcp.nix { };
      codewhale            =
        if pkgs.stdenv.hostPlatform.isRiscV
        then pkgs.callPackage ./packages/codewhale-src.nix { }
        else pkgs.callPackage ./packages/codewhale.nix { };
      kitsfmt              = kitsfmtDrv;
      opencode-telegram    = pkgs.callPackage ./packages/opencode-telegram.nix { };
      mcp-searxng          = pkgs.callPackage ./packages/mcp-searxng.nix { };
      obs-bilibili-stream  = pkgs.callPackage ./packages/obs-bilibili-stream.nix { };
      ruyi                 = pkgs.callPackage ./packages/ruyi/ruyi.nix { };
      ruyi-beta            = pkgs.callPackage ./packages/ruyi/ruyi-beta.nix { };
      ruyi-alpha           = pkgs.callPackage ./packages/ruyi/ruyi-alpha.nix { };
      godot-ai             = godotPkgs.callPackage ./packages/godot-ai.nix { };
      dsh                  = pkgs.callPackage ./packages/dsh.nix { };
    };

    formatter = pkgs.writeShellScriptBin "kitsfmt-fmt" ''
      exec ${kitsfmtDrv}/bin/kitsfmt -i "$@"
    '';

    devShells = let
      inherit (self.packages.${system}) blender-mcp mcp-searxng opencode-telegram ruyi ruyi-beta ruyi-alpha godot-ai;
    in {
      opencode   = pkgs.callPackage ./develop/opencode.nix   { inherit blender-mcp mcp-searxng opencode-telegram godot-ai; };
      ruyi       = pkgs.callPackage ./develop/ruyi.nix       { inherit ruyi; };
      ruyi-beta  = pkgs.callPackage ./develop/ruyi-beta.nix  { inherit ruyi-beta; };
      ruyi-alpha = pkgs.callPackage ./develop/ruyi-alpha.nix { inherit ruyi-alpha; };
    };
  }) // {

    nixosModules.obs-bilibili-stream   = import ./modules/obs-bilibili-stream.nix;
    nixosModules.opencode-telegram     = import ./modules/opencode-telegram.nix;
    nixosModules.llama-cpp-rocm        = import ./modules/llama-cpp-rocm.nix;
    nixosModules.comfyui-rocm          = import ./modules/comfyui-rocm.nix;
    nixosModules.rcc-fix = import ./modules/rcc-fix.nix;
    nixosModules.ruyi                 = import ./modules/ruyi.nix;

    overlays = {
      default           = import ./overlays/default.nix;
      efl-cross-fix     = import ./overlays/efl-cross-fix.nix;
      llama-cpp-rocm    = import ./overlays/llama-cpp-rocm.nix { inherit llama-cpp-ver; };
      rcc-fix           = import ./overlays/rcc-fix.nix;
      ruyi-nixos-compat = import ./overlays/ruyi-nixos-compat.nix;
      "codewhale-sudo-fix" = import ./overlays/codewhale-sudo-fix.nix;
      breeze-black       = import ./overlays/breeze-black.nix;
      fastmcp            = import ./overlays/fastmcp.nix;
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
