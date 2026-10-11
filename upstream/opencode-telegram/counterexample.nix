let
  # 反证臂：造一个「把 linux-x64 预编译删掉」的派生，证明判据确实在量那个文件。
  #
  # **不手工改文件**——store 是只读的，而 `cp` 之后再 `chmod -R` 会顺着符号链接
  # 打到 /nix/store（本仓第一天踩过）。用 `overrideAttrs` 让 nix 自己产出那一份。
  pkgs0 = import (builtins.getFlake "path:${builtins.getEnv "NIXPKGS_PATH"}") {
    system = "x86_64-linux";
  };
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
  base = pkgs.callPackage ./package.nix { };
in
{
  inherit base;
  noPrebuild = base.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        rm -f "$out/lib/node_modules/@grinev/opencode-telegram-bot/node_modules/better-sqlite3/prebuilds/linux-x64.node"
      '';
  });
}
