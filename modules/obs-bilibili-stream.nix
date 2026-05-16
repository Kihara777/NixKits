{ config, pkgs, lib, nix-kits, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [ nix-kits.packages.x86_64-linux.obs-bilibili-stream ];
  };
}
