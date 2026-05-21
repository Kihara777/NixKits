{
  description = "NixKits - A comprehensive NixOS flake repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  } @ inputs:
  {
    # NixOS modules
    nixosModules.obs-bilibili-stream = import ./modules/obs-bilibili-stream.nix;

    # Overlays
    overlays = {
      # OBS Bilibili Stream plugin overlay
      obs-bilibili-stream = import ./overlays/obs-bilibili-stream.nix;

      # ROCm-accelerated llama.cpp with latest release tracking
      llama-cpp-rocm = import ./overlays/llama-cpp-rocm.nix;

      # RCC-FIX overlay for ASUS ROG Control Center
      rcc-fix = import ./overlays/rog-control-center-fix.nix;

      # kitsfmt formatter overlay
      kitsfmt = import ./overlays/kitsfmt.nix;

      # OpenCode Telegram Bot overlay
      opencode-telegram = import ./overlays/opencode-telegram.nix;

      # SearXNG MCP Server overlay
      mcp-searxng = import ./overlays/mcp-searxng.nix;
    };

    # Per-system packages
    packages = builtins.mapAttrs (system: _: let
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
      obsBiliStream = pkgs.callPackage ./packages/obs-bilibili-stream.nix {
        qtbase = pkgs.qt6.qtbase;
      };
      kitsfmt = pkgs.callPackage ./packages/kitsfmt.nix { };
      opencodeTelegram = pkgs.callPackage ./packages/opencode-telegram.nix { };
      mcpSearxng = pkgs.callPackage ./packages/mcp-searxng.nix { };
      isLinux = builtins.match ".*-linux" system != null;
    in {
      kitsfmt = kitsfmt;
      opencode-telegram = opencodeTelegram;
      mcp-searxng = mcpSearxng;
      default = kitsfmt;
    } // (lib.optionalAttrs isLinux {
      obs-bilibili-stream = obsBiliStream;
    })) {
      x86_64-linux = {};
      aarch64-linux = {};
    };
  };
}
