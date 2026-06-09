{ config, lib, pkgs, ... }:

let
  cfg = config.services.opencode-telegram;
in
{
  options.services.opencode-telegram = {
    enable = lib.mkEnableOption "OpenCode Telegram Bot service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode-telegram;
      description = "The opencode-telegram package to use";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "opencode-telegram";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "opencode-telegram";
      description = "Group to run the service as";
    };

    afterServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "network-online.target" ];
      description = "Services to start after";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for the service";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == "opencode-telegram") {
      opencode-telegram = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = lib.mkIf (cfg.group == "opencode-telegram") {
      opencode-telegram = { };
    };

    systemd.services.opencode-telegram = {
      description = "OpenCode Telegram Bot";
      after = cfg.afterServices;
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} start";
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 30;
        KillMode = "mixed";
        User = cfg.user;
        Group = cfg.group;
      } // lib.optionalAttrs (cfg.environment != { }) {
        Environment = lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment;
      };
    };
  };
}
