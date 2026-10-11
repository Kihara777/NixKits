let
  # 求值入口：把草稿对着**一棵真的 nixpkgs 树**求值。
  # 与另外两个草稿同一套办法：`builtins.getFlake "path:…"` 直接读，不复制树。
  pkgs0 = import (builtins.getFlake "path:${builtins.getEnv "NIXPKGS_PATH"}") {
    system = "x86_64-linux";
  };

  # 包定义引用 `lib.maintainers.grg41`，本地那棵 nixpkgs 里没有这个条目
  # ——它由本 PR 的第一个 commit 加进 maintainer-list.nix。
  # 这里注进去以模拟**合并之后**的状态。
  grg41 = import ../maintainer-entry.nix;

  pkgs = pkgs0.extend (
    final: prev: {
      lib = prev.lib.extend (
        libFinal: libPrev: {
          maintainers = libPrev.maintainers // { inherit grg41; };
        }
      );
    }
  );
in
pkgs.callPackage ./package.nix { }
