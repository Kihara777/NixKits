{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.dsh;

  # dsh with third-party plugin packages injected into its node_modules tree.
  # Composition rows resolve package names from the dsh install root, so the
  # packages must be real directories in that tree: a symlink would be
  # realpathed back into the plugin's own store path and its peer imports
  # (@deepseek-ai/cordis etc.) would never reach dsh's node_modules.  The tar
  # round trip yields a builder-owned tree, chmod opens the node_modules dir
  # for the injection, and the plugin is then extracted in place.
  dshWithPlugins = pkgs.runCommand "${cfg.package.name}-with-plugins" { } ''
    mkdir -p "$out"
    tar -C ${cfg.package} -cf - . | tar -C "$out" -xf -
    NM="$out/lib/node_modules/@deepseek-ai/dsh/node_modules"
    chmod -R u+w "$NM"
    ${lib.concatMapStrings (p: ''
      tar -C ${p.package}/lib/node_modules -cf - . | tar -C "$NM" -xf -
    '') cfg.plugins.packages}
  '';

  dshPkg = if cfg.plugins.packages == [ ] then cfg.package else dshWithPlugins;

  # Generated cordis.patch.yml: user's extraPatch + declarative plugin
  # off-switches (disabled), config overrides (settings), and rows for
  # third-party plugin packages.  Written to $DSH_HOME/profiles/web by
  # preStart; dsh hot-reloads it at runtime.
  cordisPatch = pkgs.writeText "cordis.patch.yml" ''
    ${cfg.plugins.extraPatch}
    ${lib.concatMapStrings (id: "- id: ${id}\n  disabled: true\n") cfg.plugins.disabled}
    ${lib.concatStrings (lib.mapAttrsToList (id: conf: "- id: ${id}\n  config: ${builtins.toJSON conf}\n") cfg.plugins.settings)}
    ${lib.concatMapStrings (p: ''
      - id: ${p.id}
        name: ${builtins.toJSON p.name}
      ${lib.optionalString (p.config != { }) "  config: ${builtins.toJSON p.config}\n"}
    '') cfg.plugins.packages}
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
      packages = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            package = lib.mkOption {
              type = lib.types.package;
              description = "Plugin package (npm build with the package installed under lib/node_modules).";
            };
            id = lib.mkOption {
              type = lib.types.str;
              description = "Entry id for the generated cordis.patch.yml composition row.";
            };
            name = lib.mkOption {
              type = lib.types.str;
              description = "npm package name referenced by the composition row (e.g. @kihara777/dsh-nix-shell).";
            };
            config = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = "Row config rendered as YAML flow JSON.";
            };
          };
        });
        default = [ ];
        description = ''
          Third-party dsh plugin packages.  Each entry is injected into dsh's
          node_modules tree (Node module resolution makes it reachable from
          composition rows) and registered as a row in the generated
          cordis.patch.yml.
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

    skills = {
      enable = lib.mkEnableOption "register the NixKits skills as native dsh skill plugins (one composition row per skill)";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dsh-skill-nixkits;
        description = "Skill plugin package (@kihara777/dsh-skill-nixkits) embedding the NixKits skills.";
      };
    };

    sudo = {
      enable = lib.mkEnableOption "external sudo daemon for dsh-nix-shell (systemd socket-activated root executor)";
      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/nixkits-sudo.sock";
        description = "Unix socket path for the sudo executor; exported to the dsh service as NIXKITS_SUDO_SOCKET.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dsh-nix-shell;
        description = "Package providing the nixkits-sudo-exec executor script.";
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

    # NixKits skills as native dsh skill plugins: one composition row per
    # skill, each plugin registering its own content via ctx.skills.register
    # (runtime provider, rank 250 — outranking the filesystem roots).
    nixkits.dsh.plugins.packages = lib.mkIf cfg.skills.enable (
      builtins.map (skillId: {
        package = cfg.skills.package;
        id = "skill-nixkits-${skillId}";
        name = "@kihara777/dsh-skill-nixkits/${skillId}";
      }) [
        "nixkits-check-updates"
        "nixkits-skills"
        "nixos-modern-cli"
        "recover-nixos-config"
        "translate-pseudocn"
        "write-maintenance-log"
        "write-project-docs"
      ]
    );

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
        ExecStart = "${lib.getExe pkgs.nodejs} --expose-internals ${dshPkg}/lib/node_modules/@deepseek-ai/dsh/lib/bin.js web --host ${cfg.host} --port ${toString cfg.port} ${lib.concatMapStringsSep " " (h: "--trusted-host ${h}") cfg.trustedHosts}";
        WorkingDirectory = cfg.dshHome;
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 30;
        User = cfg.user;
        Group = cfg.group;
        # HOME/DSH_HOME must be writable (system user default /var/empty is not);
        # merge with user-provided environment instead of overwriting.
        #
        # PATH: systemd's default PATH does not include the NixOS system
        # profile, so the built-in bash tool fails with "spawn bash ENOENT"
        # (dsh resolves the shell through the subprocess service against its
        # own PATH).  Inject the NixOS layout explicitly; the per-user
        # profile dir keeps tools installed for a normal-user deployment
        # (cfg.user) reachable from the service.
        Environment = [
          "HOME=${cfg.dshHome}"
          "DSH_HOME=${cfg.dshHome}"
          "PATH=/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/${cfg.user}/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin"
        ]
          ++ lib.optionals cfg.sudo.enable [ "NIXKITS_SUDO_SOCKET=${cfg.sudo.socketPath}" ]
          ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment;
      };
    };

    # External sudo daemon: a systemd socket-activated root executor.  The
    # socket is owned by the dsh service user (SocketUser + 0600), so only
    # that user can connect; every accepted connection runs one command as
    # root via the nixkits-sudo-exec script.  This deliberately equals
    # passwordless root for the dsh user — gate it behind cfg.sudo.enable and
    # prefer narrower alternatives when the sandbox permits sudo directly.
    systemd.sockets.nixkits-sudo = lib.mkIf cfg.sudo.enable {
      description = "NixKits sudo executor socket (dsh-nix-shell)";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ cfg.sudo.socketPath ];
      socketConfig = {
        SocketUser = cfg.user;
        SocketMode = "0600";
        Accept = true;
        RemoveOnStop = true;
      };
    };

    systemd.services."nixkits-sudo@" = lib.mkIf cfg.sudo.enable {
      description = "NixKits sudo executor (per-connection root command runner)";
      serviceConfig = {
        ExecStart = "${lib.getExe pkgs.nodejs} ${cfg.sudo.package}/lib/node_modules/@kihara777/dsh-nix-shell/bin/nixkits-sudo-exec.js";
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
        TimeoutStopSec = 30;
        # Runs as root by design — the socket gate above is the access
        # control boundary.
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

    services.lighttpd.extraConfig = lib.mkIf cfg.reverseProxy.enable ''
      $SERVER["socket"] == "0.0.0.0:${toString cfg.reverseProxy.port}" {
        proxy.server = ( "" => (("host" => "127.0.0.1", "port" => ${toString cfg.port})) )
        # dsh 的 /api/events.* 是 WebSocket（Upgrade: websocket）。
        # lighttpd 1.4.56+ 的 mod_proxy 原生支持 WebSocket 隧道，但必须
        # 显式开启 proxy.header 的 upgrade 转发，否则返回 426 Upgrade Required。
        #
        # 不能用 mod_wstunnel：NixOS 的 lighttpd 模块按 allKnownModules 固定
        # 顺序生成 server.modules，mod_wstunnel 永远排在 mod_proxy 之后，
        # mod_proxy 先接管请求（proxy.server 匹配所有路径）返回 426，
        # mod_wstunnel 因 r->handler_module 已非空而跳过，从不生效。
        proxy.header = ( "upgrade" => "enable" )
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
      }
    '';

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.reverseProxy.enable [ cfg.reverseProxy.port ];
  };
}
