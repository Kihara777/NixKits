{ config, lib, ... }:
{
  config = lib.mkIf config.services.asusd.enable {
    systemd.services.asus-shutdown = {
      # 移除 PartOf 防止 asusd 停止时连带停止，导致死锁
      partOf = lib.mkForce [ ];
    };
  };
}
