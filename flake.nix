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
    # godot-ai 需要这两个 overlay **同时**链上：fastmcp/fastmcp-slim 要 4.0.5，
    # 其余运行时包要与 v4 fail-closed 校验表逐项相等（4.2.3 共 14 项）。
    # 两者缺一，`godot-ai --version` 都会崩在启动校验上。
    # ⚠️ 这里与 overlays/default.nix 是**两个落点**，必须同步——只改一处时构建产物
    # 仍用旧依赖：构建通过，运行即死（历史事故）。
    # 两文件都经 nixpkgs 的 `pythonPackagesExtensions` 挂载（可叠加），故与先后顺序无关。
    godotPkgs = (pkgs.extend self.overlays.fastmcp).extend self.overlays.godot-ai-v4-deps;
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
      # 同上，但预设内容**冻结**在 dsh-nixos-shell-stable.nix 钉住的 rev
      # （stable 通道用；默认变体跟仓库 HEAD）。modules/dsh.nix 按 dsh 通道自动
      # 二选一，不需要用户手写。
      dsh-nixos-shell-stable = pkgs.callPackage ./packages/dsh-nixos-shell-stable.nix { };
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
    # - doc-versions：文档版本号与包定义一致（四语 + 通道表）
    # - doc-counts：文档里能从源机械读出的计数与源一致（词典条数、自检项数）
    # - maintenance-log：四语条目数一致、时间戳精确、SHA 去重、pcn 无假名
    # - session-sources：预设插件写进会话的消息来源不得用 v3 旧形状（kind: "plugin"）
    # - self-tests：每个自检都必须能被「已知的坏输入」撞响（对照 + 注入 + 断言红得对）
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

      doc-versions = pkgs.runCommand "check-doc-versions" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-doc-versions.py
        touch $out
      '';

      doc-counts = pkgs.runCommand "check-doc-counts" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-doc-counts.py
        touch $out
      '';

      maintenance-log = pkgs.runCommand "check-maintenance-log" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-maintenance-log.py
        touch $out
      '';

      # 预设插件写进会话的消息来源不许用 v3 的旧形状（`kind: "plugin"`）：
      # dsh 0.2.0 的 v4 准入只拒这一个字面量，症状是整个 session「本机运行失败」。
      # 2026-10-03 实测：掌灯模式开局对账每开一个新会话就崩一次。
      session-sources = pkgs.runCommand "check-session-sources" {
        nativeBuildInputs = [ pkgs.python3 ];
      } ''
        cd ${self.outPath}
        python3 develop/check-session-sources.py
        touch $out
      '';

      # 每个自检都必须能被「已知的坏输入」撞响（对照 + 注入 + 断言红得对）：
      # 判据静默失灵过一次就不会自己说话——2026-10-05 一天里出现过三次。
      self-tests = pkgs.runCommand "check-self-tests" {
        nativeBuildInputs = [ pkgs.python3 pkgs.nodejs ];
      } ''
        cd ${self.outPath}
        python3 develop/check-selftests.py
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
    nixosModules.comfyui               = import ./modules/comfyui.nix;
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
      "codewhale-sudo-fix" = import ./overlays/codewhale-sudo-fix.nix;
      breeze-black       = import ./overlays/breeze-black.nix;
      fastmcp            = import ./overlays/fastmcp.nix;
      godot-ai-v4-deps   = import ./overlays/godot-ai-v4-deps.nix;
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
