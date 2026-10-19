{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.obs-bilibili-stream;
in
{
  options.nixkits.obs-bilibili-stream = {
    enable = lib.mkEnableOption "Bilibili streaming plugin for OBS Studio";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio.plugins = [ pkgs.obs-bilibili-stream ];
  };
}
