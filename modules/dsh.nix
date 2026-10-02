{ config, lib, pkgs, ... }:

let
  cfg = config.nixkits.dsh;

  # 局域网设置读写补丁（见 packages/dsh.nix 的 allowLanSettings）。
  #
  # 跟随 reverseProxy.autoAuth —— 该开关的语义正是「让局域网浏览器无感使用
  # web UI」，也正是补丁需要的前提：页面经反代访问、authority 已列入
  # trustedHosts。关闭 autoAuth 时保持上游行为（非 loopback 页面设置只读），
  # 产物与上游逐字节一致。
  #
  # override 只在开启且包确实暴露该参数时使用：cfg.package 可能是用户传入的
  # 任意 dsh 派生（含不含本参数的第三方构建），hasAttr 探测避免 eval 报错。
  dshPackage =
    if cfg.reverseProxy.enable && cfg.reverseProxy.autoAuth
       && (cfg.package.override.__functionArgs or { }) ? allowLanSettings
    then cfg.package.override { allowLanSettings = true; }
    else cfg.package;

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
  dshWithPlugins = pkgs.runCommand "${dshPackage.name}-with-plugins" { } ''
    mkdir -p "$out"
    tar -C ${dshPackage} -cf - . | tar -C "$out" -xf -
    NM="$out/lib/node_modules/@deepseek-ai/dsh/node_modules"
    chmod -R u+w "$NM"
    ${lib.concatMapStrings (p: ''
      tar -C ${p.package}/lib/node_modules -cf - . | tar -C "$NM" -xf -
      chmod -R u+w "$NM"
    '') cfg.plugins.packages}
  '';

  dshPkg = if cfg.plugins.packages == [ ] then dshPackage else dshWithPlugins;

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
    ${lib.optionalString cfg.presets.newsThreeElements ''
      # 新闻三要素模式：独立包（dsh-preset-news-three-elements）只把预设
      # 安装到 store，这里把它注册为 agent-presets roster 的额外 root——
      # roster 每次调用都重扫 root，故预设直接取 store 内容，无需复制，也不
      # 会与 $DSH_HOME 里的旧副本漂移。配置根先于用户根被扫描，同名 id 由
      # 本 root 胜出（用户要改动请用 roster 的 copy() 另存为新 id）。
      # config 用 JSON 发出（JSON 是 YAML 子集，同 plugins.settings 的做法），
      # 免去手写嵌套 YAML 的缩进风险。注意 `- id:` 行替换**整份** config 而非
      # 合并：schema 里 `default` 必填，故必须一并带上（值取显式
      # settings."agent-presets".default，其次取结构化选项 agentPresets.default，
      # 都未给才沿用上游 "standard"；settings.yaml 是用户层，存在时仍以它为准，
      # 故两级声明不会互相打架）。
      - id: agent-presets
        config: ${builtins.toJSON {
          default =
            cfg.settings."agent-presets".default
            or (if cfg.agentPresets.enable then cfg.agentPresets.default else "standard");
          roots = [{
            path = "${cfg.presets.newsThreeElementsPackage}/share/dsh-agent-presets";
            trust = "system";
          }];
        }}
    ''}
  '';

  # Generated settings.yaml: declarative per-namespace dsh settings, JSON
  # (valid YAML).  Written to $DSH_HOME/settings.yaml by preStart; dsh
  # hot-reloads it.  Empty ({} or missing) resolves every namespace to
  # schema defaults.
  #
  # effectiveSettings folds the declarative structured options (when enabled)
  # under their settings namespaces; an explicit cfg.settings.<namespace> wins
  # over an injected section (left side of // loses).
  #
  # Why mirror upstream schemas as typed Nix options when cfg.settings already
  # accepts any namespace: the raw escape hatch is untyped, and schemastery
  # treats an object as open — an unknown key is *preserved* while the field it
  # was meant to be keeps its schema default (verified against
  # @deepseek-ai/schemastery in dsh 0.1.6-alpha.2:
  #   schema({ maxParallelToolCall: 4 }) => { maxParallelToolCalls: 10, maxParallelToolCall: 4 }
  # ), so a typo silently changes nothing AND says nothing.  A wrong type or an
  # out-of-range value is refused instead — at load it fails the namespace
  # registration outright, at runtime the settings plugin warns "keeping last
  # good \"<ns>\" after invalid stored section".  These options turn the whole
  # class into evaluation-time errors, typos included.
  #
  # Each namespace below is registered upstream by the named plugin calling
  # `settings.installSection(...)` (or `settings.register(...)`), and the field
  # names, types and ranges are copied from that schema (dsh 0.1.6-alpha.2).
  #
  # 写入策略（哪些字段用具体默认值、哪些用 null 表示「不声明」）：
  #   · schema 有默认值、且组合基线（内置 cordis.patch.yml 里该行的 config）
  #     与之一致 → 用具体默认值无条件写入，语义与不声明等价；
  #   · schema 无默认值（由部署/适配器/进程环境决定），或组合基线已偏离 schema
  #     默认（写全量会把基线悄悄改掉）→ 用 null 表示不声明，经 dropNulls 剔除。
  # 代价（有意接受）：第一类字段写进 settings.yaml 就成了显式用户值 —— 上游日后
  # 若改这几项的 schema 默认值，本机不跟随；第二类字段则始终跟随组合基线。
  # 每个字段的具体归属见其 description。
  dropNulls = lib.filterAttrs (_: v: v != null);

  # Node 定时器上限 MAX_TIMER_DELAY_MS = 2147483647：上游好几个字段的 schema 写
  # `.max(2147483647)`，超出即拒绝。直接用 addCheck 会沿用底层类型名，对 3e9 这种
  # 越界值报「必须是正数」——误导。模块系统渲染报错用的是 type.description，故这里
  # 连 description 一并改写，让报错说清是哪条约束。
  timerMs = lib.types.addCheck lib.types.numbers.positive (v: v <= 2147483647) // {
    name = "timerMs";
    description = "positive number no greater than 2147483647 (Node MAX_TIMER_DELAY_MS)";
    descriptionClass = "noun";
  };

  structuredSections =
    lib.optionalAttrs cfg.defaultModel.enable {
      "agent-default-model" = {
        provider = cfg.defaultModel.provider;
        model = cfg.defaultModel.model;
        reasoningEffort = cfg.defaultModel.reasoningEffort;
      };
    }
    // lib.optionalAttrs cfg.agentLoop.enable {
      # @deepseek-ai/dsh-agent-loop — schema: int >= 1, default 10.
      "agent-loop" = { maxParallelToolCalls = cfg.agentLoop.maxParallelToolCalls; };
    }
    // lib.optionalAttrs cfg.subagentModelSelection.enable {
      # @deepseek-ai/dsh-tool-subagent — gates the per-subagent model picker
      # and whitelists the routes it may offer.
      "subagent-model-selection" = {
        enabled = true;
        allowedModels = cfg.subagentModelSelection.allowedModels;
      };
    }
    // lib.optionalAttrs cfg.permission.enable {
      # @deepseek-ai/dsh-permission-presets — 权限预设（`defaultPreset`，
      # schema 里 `.required()`，必填）。
      # 枚举不是上游常量：settingsSchema 是 z.union(presets 表**键名**)，表本身
      # 来自组合行 config。内置 dsh-base 的表是三个预设
      # read-only / workspace-write / danger-full-access（无 auto：auto 只进
      # availablePresets，不进 settings 的 union）。若用
      # plugins.settings."permission".presets 换了表，这里的 enum 即失效，
      # 那时请改用 nixkits.dsh.settings."permission" 逃生舱。
      "permission" = { defaultPreset = cfg.permission.defaultPreset; };
    }
    // lib.optionalAttrs cfg.agentPresets.enable {
      # @deepseek-ai/dsh-agent-presets — AgentPresetSettingsSchema
      # （default: string、modeSelectionEnabled: boolean）。
      # 该插件走的是 settings.register 而非 installSection：base 层是组合行
      # config 的 `default` 与 `modeSelectionEnabled = true`，settings.yaml 是
      # 用户层，故本段**优先于** cordis.patch.yml 里 agent-presets 行的 default。
      "agent-presets" = {
        default = cfg.agentPresets.default;
        modeSelectionEnabled = cfg.agentPresets.modeSelectionEnabled;
      };
    }
    // lib.optionalAttrs cfg.subagent.enable {
      # @deepseek-ai/dsh-subagent — SubagentRuntime.Config。两个字段都是整数：
      # maxDepth 允许 0（不许再委派），maxActiveSubagents 至少 1。
      "subagent" = {
        maxDepth = cfg.subagent.maxDepth;
        maxActiveSubagents = cfg.subagent.maxActiveSubagents;
      };
    }
    // lib.optionalAttrs cfg.shell.enable {
      # @deepseek-ai/dsh-shell 拥有 "shell" 这个 namespace（它命名的是 ctx.shell
      # 能力而非某个实现），注册者是执行器：Linux 上是 dsh-bash-local（本机实际
      # 挂载的 dsh-bash-sandbox 继承其 Config），win32 上是 dsh-pwsh-local
      # （多一个 pwshPath，故那一个字段不镜像）。
      # cwd 与 timeoutMs 为 nullable —— 见上方写入策略：cwd 的 schema 没有默认
      # 值（回落进程工作目录），timeoutMs 的 schema 默认是 120000 但内置
      # bash-sandbox 行把它配成 60000，无条件写入会把 60000 悄悄改成 120000。
      "shell" = dropNulls {
        cwd = cfg.shell.cwd;
        timeoutMs = cfg.shell.timeoutMs;
        maxTimeoutMs = cfg.shell.maxTimeoutMs;
        maxOutputBytes = cfg.shell.maxOutputBytes;
        maxSpillBytes = cfg.shell.maxSpillBytes;
        graceMs = cfg.shell.graceMs;
      };
    }
    // lib.optionalAttrs cfg.webSearchDeepSeek.enable {
      # @deepseek-ai/dsh-web-search-deepseek — Config，七个字段：
      # apiKey / apiKeyEnv / baseURL / model / apiVersion / maxTokens / maxUses。
      # apiKey 刻意不镜像：它 role("secret")，写进 settings.yaml 就等于把 API key
      # 落到 /nix/store（世界可读），该用 apiKeyEnv + 凭据库。
      "web-search-deepseek" = dropNulls {
        apiKeyEnv = cfg.webSearchDeepSeek.apiKeyEnv;
        baseURL = cfg.webSearchDeepSeek.baseURL;
        model = cfg.webSearchDeepSeek.model;
        apiVersion = cfg.webSearchDeepSeek.apiVersion;
        maxTokens = cfg.webSearchDeepSeek.maxTokens;
        maxUses = cfg.webSearchDeepSeek.maxUses;
      };
    }
    // lib.optionalAttrs cfg.llmDeepSeek.enable {
      # @deepseek-ai/dsh-llm-deepseek — NS = "llm-deepseek"，Config 镜像了其中
      # 连接与上限相关的字段。**未镜像**（需要时走逃生舱）：
      #   · models：内置模型目录（DEFAULT_MODELS），随 dsh 版本漂移，与
      #     defaultModel.model 同一类陷阱；
      #   · retryPolicy：两种策略对象的 union + 未知键白名单校验，镜像进 Nix
      #     收益低、腐化快；
      #   · filesApi* / maxRequestFilesBytes / *Image* / imageOffload*Quantum：
      #     文件 API 与图片卸载的内部字节预算，不是部署该调的旋钮。
      "llm-deepseek" = dropNulls {
        protocol = cfg.llmDeepSeek.protocol;
        apiKeyEnv = cfg.llmDeepSeek.apiKeyEnv;
        baseURL = cfg.llmDeepSeek.baseURL;
        thinking = cfg.llmDeepSeek.thinking;
        reasoningEffort = cfg.llmDeepSeek.reasoningEffort;
        maxTokens = cfg.llmDeepSeek.maxTokens;
        defaultContextWindow = cfg.llmDeepSeek.defaultContextWindow;
        streamIdleTimeoutMs = cfg.llmDeepSeek.streamIdleTimeoutMs;
      };
    }
    // lib.optionalAttrs cfg.locale.enable {
      # @deepseek-ai/dsh-client-locale — BCP 47 id; shipped ids are zh, en.
      "locale" = { preference = cfg.locale.preference; };
    }
    // lib.optionalAttrs cfg.ui.theme.enable {
      # @deepseek-ai/dsh-client-ui-theme
      "ui-theme" = {
        preference = cfg.ui.theme.preference;
        fontSize = cfg.ui.theme.fontSize;
      };
    }
    // lib.optionalAttrs cfg.ui.chat.enable {
      # @deepseek-ai/dsh-client-ui-chat — completed-Turn transcript density.
      "ui-chat" = { transcriptView = cfg.ui.chat.transcriptView; };
    }
    // lib.optionalAttrs cfg.ui.conversation.enable {
      # @deepseek-ai/dsh-client-ui-conversation — plain Enter while busy.
      "ui-conversation" = { busyEnter = cfg.ui.conversation.busyEnter; };
    };
  effectiveSettings = structuredSections // cfg.settings;
  settingsDoc = pkgs.writeText "settings.yaml" (builtins.toJSON effectiveSettings);

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

    # 新会话默认模型：结构化选项，经 settings.agent-default-model 注入。
    # 默认 off（不注入），启用时用本选项的 provider/model/reasoningEffort
    # 生成 agent-default-model 段；若 cfg.settings 已显式给出
    # "agent-default-model"，则以显式值为准（本选项仅作未配置时的回退）。
    defaultModel = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "inject a default agent model under settings.agent-default-model";
          provider = lib.mkOption {
            type = lib.types.str;
            default = "deepseek-official";
            description = "Model provider route id (e.g. deepseek-official).";
          };
          model = lib.mkOption {
            type = lib.types.str;
            default = "deepseek-flash";
            description = ''
              Default DeepSeek model id.  The upstream catalogue is built into
              the dsh adapter and moves with the dsh version: stable
              0.1.5-rc.2 and alpha 0.1.6-alpha.1 list four ids
              (deepseek-flash, deepseek-v4-flash, deepseek-v4-pro,
              deepseek-v4-flash-vision-exp), while alpha 0.1.6-alpha.2 lists
              only deepseek-flash and deepseek-v4-pro — upstream retired the
              other two on 2026-09-10 when DeepSeek-V4.1-Flash landed.

              An id the catalogue does not carry is NOT equivalent: dsh treats
              it as a text-only model, and the two failure paths differ.  A
              newly attached image is rejected outright at prompt admission
              (MODEL_DOES_NOT_SUPPORT_IMAGES, surfaced in the UI), while images
              already in the conversation are silently replaced by text
              placeholders before dispatch.

              deepseek-flash is the only id all three catalogues carry, and it
              declares the image modality in all three.  The other
              image-capable id, deepseek-v4-flash-vision-exp, appears only in
              the two older catalogues (stable 0.1.5-rc.2 and alpha
              0.1.6-alpha.1) and upstream retired it on 2026-09-10, so it is
              not a safe default.
            '';
          };
          reasoningEffort = lib.mkOption {
            type = lib.types.enum [ "off" "low" "high" "max" ];
            default = "off";
            description = "Default reasoning effort; 'off' maps to non-thinking (incl. FIM's non-thinking-only use).";
          };
        };
      };
      default = { };
      description = ''
        Declarative default agent model for new sessions, injected into
        nixkits.dsh.settings under the "agent-default-model" namespace when
        enable = true (backed by \@deepseek-ai/dsh-agent-default-model).  An
        explicit nixkits.dsh.settings."agent-default-model" always wins.
      '';
    };

    # ── 其余结构化 settings 命名空间 ────────────────────────────────────
    # 下面每个选项镜像一个上游插件经 `settings.installSection(...)` 注册的
    # settings schema（dsh 0.1.6-alpha）。语义一致：
    #   · 未 enable 时**不写入** settings.yaml，该命名空间回落 schema 默认；
    #   · 若 nixkits.dsh.settings 里显式给出同名命名空间，则以显式值为准。
    # 想声明这里没镜像的命名空间，仍可用 nixkits.dsh.settings 逃生舱。

    agentLoop = {
      enable = lib.mkEnableOption "inject settings.agent-loop (backed by \@deepseek-ai/dsh-agent-loop)";
      maxParallelToolCalls = lib.mkOption {
        type = lib.types.ints.positive;
        default = 10;
        description = ''
          Upper bound on how many tool calls one agent turn may run
          concurrently.  Upstream schema: integer >= 1, default 10.
        '';
      };
    };

    subagentModelSelection = {
      enable = lib.mkEnableOption "inject settings.subagent-model-selection (backed by \@deepseek-ai/dsh-tool-subagent)";
      allowedModels = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            provider = lib.mkOption {
              type = lib.types.str;
              description = "Provider route id (e.g. deepseek-official, llama-local).";
            };
            model = lib.mkOption {
              type = lib.types.str;
              description = "Model id within that provider.";
            };
          };
        });
        default = [ ];
        example = [
          {
            provider = "deepseek-official";
            model = "deepseek-flash";
          }
        ];
        description = ''
          Routes the per-subagent model picker may offer.  Empty (the upstream
          default) means the roster is unrestricted.  Enabling this option also
          turns the section's own `enabled` flag on — that flag is what enables
          the feature at all, so the two cannot be set independently here.
        '';
      };
    };

    # ── 宿主侧 settings 命名空间（自 2026-10-02 起补全）────────────────────
    # 下列选项镜像的是宿主能力插件的 schema：permission / agent-presets /
    # subagent / shell / web-search-deepseek / llm-deepseek。每个 description
    # 都写明注册它的上游包与 schema 出处，字段约束照抄 schema，不放宽。

    permission = {
      enable = lib.mkEnableOption "注入 settings.permission（由 \@deepseek-ai/dsh-permission-presets 注册）";
      defaultPreset = lib.mkOption {
        type = lib.types.enum [ "read-only" "workspace-write" "danger-full-access" ];
        default = "workspace-write";
        description = ''
          新会话默认使用的权限预设（sandbox + approval 打包）。上游 schema 是
          `{ defaultPreset: <presets 表键名 union>.required() }`，故必填。

          这里的三个取值来自内置 dsh-base 组合的 presets 表，**不是固定枚举**：
          表由组合行 config 给出，schema 只认表里的键名。本机组合的
          sandbox/approval 默认值（workspace-write + ask）推出的预设即
          `workspace-write`，这也是本选项的默认值。用
          `nixkits.dsh.plugins.settings."permission".presets` 换了表之后，
          请改用 `nixkits.dsh.settings."permission"`（逃生舱）声明。

          `auto`（按次审查）不在本枚举内：它只出现在客户端的可选列表里，不进
          settings schema 的 union；`custom` 是"当前组合不匹配任何预设"的派生
          状态，从来不是可写入的值。
        '';
      };
    };

    agentPresets = {
      enable = lib.mkEnableOption "注入 settings.agent-presets（由 \@deepseek-ai/dsh-agent-presets 注册）";
      default = lib.mkOption {
        type = lib.types.str;
        default = "standard";
        description = ''
          新会话默认挂载的预设 id。预设 id 由 roster 决定（内置 root 随 dsh 分发、
          `$DSH_HOME/.agent-presets` 是用户自建、`nixkits.dsh.presets.*` 另注册
          系统 root），无法在此枚举，故为自由字符串。

          schema 里 `default: z.string()` **没有默认值**，靠组合行 config 的
          `default: standard` 兜底；本选项因此显式写入。settings.yaml 是用户层，
          优先级高于组合行，故本选项一旦 enable 就压过 cordis.patch.yml 里
          agent-presets 行的 default（该行值仍会跟随本选项，见 cordisPatch）。
        '';
      };
      modeSelectionEnabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          是否在界面上提供「会话级切换预设」的入口。上游组合基线（settings.register
          的 base 层）为 true；本选项写入 settings.yaml 后覆盖它。
        '';
      };
    };

    subagent = {
      enable = lib.mkEnableOption "注入 settings.subagent（由 \@deepseek-ai/dsh-subagent 注册）";
      maxDepth = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 1;
        description = ''
          子代理可再派生子代理的最大深度；0 表示禁止再派生。上游 schema:
          integer >= 0（上界 Number.MAX_SAFE_INTEGER），default 1。
        '';
      };
      maxActiveSubagents = lib.mkOption {
        type = lib.types.ints.positive;
        default = 8;
        description = ''
          同时活跃的子代理上限。上游 schema: integer >= 1（上界
          Number.MAX_SAFE_INTEGER），default 8。
        '';
      };
    };

    shell = {
      enable = lib.mkEnableOption "注入 settings.shell（由 \@deepseek-ai/dsh-shell 拥有，执行器注册：Linux 走 \@deepseek-ai/dsh-bash-local / \@deepseek-ai/dsh-bash-sandbox，win32 走 \@deepseek-ai/dsh-pwsh-local）";
      # cwd 与 timeoutMs 为 nullable，其余四项用 schema 默认值（它们的组合基线
      # 与默认值一致，写入即等价）：本 namespace 的 cwd 无 schema 默认，而
      # timeoutMs 被内置 bash-sandbox 行刻意配成 60000（schema 默认 120000）——
      # 全量写入会把它悄悄改回 120000，正是本模块存在的意义所要防的「静默改值」。
      cwd = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          命令的默认工作目录。上游 schema: string，**无默认值** —— 未给出时执行器
          回落进程工作目录（本模块的服务单元把 dsh 的 WorkingDirectory 设为
          DSH_HOME，故基线即 DSH_HOME）。null = 不声明。
        '';
      };
      timeoutMs = lib.mkOption {
        type = lib.types.nullOr lib.types.numbers.positive;
        default = null;
        description = ''
          单条命令的默认超时（毫秒）。上游 schema: number，default 120000；但
          校验函数要求正有限值，且内置 bash-sandbox 行把它配置为 60000，故本机基线
          是 60 秒。null = 不声明（保留 60000）。填 120000 即显式改回上游默认。
        '';
      };
      maxTimeoutMs = lib.mkOption {
        type = lib.types.numbers.positive;
        default = 600000;
        description = ''
          单条命令超时的上限（毫秒）：调用方请求的 timeoutMs 会被截到此值。上游
          schema: number，default 600000（与内置组合基线一致）。
        '';
      };
      maxOutputBytes = lib.mkOption {
        type = lib.types.numbers.positive;
        default = 64000;
        description = ''
          单条命令回传给模型的输出字节上限（超出部分落 spill 文件）。上游 schema:
          number，default 64000（与内置组合基线一致）。
        '';
      };
      maxSpillBytes = lib.mkOption {
        type = lib.types.numbers.positive;
        default = 67108864;
        description = ''
          单条命令 spill（截断输出转存）的字节上限。上游 schema: number，default
          67108864（64 MiB，与内置组合基线一致）。
        '';
      };
      graceMs = lib.mkOption {
        type = timerMs;
        default = 3000;
        description = ''
          超时后 SIGTERM → SIGKILL 的宽限时间（毫秒）。上游 schema: number，
          default 3000（与内置组合基线一致）；校验另加一条
          `graceMs <= 2147483647`（Node 定时器上限 MAX_TIMER_DELAY_MS），本选项用
          共享类型 timerMs 照抄该上界（越界时报错会写明上界，而非只说"必须是正数"）。
        '';
      };
    };

    webSearchDeepSeek = {
      enable = lib.mkEnableOption "注入 settings.web-search-deepseek（由 \@deepseek-ai/dsh-web-search-deepseek 注册）";
      apiKeyEnv = lib.mkOption {
        type = lib.types.str;
        default = "DEEPSEEK_API_KEY";
        description = ''
          解析 API key 用的凭据引用（环境变量名）。上游 schema: string，
          default DEEPSEEK_API_KEY（内置组合行也显式写了同一个值）。
        '';
      };
      baseURL = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          辅助搜索接口地址。上游 schema: string，**无默认值**：未给出时的解析顺序是
          `$DEEPSEEK_SEARCH_BASE_URL` → 字面量
          https://api.deepseek.com/anthropic/v1。写死字面量会遮蔽环境变量，
          故用 null 表示不声明。
        '';
      };
      model = lib.mkOption {
        type = lib.types.str;
        default = "deepseek-v4-flash";
        description = ''
          搜索后端使用的模型 id。上游 schema: string，default deepseek-v4-flash
          （模型 id 由接口侧决定，不在 schema 里枚举，故为自由字符串）。
        '';
      };
      apiVersion = lib.mkOption {
        type = lib.types.str;
        default = "2023-06-01";
        description = "Anthropic 兼容接口的 api-version 头。上游 schema: string，default 2023-06-01。";
      };
      maxTokens = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4096;
        description = "单次搜索请求的输出 token 上限。上游 schema: integer >= 1，default 4096。";
      };
      maxUses = lib.mkOption {
        type = lib.types.ints.positive;
        default = 5;
        description = "一次请求里允许的搜索调用次数上限。上游 schema: integer >= 1，default 5。";
      };
    };

    llmDeepSeek = {
      enable = lib.mkEnableOption "注入 settings.llm-deepseek（由 \@deepseek-ai/dsh-llm-deepseek 注册）";
      protocol = lib.mkOption {
        type = lib.types.enum [ "chat-completions" "messages" ];
        default = "messages";
        description = ''
          与 DeepSeek 通信的协议。上游 schema: union(chat-completions|messages)，
          default messages。
        '';
      };
      apiKeyEnv = lib.mkOption {
        type = lib.types.str;
        default = "DEEPSEEK_API_KEY";
        description = ''
          解析 API key 用的凭据引用。上游 schema: string，default
          DEEPSEEK_API_KEY。密钥本身不经本模块（服务经 systemd
          LoadCredential 注入环境变量）。
        '';
      };
      baseURL = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          接口地址。上游 schema: string，**无默认值**：未给出时按
          `$DEEPSEEK_BASE_URL` → https://api.deepseek.com 解析。写死字面量会遮蔽
          环境变量，故用 null 表示不声明。
        '';
      };
      thinking = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "enabled" "disabled" ]);
        default = null;
        description = ''
          是否启用思考。上游 schema: union(enabled|disabled)，**无默认值** —— 上游
          组合注释明确写着"Thinking defaults are a deployment choice"，故留 null
          表示由部署/适配器决定，而非由 Nix 单方面拍板。

          约束：`disabled` 只允许搭配 reasoningEffort = off（或省略）；二者冲突时
          适配器会拒绝该段，本模块用 assertion 把它提前到求值期。
        '';
      };
      reasoningEffort = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "off" "low" "high" "max" ]);
        default = null;
        description = ''
          推理力度。上游 schema: union(off|low|high|max)，**无默认值**（适配器按
          high 处理）。null = 不声明。

          与 nixkits.dsh.defaultModel.reasoningEffort 的区别：那一项写的是
          `agent-default-model`（新会话选择），本项写的是适配器自身的连接段。
        '';
      };
      maxTokens = lib.mkOption {
        type = lib.types.ints.positive;
        default = 256000;
        description = "单次请求的输出 token 上限。上游 schema: integer >= 1（上界 Number.MAX_SAFE_INTEGER），default 256000。";
      };
      defaultContextWindow = lib.mkOption {
        type = lib.types.ints.positive;
        default = 1000000;
        description = ''
          目录里未声明 contextWindow 的模型的回退上下文窗口。上游 schema:
          integer >= 1，default 1000000。
        '';
      };
      streamIdleTimeoutMs = lib.mkOption {
        type = timerMs;
        default = 300000;
        description = ''
          流式响应**相邻两块之间**的空闲超时（毫秒，不是整请求墙钟）。上游 schema:
          number，default 300000（5 分钟，与内置组合基线一致）；校验另加
          `<= 2147483647`（MAX_TIMER_DELAY_MS），共享类型 timerMs 照抄该上界。

          注意它是「分块间隔」超时：服务端在 prefill 期间完全不发数据时，预填耗时
          即空闲间隔 —— llama-server 之类的本地后端正因此需要显式放大（本机
          llama-local 路由在 llm-pi-ai 行里调的是同一个旋钮）。
        '';
      };
    };

    locale = {
      enable = lib.mkEnableOption "inject settings.locale (backed by \@deepseek-ai/dsh-client-locale)";
      preference = lib.mkOption {
        type = lib.types.str;
        default = "zh";
        description = ''
          Explicit UI language as a BCP 47 id; the browser client currently
          ships `zh` and `en`.  Leaving the section out (the default) delegates
          to the browser's Accept-Language, which makes the UI language depend
          on whichever device opens it.
        '';
      };
    };

    ui = {
      theme = {
        enable = lib.mkEnableOption "inject settings.ui-theme (backed by \@deepseek-ai/dsh-client-ui-theme)";
        preference = lib.mkOption {
          type = lib.types.enum [ "light" "dark" "system" ];
          default = "system";
          description = "Built-in theme preference.  Upstream default: system.";
        };
        fontSize = lib.mkOption {
          type = lib.types.ints.between 12 17;
          default = 14;
          description = "Conversation content font size in px.  Upstream range: 12-17.";
        };
      };
      chat = {
        enable = lib.mkEnableOption "inject settings.ui-chat (backed by \@deepseek-ai/dsh-client-ui-chat)";
        transcriptView = lib.mkOption {
          type = lib.types.enum [ "normal" "compact" ];
          default = "compact";
          description = ''
            Presentation of a completed Turn's transcript: `compact` keeps the
            collapsible process disclosure, `normal` expands it.  Upstream
            default: compact.
          '';
        };
      };
      conversation = {
        enable = lib.mkEnableOption "inject settings.ui-conversation (backed by \@deepseek-ai/dsh-client-ui-conversation)";
        busyEnter = lib.mkOption {
          type = lib.types.enum [ "queue" "steer" ];
          default = "queue";
          description = ''
            What a plain Enter does while an agent is still busy: `queue` parks
            the message for the next Turn, `steer` injects it into the running
            one.  Upstream default: queue.
          '';
        };
      };
    };

    presets = {
      nixosMode = lib.mkEnableOption "seed the NixOS模式 agent preset (id `nixos`) into \$DSH_HOME/.agent-presets/nixos at service start";
      maintenanceMode = lib.mkEnableOption "seed the 维护模式 agent preset (id `maintenance`) into \$DSH_HOME/.agent-presets/maintenance at service start";
      newsThreeElements = lib.mkEnableOption "register the 新闻三要素模式 agent preset (id `news-three-elements`) as an extra agent-presets roster root from its own package (no copy into \$DSH_HOME)";
      newsThreeElementsPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dsh-preset-news-three-elements;
        defaultText = lib.literalExpression "pkgs.dsh-preset-news-three-elements";
        description = ''
          Package shipping the 新闻三要素模式 preset tree.  The directory it
          installs (`share/dsh-agent-presets`) is registered as an extra
          `agent-presets` roster root, so the preset is read straight out of the
          store on every roster call and is never copied into
          `$DSH_HOME/.agent-presets` — a rebuild is what updates it.
        '';
      };
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
            # 从 store 复制来的目录/文件是只读的，而 seed-once 的契约是「尊重
            # 用户后续编辑」——不放开写权限，用户改不动自己那份预设。
            chmod -R u+w ${cfg.dshHome}/.agent-presets/nixos
            chown -R ${cfg.user}:${cfg.group} ${cfg.dshHome}/.agent-presets/nixos
          fi
        ''}
        ${lib.optionalString cfg.presets.maintenanceMode ''
          if [ ! -e ${cfg.dshHome}/.agent-presets/maintenance ]; then
            mkdir -p ${cfg.dshHome}/.agent-presets
            cp -r /run/dsh/nixos-shell/lib/node_modules/@kihara777/dsh-nixos-shell/presets/maintenance-mode ${cfg.dshHome}/.agent-presets/maintenance
            chmod -R u+w ${cfg.dshHome}/.agent-presets/maintenance
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
    assertions =
      # `llm-deepseek` 段的跨字段约束：适配器 resolveAdapterOptions 里写着
      # `thinking === "disabled"` 时只允许 reasoningEffort 为 off（或省略），
      # 否则整段被拒绝。schema 表达不了这种耦合，故在求值期拦下 —— 与类型化
      # 选项同一目的：让错误在这里报，而不是在 dsh 运行期变成「保留上一份好值」
      # 的告警。
      lib.optional
        (cfg.llmDeepSeek.enable
          && cfg.llmDeepSeek.thinking == "disabled"
          && cfg.llmDeepSeek.reasoningEffort != null
          && cfg.llmDeepSeek.reasoningEffort != "off")
        {
          assertion = false;
          message = ''
            nixkits.dsh.llmDeepSeek: thinking = "disabled" 只允许 reasoningEffort = "off"
            （或省略 reasoningEffort）—— @deepseek-ai/dsh-llm-deepseek 会拒绝该段。
          '';
        }
      ++ lib.optionals cfg.reverseProxy.enable [
        {
          assertion = config.services.lighttpd.enable;
          message = "nixkits.dsh.reverseProxy requires services.lighttpd.enable = true";
        }
      ];

    # reverseProxy 依赖 mod_proxy（proxy.server/proxy.header）与 mod_setenv
    # （setenv.add-request-header）。早期版本依赖 SearXNG 模块顺带启用的这
    # 两个模块；core/headless 场景不再启用 SearXNG（只带 mod_access/mod_alias
    # 的轻量 lighttpd），必须在此显式声明，否则 lighttpd 未加载 mod_proxy，
    # proxy.server 配置被忽略，反代端口请求无 handler 而返回 403。
    # autoAuth 额外追加 mod_magnet。enableModules 是 types.listOf，与用户或
    # 其它模块的列表拼接而非覆盖。
    services.lighttpd.package = lib.mkIf (cfg.reverseProxy.enable && cfg.reverseProxy.autoAuth) lighttpdMagnet;
    services.lighttpd.enableModules = lib.mkIf cfg.reverseProxy.enable
      ([ "mod_proxy" "mod_setenv" ] ++ lib.optional cfg.reverseProxy.autoAuth "mod_magnet");

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
