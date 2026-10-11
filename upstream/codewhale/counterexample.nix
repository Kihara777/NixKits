let
  # 反证臂：造一份**去掉 postInstall** 的派生。
  # 用来证明「`codew` 符号链接存在」这条判据量的是我们的代码，不是碰巧。
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
  noAlias = base.overrideAttrs (_old: {
    postInstall = "";
  });
}
