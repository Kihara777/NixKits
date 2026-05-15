{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.obs-bilibili-stream;
in
{
  options.programs.obs-bilibili-stream = {
    enable = mkEnableOption "OBS Studio Bilibili streaming plugin";
  };

  config = mkIf cfg.enable {
    programs.obs-studio.plugins = [ pkgs.obs-bilibili-stream ];
  };
}
