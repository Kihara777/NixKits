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
  pkgs = import (builtins.getFlake "path:${builtins.getEnv "NIXPKGS_PATH"}") {
    system = "x86_64-linux";
  };
in
pkgs.callPackage ./package.nix { }
