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
      dsh-alpha            = pkgs.callPackage ./packages/dsh-alpha.nix { };
      dsh-nixos-shell      = pkgs.callPackage ./packages/dsh-nixos-shell.nix { };
      dsh-api-balance      = pkgs.callPackage ./packages/dsh-api-balance.nix { };
      # 独立分发的 Agent 预设包（新闻三要素模式）：只装预设数据，模块把它
      # 注册为 agent-presets roster 的额外 root。
      dsh-preset-news-three-elements = pkgs.callPackage ./packages/dsh-preset-news-three-elements.nix { };
    };

    # 仓库自检集合，全部挂入 `nix flake check`（CI 每次 push 执行）：
    # - preset-derivation：维护模式必须完整派生自 NixOS模式
    # - preset-bundle：包内技能快照必须与 skills/ 树逐字节一致
    # - workflow-coverage：每个包都有构建 workflow（例外显式登记）
    # - doc-links：文档相对链接可达、语言切换器四语齐全
    # - maintenance-log：四语条目数一致、时间戳精确、SHA 去重、pcn 无假名
    # - news-mode-tests：新闻三要素模式插件的行为测试
    checks = {
      preset-derivation = pkgs.runCommand "check-preset-derivation" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-preset-derivation.py
        touch $out
      '';

      preset-bundle = pkgs.runCommand "check-preset-bundle" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-preset-bundle.py
        touch $out
      '';

      workflow-coverage = pkgs.runCommand "check-workflow-coverage" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-workflows.py
        touch $out
      '';

      doc-links = pkgs.runCommand "check-doc-links" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-doc-links.py
        touch $out
      '';

      maintenance-log = pkgs.runCommand "check-maintenance-log" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-maintenance-log.py
        touch $out
      '';

      news-mode-tests = pkgs.runCommand "check-news-mode-tests" {
        nativeBuildInputs = [ pkgs.nodejs ];
      } ''
        node ${./packages/dsh-preset-news-three-elements}/tests/mode.test.mjs
        touch $out
      '';
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
    nixosModules.dsh                   = import ./modules/dsh.nix;
    nixosModules.rcc-fix = import ./modules/rcc-fix.nix;
    nixosModules.asusd-pd-profile = import ./modules/asusd-pd-profile.nix;
    nixosModules.asusd-thermal-guard = import ./modules/asusd-thermal-guard.nix;
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
