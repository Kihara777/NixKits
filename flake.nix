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
    };

    formatter = pkgs.writeShellScriptBin "kitsfmt-fmt" ''
      exec ${kitsfmtDrv}/bin/kitsfmt -i "$@"
    '';

    devShells = let
      blenderMcpDrv = pkgs.callPackage ./packages/blender-mcp.nix { };
      mcpSearxngDrv = pkgs.callPackage ./packages/mcp-searxng.nix { };
      opencodeTelegramDrv = pkgs.callPackage ./packages/opencode-telegram.nix { };
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

      opencode = pkgs.mkShell {
        name = "opencode-dev";
        packages = [
          opencodeTelegramDrv
          pkgs.opencode
          pkgs.nodejs
          blenderMcpDrv
          pkgs.blender
          pkgs.python3
          mcpSearxngDrv
          pkgs.searxng
          pkgs.redis
        ] ++ (if (builtins.tryEval pkgs.godot-mcp).success
             then [ pkgs.godot-mcp pkgs.godot_4 ]
             else [ ]);
        shellHook = ''
          export BLENDER_PATH="${pkgs.blender}/bin/blender"
          export SEARXNG_SETTINGS_DIR="''${XDG_RUNTIME_DIR:-/tmp}/searxng-$$"
          mkdir -p "$SEARXNG_SETTINGS_DIR"
          cat > "$SEARXNG_SETTINGS_DIR/settings.yml" << YML
use_default_settings: true
search:
  formats:
    - html
    - json
server:
  bind_address: "127.0.0.1"
  port: 42999
  secret_key: "opencode-devshell-searxng-key"
YML
          redis-server --port 0 --unixsocket /tmp/searxng-redis-$$.sock --daemonize yes 2>/dev/null
          SEARXNG_SETTINGS_PATH="$SEARXNG_SETTINGS_DIR/settings.yml" \
            searxng-run &
          SEARXNG_PID=$!
          disown
          sleep 2
          export SEARXNG_URL="http://127.0.0.1:42999"
        '' + (if (builtins.tryEval pkgs.godot-mcp).success
             then "export GODOT_PATH=\"${pkgs.godot_4}/bin/godot\"\n"
             else "") + ''
          echo "opencode + mcp-searxng + blender-mcp + godot-mcp ready"
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
      efl-cross-fix     = import ./overlays/efl-cross-fix.nix;
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
