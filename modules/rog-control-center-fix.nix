{ config, lib, ... }:

let
  cfg = config.nixkits.rog-control-center-fix;
in
{
  options.nixkits.rog-control-center-fix = {
    enable = lib.mkEnableOption "rog-control-center fix — prevent shutdown deadlock when asusd stops asus-shutdown.service";
  };

  config = lib.mkIf (cfg.enable && config.services.asusd.enable) {
    systemd.services.asus-shutdown = {
      # 移除 PartOf 防止 asusd 停止时连带停止，导致死锁
      partOf = lib.mkForce [ ];
    };
  };
}
