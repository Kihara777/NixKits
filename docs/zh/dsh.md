# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.1-rc.2` |
| 开发通道 | `dsh-alpha 0.1.2-alpha.3`（npm `alpha` dist-tag） |
| 许可 | MIT |
| 命令 | `dsh` |

## 版本通道

NixKits 仿 ruyi 的薄包装模式（主定义 + 版本/hash 覆盖包装）同时提供多个 dsh 版本：

| 包 | 通道 | 版本 | 说明 |
|----|------|------|------|
| `pkgs.dsh` | stable | `0.1.1-rc.2` | npm `latest` dist-tag，默认 |
| `pkgs.dsh-alpha` | alpha | `0.1.2-alpha.3` | npm `alpha` dist-tag，跟踪最新开发版 |

```nix
# 本机改用最新开发版本
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` 为上游开发通道：内置插件清单随版本变化（下文插件清单对应 stable `0.1.1-rc.2`，alpha 以运行时实际加载为准），升级前建议查看 [changelog](https://github.com/deepseek-ai/deepseek-harness/releases)。

## 安装

```nix
# /etc/nixos/flake.nix — 引入 flake 并挂载模块
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # nixosConfigurations.<host>.modules 中:
  #   nixkits.nixosModules.dsh
}
```

```nix
# 模块配置（启用后同时把 dsh 加入 systemPackages）
{ nixkits.dsh.enable = true; }
```

> **二进制缓存**：flake 已通过 `nixConfig` 声明缓存（`nixkits.cachix.org`），首次构建时 Nix 自动提示启用；手动启用：`cachix use nixkits`。

## 使用

```bash
dsh --help
dsh web   # 启动浏览器 UI
```

## 服务配置

作为常驻 web 服务运行，使用 `nixkits.dsh` 模块。dsh 出于 RCE 安全只监听 loopback（`127.0.0.1:8615`），通过 lighttpd 反向代理暴露到对外端口 `8625`（自动开放防火墙）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh 拒绝非 loopback
    port = 8615;          # 内部 loopback 端口
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外端口
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

### 局域网访问（trustedHosts + 启动 URL）

dsh ≥ 0.1.2-alpha 的 web UI 入口用基于 Host authority 的 session cookie 认证，反代**不再重写 Host**（重写会让后端看到的 authority 与浏览器实际访问的不一致，cookie 无法跨反代匹配，表现为永远 401）。局域网设备通过 `http://<host>:8625` 访问时，其 authority 必须列入 `trustedHosts`。dsh 打印的 token 启动 URL 仅限 127.0.0.1，`launchUrlFile` 让模块在 dsh 启动时（ExecStartPost 捕获启动输出）把局域网设备的认证 URL 写入指定文件：

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # 局域网 authority
    launchUrlFile = "/run/dsh/launch-urls";             # 启动 URL 输出文件
  };
}
```

> token 每次 dsh 重启轮换；换取到的 session cookie 在到期前持续有效。

### 免认证入口（autoAuth）

`reverseProxy.autoAuth` 用 lighttpd mod_magnet（模块自动换用 `enableMagnet` 编译的 lighttpd）在无 session cookie 的首页请求上 302 注入当前 launch token，局域网设备免手动认证一步直达。**该开关禁用 dsh 的入口认证（token 不再是秘密）**——仅当本地局域网完全可信时启用，否则任何能到达反代端口的设备都能获得完整 dsh 访问（含 RCE 面）：

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> 注意：autoAuth 假定由网络层安全方案（如隔离的 LAN）负责访问边界。

> **PATH**：模块自动为服务注入 NixOS 完整 PATH（`/run/current-system/sw/bin` 等）。没有它，systemd 默认 PATH 找不到 bash，内置 bash 工具会报 `spawn bash ENOENT`。

> **HOME**：服务 HOME 指向运行用户的真实家目录（`users.users.<user>.home`，缺省回退 dshHome），代理因此继承用户自身的工具上下文——git/gh 凭据（`~/.config/gh`）、`~/.gitconfig`、npm/ssh 配置全部按 `$HOME` 解析。若把 HOME 指向 dshHome，git 的 gh credential helper 会找不到凭据导致推送失败。

## 插件声明式管理

dsh 的插件通过 `cordis.patch.yml` 运行时热加载（无需重启）。`nixkits.dsh.plugins` 提供声明式启停与配置：

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # 禁用插件
    settings."dsh-web-app" = { printUrl = false; };           # 配置覆盖
    extraPatch = "...";  # 手写片段（如 MCP 服务 insert 列表）
  };
}
```

