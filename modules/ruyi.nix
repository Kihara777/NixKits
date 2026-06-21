{ config, lib, pkgs, ... }:

let
  oldCfg = config.services.ruyi or { };
  cfg = config.nixkits.ruyi;

  configToml = lib.concatStringsSep "\n" (
    lib.optional (cfg.settings.packages.prereleases) "[packages]\nprereleases = true"
    ++ lib.optional (cfg.settings.repo.local != null && cfg.settings.repo.local != "") "[repo]\nlocal = \"${cfg.settings.repo.local}\""
    ++ lib.optional (cfg.settings.repo.remote != "https://github.com/ruyisdk/packages-index.git") "[repo]\nremote = \"${cfg.settings.repo.remote}\""
    ++ lib.optional (cfg.settings.repo.branch != "main") "[repo]\nbranch = \"${cfg.settings.repo.branch}\""
    ++ lib.optional (cfg.settings.telemetry.mode != "local") "[telemetry]\nmode = \"${cfg.settings.telemetry.mode}\""
    ++ lib.optional (cfg.settings.telemetry.upload_consent != null) "[telemetry]\nupload_consent = \"${cfg.settings.telemetry.upload_consent}\""
    ++ lib.optional (cfg.settings.telemetry.pm_telemetry_url != null) "[telemetry]\npm_telemetry_url = \"${cfg.settings.telemetry.pm_telemetry_url}\""
  );
in
{
  options = {
    # Canonical option (new)
    nixkits.ruyi = {
      enable = lib.mkEnableOption "RuyiSDK package manager declarative configuration";

      package = lib.mkPackageOption pkgs "ruyi" { };

      settings = {
        packages.prereleases = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to consider pre-release versions when matching packages.";
        };

        repo = {
          local = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Local RuyiSDK metadata repository path.
              Must be absolute; ignored if empty or relative.
            '';
          };
          remote = lib.mkOption {
            type = lib.types.str;
            default = "https://github.com/ruyisdk/packages-index.git";
            description = "Remote URL of the RuyiSDK metadata repository.";
          };
          branch = lib.mkOption {
            type = lib.types.str;
            default = "main";
            description = "Branch name to use for the metadata repository.";
          };
        };

        telemetry = {
          mode = lib.mkOption {
            type = lib.types.enum [ "local" "off" "on" ];
            default = "local";
            description = ''
              Telemetry mode.
              - `local`: collect data locally but do not auto-upload (default).
              - `off`: do not collect or upload data.
              - `on`: collect and periodically upload data.
            '';
          };
          upload_consent = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Timestamp of user consent to upload telemetry.
              Set to current local time to hide the consent banner,
              e.g. `2024-12-02T15:51:00+08:00`.
            '';
          };
          pm_telemetry_url = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Override the telemetry server URL.";
          };
        };
      };

      telemetryOptout = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set `RUYI_TELEMETRY_OPTOUT=1` to completely disable telemetry.";
      };

      venv = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Explicitly set the Ruyi virtual environment via `RUYI_VENV`.";
      };

      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically run `ruyi update` after system activation to refresh the package index.";
      };

      buildTools = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "gnumake" "cmake" "ninja" "meson" ]);
        default = [ ];
        example = [ "gnumake" ];
        description = ''
          Build tools to provide system-wide when ruyi is enabled.
          These are injected into the ruyi runtime PATH so they are
          available inside ruyi venvs.
        '';
      };

      venvs = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            profile = lib.mkOption {
              type = lib.types.str;
              description = "Ruyi profile name (e.g. 'gnu-plct').";
            };
            toolchain = lib.mkOption {
              type = lib.types.str;
              description = "Toolchain specifier (e.g. 'gnu-plct').";
            };
            dest = lib.mkOption {
              type = lib.types.str;
              description = "Path to the virtual environment directory.";
            };
            emulator = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Emulator to use in the venv.";
            };
            sysroot = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Sysroot package specifier.";
            };
          };
        });
        default = { };
        description = "Declarative Ruyi virtual environments. Created on activation.";
      };
    };

    # Deprecated: services.ruyi (moved to nixkits)
    services.ruyi.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      visible = false;
      description = "Deprecated: use nixkits.ruyi.enable instead";
    };
  };

  config = lib.mkMerge [
    {
      warnings = lib.optional (oldCfg ? enable && oldCfg.enable)
        "services.ruyi is deprecated; use nixkits.ruyi instead";

      nixkits.ruyi.enable = lib.mkIf (oldCfg ? enable && oldCfg.enable) (lib.mkDefault true);
    }

    (lib.mkIf cfg.enable {
      environment.systemPackages = [ cfg.package ]
        ++ lib.optionals (lib.elem "gnumake" cfg.buildTools) [ pkgs.gnumake ]
        ++ lib.optionals (lib.elem "cmake" cfg.buildTools) [ pkgs.cmake ]
        ++ lib.optionals (lib.elem "ninja" cfg.buildTools) [ pkgs.ninja ]
        ++ lib.optionals (lib.elem "meson" cfg.buildTools) [ pkgs.meson ];

      system.activationScripts.ruyiUpdate = lib.mkIf cfg.autoUpdate ''
        if [ -x "${cfg.package}/bin/ruyi" ]; then
          echo "ruyi: updating package index..."
          RUYI_TELEMETRY_OPTOUT=1 ${cfg.package}/bin/ruyi update 2>&1 || true
        fi
      '';

      system.activationScripts.ruyiVenvs = let
        venvCommands = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: venv: ''
            echo "ruyi: creating venv ${name}..."
            RUYI_TELEMETRY_OPTOUT=1 ${cfg.package}/bin/ruyi venv \
              --toolchain ${venv.toolchain} \
              ${lib.optionalString (venv.emulator != null) "--emulator ${venv.emulator}"} \
              ${lib.optionalString (venv.sysroot != null) "--copy-sysroot-from-pkg ${venv.sysroot}"} \
              ${venv.profile} \
              ${venv.dest} 2>&1 || echo "ruyi: venv ${name} skipped (toolchain not installed yet)"
          '') cfg.venvs
        );
      in lib.mkIf (cfg.venvs != { }) ''
        echo "ruyi: setting up declarative virtual environments..."
        ${venvCommands}
      '';

      environment.etc."xdg/ruyi/config.toml".text = ''
        # Generated by NixKits nixkits.ruyi — do not edit manually.
        ${configToml}
      '';

      environment.variables = lib.mkMerge [
        (lib.mkIf cfg.telemetryOptout { RUYI_TELEMETRY_OPTOUT = "1"; })
        (lib.mkIf (cfg.venv != null) { RUYI_VENV = cfg.venv; })
      ];
    })
  ];
}
