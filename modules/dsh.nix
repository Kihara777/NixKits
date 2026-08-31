{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.dsh;

  # dsh with third-party plugin packages injected into its node_modules tree.
  # Composition rows resolve package names from the dsh install root, so the
  # packages must be real directories in that tree: a symlink would be
  # realpathed back into the plugin's own store path and its peer imports
  # (@deepseek-ai/cordis etc.) would never reach dsh's node_modules.  The tar
  # round trip yields a builder-owned tree and chmod opens the node_modules
  # dir for the injection; each plugin is then extracted in place.  The chmod
  # must run again after EVERY extraction: GNU tar restores each directory's
  # archived mode (0555 for store trees) once its contents are in place, so
  # a scope dir created by the previous plugin would otherwise be unwritable
  # and the next extraction fails with "Cannot mkdir: Permission denied".
  dshWithPlugins = pkgs.runCommand "${cfg.package.name}-with-plugins" { } ''
    mkdir -p "$out"
    tar -C ${cfg.package} -cf - . | tar -C "$out" -xf -
    NM="$out/lib/node_modules/@deepseek-ai/dsh/node_modules"
    chmod -R u+w "$NM"
    ${lib.concatMapStrings (p: ''
      tar -C ${p.package}/lib/node_modules -cf - . | tar -C "$NM" -xf -
      chmod -R u+w "$NM"
    '') cfg.plugins.packages}
  '';

  dshPkg = if cfg.plugins.packages == [ ] then cfg.package else dshWithPlugins;

  # Generated cordis.patch.yml: user's extraPatch + declarative plugin
  # off-switches (disabled), config overrides (settings), and rows for
  # third-party plugin packages.  Written to $DSH_HOME/profiles/web by
  # preStart; dsh hot-reloads it at runtime.
  #
  # Row verbs matter: a bare `- id: …` row PATCHES an existing entry and
  # dsh drops it with "patch: entry … not found" when the entry does not
  # exist in the profile tree yet.  Each new entry is emitted as its own
  # `- insert:` op with the entry object indented under it (column 0 rows
  # would parse as separate patch ops), exactly like the MCP rows in the
  # user's extraPatch.  The entry object must live in the SAME '' string as
  # its `- insert:` line: a nested '' string is dedented by its own minimum
  # indent, which would push the rows back to column 0.
  cordisPatch = pkgs.writeText "cordis.patch.yml" ''
    ${cfg.plugins.extraPatch}
    ${lib.concatMapStrings (id: "- id: ${id}\n  disabled: true\n") cfg.plugins.disabled}
    ${lib.concatStrings (lib.mapAttrsToList (id: conf: "- id: ${id}\n  config: ${builtins.toJSON conf}\n") cfg.plugins.settings)}
    ${lib.concatMapStrings (p: ''
      - insert:
        - id: ${p.id}
          name: ${builtins.toJSON p.name}
        ${lib.optionalString (p.config != { }) "config: ${builtins.toJSON p.config}\n"}
    '') cfg.plugins.packages}
  '';

  # Generated settings.yaml: declarative per-namespace dsh settings, JSON
  # (valid YAML).  Written to $DSH_HOME/settings.yaml by preStart; dsh
  # hot-reloads it.  Empty ({} or missing) resolves every namespace to
  # schema defaults.
  settingsDoc = pkgs.writeText "settings.yaml" (builtins.toJSON cfg.settings);

  # External launch authorities: dsh prints its tokenized startup URL for
  # 127.0.0.1 only (localWebUrl hardcodes loopback, and --host 0.0.0.0 is
  # rejected upstream as RCE exposure).  LAN devices behind the reverse
  # proxy must authenticate against the external authority, so derive it
  # from trustedHosts: port-less entries get the reverse-proxy port.
  launchAuthorities = lib.map (h:
    if builtins.match ".*:[0-9]+$" h != null || !cfg.reverseProxy.enable
    then h
    else "${h}:${toString cfg.reverseProxy.port}"
  ) cfg.trustedHosts;

  # Writes the external launch URLs once dsh has printed its tokenized
  # startup URL.  A separate script (not an inline bash -c) because systemd
  # unit quoting does not understand bash's '\'' escapes for the grep
  # single quotes.
  launchUrlScript = pkgs.writeShellApplication {
    name = "dsh-launch-url";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep ];
    text = ''
      token=""
      for _ in $(seq 1 60); do
        # writeShellApplication runs under `set -e -o pipefail`; grep exits 1
        # on an empty log, so absorb it or the first poll kills the script.
        token=$(grep -oP 'token=\K[A-Za-z0-9_-]+' /run/dsh/web.log 2>/dev/null | head -1 || true)
        [ -n "$token" ] && break
        sleep 1
      done
      if [ -z "$token" ]; then
        echo "dsh: launch token not printed within 60s — launch URLs not written" >&2
        exit 0
      fi
      umask 077
      {
        echo "# dsh web launch URLs — open one from a LAN device to authenticate"
        echo "# (token rotates on every dsh restart; cookies stay valid until expiry)"
        ${lib.concatMapStringsSep "\n" (a: "echo \"http://${a}/?token=\$token\"") launchAuthorities}
      } > ${cfg.launchUrlFile}
      chown ${cfg.user}:${cfg.group} ${cfg.launchUrlFile}

      # 纯 token 文件：lighttpd mod_magnet (autoAuth) 读取它做免认证注入。
      # autoAuth 模式下 token 不再是秘密（反代会自动使用），world-readable。
      echo "$token" > /run/dsh/launch-token
      chmod 644 /run/dsh/launch-token
    '';
  };

  # lighttpd with mod_magnet (Lua) compiled in.  nixpkgs' lighttpd ships
  # enableMagnet=false by default; magnet is required for the autoAuth
  # launch-token injection.
  lighttpdMagnet = pkgs.lighttpd.override { enableMagnet = true; };

  # mod_magnet Lua script: transparently inject the launch token for LAN
  # devices that have not yet exchanged it for a session cookie.  Runs at
  # magnet.attract-raw-url-to (before URL parsing), so it reads the raw
  # request URI via lighty.env["request.uri"].
  dshAutoAuthScript = pkgs.writeText "dsh-auto-auth.lua" ''
    -- dsh auto-auth: transparently inject the launch token for LAN devices
    -- that have not yet exchanged it for a session cookie.
    local cookie = lighty.request["Cookie"] or ""
    if string.find(cookie, "dsh-auth-", 1, true) then
      return nil
    end

    local uri = lighty.env["request.uri"] or "/"
    -- Already carrying a token (our own redirect, or a manual one): let dsh
    -- exchange it for a signed cookie.  Injecting again would loop forever.
    if string.find(uri, "token=", 1, true) then
      return nil
    end

    local path = string.match(uri, "^([^?]*)")
    if path == "/" or path == "/index.html" then
      local f = io.open("/run/dsh/launch-token", "r")
      if f then
        local token = f:read("*l")
        f:close()
        if token and token ~= "" then
          lighty.header["Location"] = "/?token=" .. token
          return 302
        end
      end
    end
    return nil
  '';
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

    launchUrlFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        When set (and trustedHosts non-empty), dsh startup writes the
        authenticated launch URLs (http://<trusted-host>/?token=…) to this
        file.  dsh prints its token URL for 127.0.0.1 only; LAN devices
        behind the reverse proxy need the external-authority URL to
        exchange the launch token for a session cookie.  The token rotates
        on every dsh restart; issued cookies remain valid until expiry.
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
      autoAuth = lib.mkEnableOption ''
        transparently inject the dsh launch token so LAN devices reach the
        web UI with no manual authentication step.  This DISABLES dsh's
        entry authentication (token secrecy) — only enable when the local
        network is fully trusted, as any device that can reach the proxy
        port gains full dsh access (including its RCE surface).
      '';
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
              description = "npm package name referenced by the composition row (e.g. @kihara777/dsh-nixos-shell).";
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
          composition rows) and inserted as a new entry row under the
          `- insert:` op in the generated cordis.patch.yml.
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

    sudo = {
      enable = lib.mkEnableOption "external sudo daemon for nixos-shell (systemd socket-activated root executor)";
      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "/run/nixkits-sudo.sock";
        description = "Unix socket path for the sudo executor; exported to the dsh service as NIXKITS_SUDO_SOCKET.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dsh-nixos-shell;
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

    presets = {
      nixosMode = lib.mkEnableOption "seed the NixOS模式 agent preset (id `nixos`) into \$DSH_HOME/.agent-presets/nixos at service start";
      maintenanceMode = lib.mkEnableOption "seed the 维护模式 agent preset (id `maintenance`) into \$DSH_HOME/.agent-presets/maintenance at service start";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # 稳定挂载点（方案 C — 插件更新零重启）：dsh.service 与
    # nixkits-sudo@.service 的单元定义只引用 /run/dsh/* 稳定路径，
    # 插件包更新不再改变 unit 内容，switch-to-configuration 因此
    # 既不重启 dsh、也不 stop/start sudo socket（模板变更才重启），
    # 激活阶段对在途工具调用零中断。本激活脚本在每次 switch/boot
    # 时把符号链接翻到当前代的 store 路径；链接目标处于当前
    # toplevel 闭包内，GC 安全，回滚时自动翻回旧代路径。
    #
    # 插件更新后 dsh 仍在运行旧代码，需显式 `systemctl restart dsh`
    # 生效（nixos_shell 会把它自动分离到瞬态单元）；sudo 守护按
    # 连接生成，新连接自动使用新脚本。
    system.activationScripts.dshPlugins = ''
      mkdir -p /run/dsh
      ln -sfn ${dshPkg} /run/dsh/current
      ${lib.optionalString cfg.sudo.enable "ln -sfn ${cfg.sudo.package} /run/dsh/nixos-shell"}
      ${lib.optionalString (cfg.launchUrlFile != null && cfg.trustedHosts != [ ]) ''
        # launch-URL capture: systemd appends dsh's stdout here as the
        # service user, so the file must be pre-created and owned by them
        # (/run/dsh itself is root-owned).
        touch /run/dsh/web.log
        chown ${cfg.user}:${cfg.group} /run/dsh/web.log
      ''}
    '';

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

        # 插件包 ESM 解析：dsh 的 cordis-plugin-loader 以 profile 目录
        # ($DSH_HOME/profiles/web) 为解析基准（Node 24 内部 cascaded loader
        # 的 parentURL），从那里向上查找 node_modules。插件注入的 dsh store
        # 树经稳定挂载点 /run/dsh/current 访问（activation script 翻链），
        # store 不在 profile 的 node_modules 链上，直接 import 会
        # ERR_MODULE_NOT_FOUND。把注入后的 @kihara777 scope 链接到
        # $DSH_HOME/node_modules 下让 Node 可解析；符号链接 realpath 回
        # store 树，插件引用的 @deepseek-ai/* peer deps 仍在同树内可解析。
        ${lib.optionalString (cfg.plugins.packages != []) ''
          rm -rf ${cfg.dshHome}/node_modules
          mkdir -p ${cfg.dshHome}/node_modules
          ln -sfn /run/dsh/current/lib/node_modules/@deepseek-ai/dsh/node_modules/@kihara777 ${cfg.dshHome}/node_modules/@kihara777
        ''}

        # 种子预设（seed-once）：仅在目标不存在时复制，尊重用户后续对
        # ~/.dsh/.agent-presets/<id> 的编辑。NixOS模式预设（id `nixos`）
        # 随 dsh-nixos-shell 包分发（presets/nixos-mode：组合 + 元数据 +
        # 创造模式技能目录），非 NixOS 宿主由预设内的 nixos-gate 插件
        # 拒绝一切请求。
        ${lib.optionalString cfg.presets.nixosMode ''
          if [ ! -e ${cfg.dshHome}/.agent-presets/nixos ]; then
            mkdir -p ${cfg.dshHome}/.agent-presets
            cp -r /run/dsh/nixos-shell/lib/node_modules/@kihara777/dsh-nixos-shell/presets/nixos-mode ${cfg.dshHome}/.agent-presets/nixos
            chown -R ${cfg.user}:${cfg.group} ${cfg.dshHome}/.agent-presets/nixos
          fi
        ''}
        ${lib.optionalString cfg.presets.maintenanceMode ''
          if [ ! -e ${cfg.dshHome}/.agent-presets/maintenance ]; then
            mkdir -p ${cfg.dshHome}/.agent-presets
            cp -r /run/dsh/nixos-shell/lib/node_modules/@kihara777/dsh-nixos-shell/presets/maintenance-mode ${cfg.dshHome}/.agent-presets/maintenance
            chown -R ${cfg.user}:${cfg.group} ${cfg.dshHome}/.agent-presets/maintenance
          fi
        ''}
        ${lib.optionalString (cfg.launchUrlFile != null && cfg.trustedHosts != [ ]) ''
          # Truncate the launch-URL capture log so ExecStartPost only sees
          # this boot's token line (dsh prints it once at startup).
          : > /run/dsh/web.log
        ''}
      '';
      serviceConfig = {
        Type = "simple";
        # ExecStart 只引用稳定路径 /run/dsh/current（activation script 在每次
        # switch/boot 时翻链）——插件包更新不改变本 unit 的内容，switch 不再
        # 在激活阶段重启 dsh，在途工具调用零中断。
        ExecStart = "${lib.getExe pkgs.nodejs} --expose-internals /run/dsh/current/lib/node_modules/@deepseek-ai/dsh/lib/bin.js web --host ${cfg.host} --port ${toString cfg.port} ${lib.concatMapStringsSep " " (h: "--trusted-host ${h}") cfg.trustedHosts}";
        WorkingDirectory = cfg.dshHome;
        Restart = "always";
        # 快速恢复：dsh 上游有已知崩溃 bug（cordis-plugin-timer 的 Context
        # disposed，rc.6 实测 13 小时触发）；rc.7 尚未修复该上游问题，缩短
        # 重启间隔把中断窗口压到最小。always 覆盖 exit 0 退出（on-failure
        # 不重启 exit 0，dsh 某些异常路径会以 0 退出）。
        RestartSec = 5;
        TimeoutStopSec = 30;
        User = cfg.user;
        Group = cfg.group;
        # HOME/DSH_HOME must be writable (system user default /var/empty is
        # not); merge with user-provided environment instead of overwriting.
        #
        # HOME points at the service user's REAL home (falling back to
        # dshHome) so the agent inherits the user's own tooling context —
        # git/gh credentials (~/.config/gh), ~/.gitconfig, npm/ssh configs
        # all resolve from $HOME.  Pointing HOME at dshHome instead breaks
        # exactly that: git's gh credential helper looks for
        # $HOME/.config/gh/hosts.yml and silently finds no credentials.
        # DSH_HOME remains dsh's own state root (settings, profiles,
        # skills) and is unaffected.
        #
        # PATH: systemd's default PATH does not include the NixOS system
        # profile, so the built-in bash tool fails with "spawn bash ENOENT"
        # (dsh resolves the shell through the subprocess service against its
        # own PATH).  Inject the NixOS layout explicitly; the per-user
        # profile dir keeps tools installed for a normal-user deployment
        # (cfg.user) reachable from the service.
        Environment = [
          "HOME=${config.users.users.${cfg.user}.home or cfg.dshHome}"
          "DSH_HOME=${cfg.dshHome}"
          "PATH=/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/${cfg.user}/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin"
        ]
          ++ lib.optionals cfg.sudo.enable [ "NIXKITS_SUDO_SOCKET=${cfg.sudo.socketPath}" ]
          ++ lib.mapAttrsToList (k: v: "${k}=${v}") cfg.environment;
        # Capture dsh's stdout (it prints the tokenized startup URL once)
        # for ExecStartPost to derive the external launch URLs.
        StandardOutput = lib.mkIf (cfg.launchUrlFile != null && cfg.trustedHosts != [ ]) "append:/run/dsh/web.log";
        # Run as root ('+') to write the launch URL file under root-owned
        # /run/dsh and chown it to the service user.  The script polls the
        # capture log for dsh's token line, then derives one launch URL per
        # trusted host with the reverse-proxy port (dsh's own URL is
        # loopback-only).
        ExecStartPost = lib.mkIf (cfg.launchUrlFile != null && cfg.trustedHosts != [ ]) "+${lib.getExe launchUrlScript}";
      };
    };

    # 健康守护：nixos-rebuild 的 switch-to-configuration 在「stop dsh →
    # start dsh」之间偶发失败（exit 101）会把 dsh 留在 inactive ——
    # systemd 主动 stop 不触发 Restart=always，导致反代长期 503。用
    # timer 定期检查并拉起。
    systemd.services.dsh-watchdog = {
      description = "Ensure dsh is running";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl is-active --quiet dsh.service || ${pkgs.systemd}/bin/systemctl start dsh.service'";
      };
    };

    systemd.timers.dsh-watchdog = {
      description = "Periodically ensure dsh is running";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15s";
        OnUnitActiveSec = "15s";
      };
    };

    # External sudo daemon: a systemd socket-activated root executor.  The
    # socket is owned by the dsh service user (SocketUser + 0600), so only
    # that user can connect; every accepted connection runs one command as
    # root via the nixkits-sudo-exec script.  This deliberately equals
    # passwordless root for the dsh user — gate it behind cfg.sudo.enable and
    # prefer narrower alternatives when the sandbox permits sudo directly.
    systemd.sockets.nixkits-sudo = lib.mkIf cfg.sudo.enable {
      description = "NixKits sudo executor socket (nixos-shell)";
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
        # ExecStart 只引用稳定路径 /run/dsh/nixos-shell——插件包更新不改变
        # 本模板的内容，switch 不再 stop/start socket（不会杀死在途 @ 实例）。
        # 守护按连接生成：新连接自动使用翻链后的新脚本。
        ExecStart = "${lib.getExe pkgs.nodejs} /run/dsh/nixos-shell/lib/node_modules/@kihara777/dsh-nixos-shell/bin/nixkits-sudo-exec.js";
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

    # autoAuth: 换用带 mod_magnet 的 lighttpd，并追加该模块到 server.modules。
    # enableModules 是 types.listOf，与 SearXNG 的列表拼接而非覆盖。
    services.lighttpd.package = lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.autoAuth) lighttpdMagnet;
    services.lighttpd.enableModules = lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.autoAuth) [ "mod_magnet" ];

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
        # dsh 的 /api 浏览器信任鉴权用 --trusted-host 配置的 authority，
        # 而 web UI 入口（dsh ≥ 0.1.2-alpha）用基于 Host authority 的
        # session cookie 认证。这里不能重写 Host：重写会让后端看到的
        # authority 与浏览器实际访问的域名不一致，cookie 无法跨反代匹配，
        # 表现为永远 401。保持原始 Host，由 trustedHosts 授权局域网 authority。
        # X-Forwarded-* 保留给后端日志/审计。
        ${lib.optionalString cfg.reverseProxy.autoAuth ''
          # autoAuth（免认证）：无 dsh-auth cookie 的首页请求由 magnet 脚本
          # 302 注入当前 launch token，换取签名 cookie 后正常进入。
          magnet.attract-raw-url-to = ( "${dshAutoAuthScript}" )
        ''}
      }
    '';

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.reverseProxy.enable [ cfg.reverseProxy.port ];
  };
}