| 选项 | 说明 |
|------|------|
| `disabled` | 禁用的插件 entry id，渲染为 `- id: <id> / disabled: true` |
| `settings` | 插件 config 覆盖（id → JSON，YAML flow style） |
| `packages` | 第三方插件包：注入 dsh 的 node_modules 并生成组合行（见下文） |
| `extraPatch` | 手写 cordis.patch.yml 片段（如 MCP 服务） |

### 第三方插件包

`plugins.packages` 把第三方 npm 插件包注入 dsh 的 node_modules 树（组合行按包名解析，必须以真实目录存在——符号链接会被 Node realpath 回插件自身的 store 路径，导致 peer 依赖无法命中 dsh 树），并自动在生成的 cordis.patch.yml 中注册组合行：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nixos-shell;           # NixKits 包（npm 构建）
    id = "nixos-shell";                   # cordis.patch.yml entry id
    name = "@kihara777/dsh-nixos-shell";  # 组合行引用的 npm 包名
  }];
}
```

> **dsh ≥ 0.1.2-alpha 插件兼容**：`ctx.connection.rpc.intercept` 的 shared RPC channel interceptor 互斥（每 channel 仅一个，重复注册直接 throw），`/api` 已被内置 typert-gateway 占用。第三方插件提供 RPC 方法请改用精确 fetch route（`ctx.connection.fetch.register` 注册如 `/api/<plugin>/<method>`，自行实现 `{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` 的 RPC envelope 约定），避免顶掉内置 interceptor 导致所有 llm/session 等 RPC 404。插件依赖的 `@deepseek-ai/dsh-tools` 等 peer 版本需与宿主 dsh 通道对齐。

### 插件更新与零重启激活

插件包通过**稳定挂载点**加载：activation script 在每次 switch/boot 把 `/run/dsh/current`（dsh 含插件树）与 `/run/dsh/nixos-shell`（sudo 守护脚本）符号链接翻到当前代的 store 路径（GC 安全：目标始终处于当前 toplevel 闭包内，回滚自动翻回旧代路径）。`dsh.service` 与 `nixkits-sudo@.service` 的单元定义只引用这些稳定路径，因此**插件包更新不再改变 unit 内容**——switch-to-configuration 既不重启 dsh、也不 stop/start sudo socket，激活阶段对在途工具调用零中断。

代价与配套：dsh 是长驻进程，插件更新后需显式 `systemctl restart dsh` 才生效（`nixos_shell` 会把该命令自动分离到瞬态单元，调用先于重启返回）；sudo 守护按连接生成，新连接自动使用新脚本，无需任何重启。

## NixKits 插件

仓库内为 dsh 开发的独立插件**不在本文档展开**，各自维护独立文档（挂载方式见上文 `plugins.packages`）：

| 插件 | 说明 | 文档 |
|------|------|------|
| dsh-nixos-shell | NixOS 场景能力整合：`nixos_shell` 执行器（PATH 注入 / `nix shell` 工具引导 / sudo 守护路由）+ `nixos_cli` 只读诊断；随包分发 NixOS模式 / 维护模式两个 Agent 预设 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量面板「用量 / 余额」切换：账户余额、日 / 月 / 30 日消耗图表与语音播报（含语音包格式指南） | [dsh-api-balance.md](dsh-api-balance.md) |

## Agent 预设

`nixkits.dsh.presets` 把随 dsh-nixos-shell 包分发的 Agent 预设以 **seed-once** 方式写入 `$DSH_HOME/.agent-presets/<id>`（仅目标不存在时复制，尊重用户后续编辑）：

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;       # id `nixos` —— NixOS模式
    maintenanceMode = true; # id `maintenance` —— 维护模式（派生自 NixOS模式）
  };
}
```

| 预设 | 说明 |
|------|------|
| NixOS模式（id `nixos`） | 初始化校验 NixOS 宿主（非 NixOS 拒绝一切请求并明确告知理由）；加载 `nixos_shell` / `nixos_cli` 与 NixOS 高效开发提示词 |
| 维护模式（id `maintenance`） | 基于 NixOS模式；注入 `write-project-docs` / `write-maintenance-log` / `translate-*` 技能（构建期嵌入的仓库 `skills/` 树，全新会话即最新）与仓库维护工作流提示词 |

预设的详细行为、组合结构与派生维护规则见 [dsh-nixos-shell.md](dsh-nixos-shell.md)。

## sudo 守护

dsh 沙箱中 `sudo` 的 setuid 被剥离，代理无法提权（如 `nixos-rebuild`）。`sudo.enable` 部署一个 systemd **套接字激活的 root 执行器**（`nixkits-sudo@.service`，每连接运行一次 `nixkits-sudo-exec`），并向 dsh 服务注入 `NIXKITS_SUDO_SOCKET`。nixos-shell 插件初始化时探测该套接字，存在即启用 `sudo` 参数并路由请求：

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # 默认
  };
}
```

> **安全模型**：套接字文件归 dsh 服务用户所有且 `0600`（`SocketUser`/`SocketMode`），仅该用户可连接——等价于为该用户提供免密 root 执行入口，请仅在信任该用户与代理行为的前提下开启。

## 插件清单

dsh 0.1.1-rc.2 的内置插件 entry id（`nixkits.dsh.plugins.disabled` 的可用值，`id -> 插件包`）：

> **清单生成方法**：`dsh --profile web --dump-default-config`（只读）输出即 `id -> name` 格式；升级 dsh 后用它重新生成本表，以所装版本的输出为准。表中 `headless-runner` / `headless-startup` 两行来自 headless profile 组合，非 web profile 的 base + web-app 补丁集。

```text
  agent -> @deepseek-ai/dsh-agent
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  agent-loop -> @deepseek-ai/dsh-agent-loop
  agent-presets -> @deepseek-ai/dsh-agent-presets
  api-gateway -> @deepseek-ai/dsh-host-apiproxy
  api-remotes -> @deepseek-ai/dsh-api-remotes
  approval -> @deepseek-ai/dsh-user-approval
  attachment-local -> @deepseek-ai/dsh-attachment-local
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  client-hmr -> @deepseek-ai/dsh-client-hmr
  client-runtime -> @deepseek-ai/dsh-client-runtime
  code-runtime -> @deepseek-ai/dsh-code-runtime-worker-thread
  command-compact -> @deepseek-ai/dsh-command-compact
  command-feedback -> @deepseek-ai/dsh-command-feedback
  command-goal -> @deepseek-ai/dsh-command-goal
  commands -> @deepseek-ai/dsh-commands
  compaction-basic -> @deepseek-ai/dsh-compaction-basic
  connection -> @deepseek-ai/dsh-client-connection
  cordis-client-runner -> @deepseek-ai/dsh-cordis-client-runner
  cordis-host-runner -> @deepseek-ai/dsh-cordis-host-runner
  credentials -> @deepseek-ai/dsh-credentials-local
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  headless-runner -> @deepseek-ai/dsh-headless
  headless-startup -> @deepseek-ai/dsh-headless/startup
  hmr -> @deepseek-ai/cordis-plugin-hmr
  jobs -> @deepseek-ai/dsh-jobs-local
  llm -> @deepseek-ai/dsh-llm
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  llm-retry -> @deepseek-ai/dsh-llm-retry
  locale -> @deepseek-ai/dsh-client-locale
  message-feedback -> @deepseek-ai/dsh-message-feedback
  modules -> @deepseek-ai/dsh-client-modules
  permission -> @deepseek-ai/dsh-permission-presets
  plan-mode -> @deepseek-ai/dsh-plan-mode
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  session -> @deepseek-ai/dsh-session
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  session-log-download -> @deepseek-ai/dsh-session-log-export
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  session-projection -> @deepseek-ai/dsh-session-projection
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-reference -> @deepseek-ai/dsh-session-reference
  session-stats -> @deepseek-ai/dsh-session-stats
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  settings -> @deepseek-ai/dsh-settings-file
  shell-env -> @deepseek-ai/dsh-shell-env
  skill -> @deepseek-ai/dsh-skill
  skill-badge -> @deepseek-ai/dsh-skill-badge
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  storage -> @deepseek-ai/dsh-storage
  storage-domain -> @deepseek-ai/dsh-storage-domain
  storage-json -> @deepseek-ai/dsh-storage-json
  subagent -> @deepseek-ai/dsh-subagent
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  subagent-spawn-in-process -> @deepseek-ai/dsh-subagent-spawn-in-process
  subprocess -> @deepseek-ai/dsh-subprocess-local
  system-prompt -> @deepseek-ai/dsh-system-prompt
  timeout-policy -> @deepseek-ai/dsh-tool-call-timeout-policy
  timer -> @deepseek-ai/cordis-plugin-timer
  token-meter -> @deepseek-ai/dsh-token-meter
  tool-bash -> @deepseek-ai/dsh-tool-bash
  tool-fs -> @deepseek-ai/dsh-tool-fs
  tool-fs-search -> @deepseek-ai/dsh-tool-fs-search
  tool-goal -> @deepseek-ai/dsh-tool-goal
  tool-jobs -> @deepseek-ai/dsh-tool-jobs
  tool-pwsh -> @deepseek-ai/dsh-tool-pwsh
  tool-ralph -> @deepseek-ai/dsh-tool-ralph
  tool-result-pruner -> @deepseek-ai/dsh-compaction-tool-result-pruner
  tool-skill -> @deepseek-ai/dsh-tool-skill
  tool-str-replace-editor -> @deepseek-ai/dsh-tool-str-replace-editor
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-subagent-report -> @deepseek-ai/dsh-tool-subagent-report
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-web -> @deepseek-ai/dsh-tool-web
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  tools -> @deepseek-ai/dsh-tools
  typert -> @deepseek-ai/dsh-typert-registry
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  typert-loader -> @deepseek-ai/dsh-typert-loader
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-commands -> @deepseek-ai/dsh-client-ui-commands
  ui-conversation -> @deepseek-ai/dsh-client-ui-conversation
  ui-cordis -> @deepseek-ai/dsh-client-ui-cordis
  ui-deliverables -> @deepseek-ai/dsh-client-ui-deliverables
  ui-goal -> @deepseek-ai/dsh-client-ui-goal
  ui-input-trigger -> @deepseek-ai/dsh-client-ui-input-trigger
  ui-jobs -> @deepseek-ai/dsh-client-ui-jobs
  ui-layout -> @deepseek-ai/dsh-client-ui-layout
  ui-message-feedback -> @deepseek-ai/dsh-client-ui-message-feedback
  ui-model-selection -> @deepseek-ai/dsh-client-ui-model-selection
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-skill -> @deepseek-ai/dsh-client-ui-skill
  ui-subagent -> @deepseek-ai/dsh-client-ui-subagent
  ui-theme -> @deepseek-ai/dsh-client-ui-theme
  ui-tool -> @deepseek-ai/dsh-client-ui-tool
  ui-trajectory -> @deepseek-ai/dsh-client-ui-trajectory
  ui-user-questions -> @deepseek-ai/dsh-client-ui-user-questions
  ui-workflow-run -> @deepseek-ai/dsh-client-ui-workflow-run
  ui-workspace -> @deepseek-ai/dsh-client-ui-workspace
  user-questions -> @deepseek-ai/dsh-user-questions
  web -> @deepseek-ai/dsh-web
  web-runtime -> @deepseek-ai/dsh-web-app
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  web-startup -> @deepseek-ai/dsh-web-app/startup
  webserver -> @deepseek-ai/dsh-host-webserver
  workflow-worker-thread -> @deepseek-ai/dsh-workflow-worker-thread
  workspace -> @deepseek-ai/dsh-workspace
