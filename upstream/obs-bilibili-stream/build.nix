let
  # 求值入口：把草稿对着**一棵真的 nixpkgs 树**求值。
  #
  # 与 blender-mcp 的 build.nix 同一套办法：用 `builtins.getFlake "path:…"` 直接读，
  # 不复制树、不 chmod（对符号链接树递归 chmod 会打到 nix store，本仓踩过）。
  pkgs0 = import (builtins.getFlake "path:${builtins.getEnv "NIXPKGS_PATH"}") {
    system = "x86_64-linux";
  };

  # 包定义引用 `lib.maintainers.grg41`，本地那棵 nixpkgs 里没有这个条目
  # ——它由同 PR 的第一个 commit 加进去。这里注入以模拟**合并之后**的状态。
  grg41 = {
    email = "gr@g41.moe";
    github = "GrG41";
    githubId = 152935465;
    name = "戦術人形Ｇ４１";
  };

  pkgs = pkgs0.extend (
    final: prev: {
      lib = prev.lib.extend (libFinal: libPrev: {
        maintainers = libPrev.maintainers // { inherit grg41; };
      });
    }
  );
in
# OBS 插件用 Qt 时，nixpkgs 的惯例是走 qt6Packages.callPackage（见 plugins/default.nix），
# 由它注入 qtbase 等 Qt 包。所以这里也走那条路，与将来的落点一致。
pkgs.qt6Packages.callPackage ./package.nix { }
