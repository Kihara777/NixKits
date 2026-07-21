# ruyi devShell — RuyiSDK package manager for RISC-V development
{
  pkgs,
  ruyi,
}:

let
  ruyiOverlay = import ../overlays/ruyi-nixos-compat.nix;
  ruyiWithCompat = (ruyiOverlay (pkgs // { ruyi = ruyi; }) (pkgs // { ruyi = ruyi; })).ruyi;
in
pkgs.mkShell {
  name = "ruyi-dev";
  packages = [ ruyiWithCompat ];
  shellHook = ''
    echo "RuyiSDK $(ruyi --version 2>/dev/null | head -1)"
  '';
}