{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.dsh;

  # Generated cordis.patch.yml: user's extraPatch + declarative plugin
  # off-switches (disabled) and config overrides (settings).  Written to
  # $DSH_HOME/profiles/web by preStart; dsh hot-reloads it at runtime.
  cordisPatch = pkgs.writeText "cordis.patch.yml" ''
    ${cfg.plugins.extraPatch}
    ${lib.concatMapStrings (id: "- id: ${id}\n  disabled: true\n") cfg.plugins.disabled}
    ${lib.concatStrings (lib.mapAttrsToList (id: conf: "- id: ${id}\n  config: ${builtins.toJSON conf}\n") cfg.plugins.settings)}
  '';

  # Generated settings.yaml: declarative per-namespace dsh settings, JSON
  # (valid YAML).  Written to $DSH_HOME/settings.yaml by preStart; dsh
  # hot-reloads it.  Empty ({} or missing) resolves every namespace to
  # schema defaults.
  settingsDoc = pkgs.writeText "settings.yaml" (builtins.toJSON cfg.settings);
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

    trustedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Non-loopback hostnames/IPs trusted for /api access, passed as
        repeatable --trusted-host flags.  Required when exposing dsh via a
        reverse proxy: dsh validates the request Host header against
        loopback + this list (exact host:port, or port-less host matching
        any port), and same-origin checks the browser Origin.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8615;
      description = "Port for the dsh web service";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "dsh";
      description = "User to run the service as (set to a normal user for full /home access)";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "dsh";
      description = "Group to run the service as";
    };

    dshHome = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/dsh";
      description = ''
        DSH_HOME directory (settings.yaml, profiles, skills).  Defaults to
        /var/lib/dsh for the isolated system user; set to the user's own
        path (e.g. /home/<user>/.dsh) when running as a normal user.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for the service (e.g. DEEPSEEK_API_KEY)";
    };

    reverseProxy = {
      enable = lib.mkEnableOption "lighttpd reverse proxy to expose dsh on a non-loopback port";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8625;
        description = "Public port for the lighttpd reverse proxy";
      };
    };

    plugins = {
      disabled = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Plugin entry ids to disable (declarative off-switch).  Rendered as
          `- id: <id> / disabled: true` in the generated cordis.patch.yml.
        '';
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
        default = { };
        description = ''
          Plugin config overrides, keyed by entry id.  Rendered as
          `- id: <id> / config: { ... }` (JSON in YAML flow style) in the
          generated cordis.patch.yml.
        '';
      };
      extraPatch = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Raw cordis.patch.yml fragment appended to the generated patch —
          for hand-written entries such as MCP servers (insert lists).
        '';
      };
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = ''
        Declarative dsh settings (namespace -> section), rendered as
        \$DSH_HOME/settings.yaml.  The document is JSON (valid YAML) so it
        survives dsh's js-yaml parser; namespaces map to the settings UI
        sections and dsh hot-reloads external edits.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    users.users = lib.mkIf (cfg.user == "dsh") {
      dsh = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dshHome;
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
      preStart = ''
        mkdir -p ${cfg.dshHome}/profiles/web
        chown -R ${cfg.user}:${cfg.group} ${cfg.dshHome}
        # dsh's settings-file rewrites settings.yaml as owner-only/read-only;
        # preStart runs as the service user, so rm first (rm works on the
        # owning user's dir) then cp recreates a writable file.
        rm -f ${cfg.dshHome}/profiles/web/cordis.patch.yml ${cfg.dshHome}/settings.yaml
        cp ${cordisPatch} ${cfg.dshHome}/profiles/web/cordis.patch.yml
        cp ${settingsDoc} ${cfg.dshHome}/settings.yaml
      '';
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.nodejs} --expose-internals ${cfg.package}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js web --host ${cfg.host} --port ${toString cfg.port} ${lib.concatMapStringsSep " " (h: "--trusted-host ${h}") cfg.trustedHosts}";
        WorkingDirectory = cfg.dshHome;
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 30;
        User = cfg.user;
        Group = cfg.group;
        # HOME/DSH_HOME must be writable (system user default /var/empty is not);
        # merge with user-provided environment instead of overwriting.
        Environment = [ "HOME=${cfg.dshHome}" "DSH_HOME=${cfg.dshHome}" ]
          ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment;
      };
    };

    # dsh rejects non-loopback hosts (RCE safety), so expose it via a lighttpd
    # reverse proxy.  Reuses the lighttpd instance enabled by SearXNG (or the
    # user); lighttpd's extraConfig is types.lines so it merges cleanly.
    assertions = lib.mkIf cfg.reverseProxy.enable [
      {
        assertion = config.services.lighttpd.enable;
        message = "nixkits.dsh.reverseProxy requires services.lighttpd.enable = true";
      }
    ];

    services.lighttpd.enableModules = lib.mkIf cfg.reverseProxy.enable [ "mod_wstunnel" ];

    services.lighttpd.extraConfig = lib.mkIf cfg.reverseProxy.enable ''
      $SERVER["socket"] == "0.0.0.0:${toString cfg.reverseProxy.port}" {
        proxy.server = ( "" => (("host" => "127.0.0.1", "port" => ${toString cfg.port})) )
        setenv.add-request-header = (
          "X-Real-IP" => "%{remote-addr}e",
          "X-Forwarded-For" => "%{remote-addr}e",
          "X-Forwarded-Proto" => "http"
        )
        # Rewrite Host + Origin to the loopback backend so dsh's
        # isTrustedApiRequest sees loopback (no trustedHosts needed) and the
        # LAN hostname/IP is not leaked to the backend.  Origin must be
        # rewritten together with Host, otherwise the same-origin check fails.
        setenv.set-request-header = (
          "Host" => "127.0.0.1:${toString cfg.port}",
          "Origin" => "http://127.0.0.1:${toString cfg.port}"
        )
        # dsh's /api/events.* endpoints are WebSocket (Upgrade: websocket).
        # mod_proxy cannot carry the Upgrade; tunnel them via mod_wstunnel.
        $HTTP["url"] =~ "^/api/events" {
          wstunnel.server = ( "" => (("host" => "127.0.0.1", "port" => "${toString cfg.port}")) )
          wstunnel.frame-type = "text"
        }
      }
    '';

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.reverseProxy.enable [ cfg.reverseProxy.port ];
  };
}
