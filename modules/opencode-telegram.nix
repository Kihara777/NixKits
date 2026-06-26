{ config, lib, pkgs, ... }:

let
  oldCfg = config.services.opencode-telegram or { };
  cfg = config.nixkits.opencode-telegram;
in
{
  options = {
    # Canonical option (new)
    nixkits.opencode-telegram = {
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

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        example = lib.literalExpression "[ pkgs.opencode ]";
        description = ''
          Extra packages whose `/bin` directories are prepended to the
          service's `PATH`. Use this when the bot needs to locate
          companion tools such as `opencode` that are not installed
          system-wide.
        '';
      };

      extraBinPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "/etc/profiles/per-user/kix/bin" ];
        description = ''
          Extra directory paths prepended to the service `PATH`.
          Useful for tools installed via home-manager whose `/bin`
          directories are not available through a Nix package
          reference.
        '';
      };
    };

    # Deprecated: services.opencode-telegram (moved to nixkits)
    services.opencode-telegram.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      visible = false;
      description = "Deprecated: use nixkits.opencode-telegram.enable instead";
    };
  };

  config = lib.mkMerge [
    {
      warnings = lib.optional (oldCfg ? enable && oldCfg.enable)
        "services.opencode-telegram is deprecated; use nixkits.opencode-telegram instead";

      # Bridge old enable to new
      nixkits.opencode-telegram.enable = lib.mkIf (oldCfg ? enable && oldCfg.enable) (lib.mkDefault true);
    }

    (lib.mkIf cfg.enable {
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
          KillMode = "process";
          User = cfg.user;
          Group = cfg.group;
        }
        // lib.optionalAttrs (cfg.extraPackages != [ ] || cfg.extraBinPaths != [ ] || cfg.environment != { }) {
          Environment = let
            pathParts =
              (lib.optional (cfg.extraPackages != [ ]) (lib.makeBinPath cfg.extraPackages))
              ++ cfg.extraBinPaths
              ++ [ "/run/current-system/sw/bin" ];
          in
            (lib.optional (pathParts != [ "/run/current-system/sw/bin" ] || cfg.extraBinPaths != [ ])
              "PATH=${lib.concatStringsSep ":" (builtins.filter (s: s != "") pathParts)}")
            ++ (lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment);
        };
      };
    })
  ];
}