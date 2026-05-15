{ config, pkgs, lib, nix-kits, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = [ nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
  };
}
