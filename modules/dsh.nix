{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.dsh;
in
{
  options.nixkits.dsh = {
    enable = lib.mkEnableOption "DeepSeek Harness (DSH) web service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.dsh;
      description = "The dsh package to use";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Listen address for the dsh web service (dsh rejects non-loopback for safety — RCE)";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8625;
      description = "Port for the dsh web service";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "dsh";
      description = "User to run the service as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "dsh";
      description = "Group to run the service as";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for the service (e.g. DEEPSEEK_API_KEY)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == "dsh") {
      dsh = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/dsh";
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "dsh") {
      dsh = { };
    };

    systemd.services.dsh = {
      description = "DeepSeek Harness (DSH) web service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} web --host ${cfg.host} --port ${toString cfg.port} --expose-internals";
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 30;
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "dsh";
        # HOME/DSH_HOME must be writable (system user default /var/empty is not);
        # merge with user-provided environment instead of overwriting.
        Environment = [ "HOME=/var/lib/dsh" "DSH_HOME=/var/lib/dsh" ]
          ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment;
      };
    };
  };
}
