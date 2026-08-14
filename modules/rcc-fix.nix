{ config, lib, ... }:

let
  cfg = config.nixkits.rcc-fix;
in
{
  options.nixkits.rcc-fix = {
    enable = lib.mkEnableOption "rcc fix — ROG Control Center fix — prevent shutdown deadlock when asusd stops asus-shutdown.service";
  };

  config = lib.mkIf (cfg.enable && config.services.asusd.enable) {
    systemd.services.asus-shutdown = {
      # 移除 PartOf 防止 asusd 停止时连带停止，导致死锁
      partOf = lib.mkForce [ ];

      # asus-shutdown 上游设置 SendSIGKILL=no + KillMode=control-group，
      # 导致旧进程残留时 systemd 无法启动新实例，从而触发 systemd-switch 失败。
      # 覆盖为允许 SIGKILL，使 systemd 在重启时可强制终止旧进程。
      serviceConfig = {
        SendSIGKILL = lib.mkForce "yes";
        TimeoutStopSec = lib.mkForce "30s";
      };
    };
  };
}
