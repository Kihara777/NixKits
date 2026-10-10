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
  grg41 = import ../maintainer-entry.nix;

  pkgs = pkgs0.extend (
    final: prev: {
      lib = prev.lib.extend (libFinal: libPrev: {
        maintainers = libPrev.maintainers // { inherit grg41; };
      });
    }
  );
in
# OBS 插件现在由 lib.packagesFromDirectoryRecursive 自动发现（见
# pkgs/applications/video/obs-studio/plugins.nix），用的是**普通的 pkgs.callPackage**。
# 所以 Qt 依赖要在包定义里写成 `qt6.qtbase`，而不是靠 qt6Packages 注入。
# 与当前 master 上 obs-color-monitor.nix 的写法一致。
pkgs.callPackage ./package.nix { }
