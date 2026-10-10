let
  # 求值入口：把草稿包对着**一棵真的 nixpkgs 树**求值。
  #
  # 路径由环境变量 `NIXPKGS_PATH` 传入（`build.sh` 负责解析），
  # 所以这份文件里没有任何机器相关的硬编码路径。
  #
  # 为什么用 `builtins.getFlake "path:…"` 而不是复制 nixpkgs 树：
  # 复制会产生一棵满是符号链接的副本，而为了「让它可写」对它递归 chmod
  # 会顺着链接打到 nix store 里的真实目录（本仓踩过，见 skills/ 的陷阱清单）。
  # 直接读原树就没有这个问题。
  pkgs0 = import (builtins.getFlake "path:${builtins.getEnv "NIXPKGS_PATH"}") {
    system = "x86_64-linux";
  };

  # 包定义引用 `lib.maintainers.grg41`，而本地那棵 nixpkgs 里没有这个条目
  # ——它由本 PR 的**第一个 commit** 加进去。
  #
  # 所以这里把该条目注进去，模拟**合并之后**的状态：
  # 否则本地会因为「属性不存在」而失败，而那失败不反映真实情况
  # （PR 一旦落地，nixpkgs 的表里就有它了）。
  #
  # 三个字段与 `MAINTAINER-ENTRY.md` 里要插进 maintainer-list.nix 的**逐字相同**。
  grg41 = import ../maintainer-entry.nix;

  pkgs = pkgs0.extend (
    final: prev: {
      lib = prev.lib.extend (
        libFinal: libPrev: {
          maintainers = libPrev.maintainers // {
            inherit grg41;
          };
        }
      );
    }
  );
in
pkgs.callPackage ./package.nix { }