```

## 设置声明式配置

dsh 的设置菜单选项通过 `$DSH_HOME/settings.yaml` 文件备份 + 热加载。`nixkits.dsh.settings` 提供声明式配置（namespace → section）：

```nix
{
  nixkits.dsh.settings = {
    "web-search-deepseek" = {
      model = "deepseek-v4-flash";
      maxTokens = 8192;
    };
    "llm-deepseek" = {
      timeout = 10000;
    };
  };
}
```

- namespace 对应设置 UI 的分区（如 `web-search-deepseek`、`llm-deepseek`、`ui-onboarding`）
- 值必须是 JSON 兼容数据（string/number/boolean/list/object）
- 生成 JSON（合法 YAML），dsh 热加载；空 `{}` 或缺失回退到 schema 默认值

### 可声明式配置的宿主 namespace

`nixkits.dsh.settings` 只能写入**宿主侧已通过 `settings.register` 注册**的命名空间——这些值存 `$DSH_HOME/settings.yaml`，跨浏览器一致。DSH 0.1.2-alpha 内置注册的 namespace 及字段：

| namespace | 字段 | 说明 |
|-----------|------|------|
| `locale` | `language` 等 | 界面语言 |
| `ui-theme` | `dark`/`light`/`system`/`fontSize`/`preference`/`body` 等 | 外观与主题 |
| `ui-chat` | `transcriptView` 等 | 会话视图 |
| `ui-conversation` | `busyEnter`（`queue`/`steer`） | 忙碌时 Enter 行为 |
| `ui-onboarding` | — | 引导步骤状态 |
| `agent-presets` | — | Agent 预设 |

> **设置菜单的存储层边界**：并非设置 UI 里每一项都能用 `nixkits.dsh.settings` 声明式配置。**dsh-api-balance 的界面 / 语音设置**（语音提醒、底部统计条横向滚动、回车换行 + Shift+回车发送、移动端会话切换不弹键盘、TTS 后端）是**浏览器 localStorage 状态**（每浏览器独立、默认开启、UI 内切换），**不经过** `settings.register` 系统，因此 `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` **不会**覆盖它们。这类"每浏览器偏好"请在该插件的 `⚙ 设置` 面板内配置，或按设备部署独立浏览器。

