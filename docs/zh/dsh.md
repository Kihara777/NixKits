# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.1-rc.2` |
| 开发通道 | `dsh-alpha 0.1.2-alpha.2`（npm `alpha` dist-tag） |
| 许可 | MIT |
| 命令 | `dsh` |

## 版本通道

NixKits 仿 ruyi 的薄包装模式（主定义 + 版本/hash 覆盖包装）同时提供多个 dsh 版本：

| 包 | 通道 | 版本 | 说明 |
|----|------|------|------|
| `pkgs.dsh` | stable | `0.1.1-rc.2` | npm `latest` dist-tag，默认 |
| `pkgs.dsh-alpha` | alpha | `0.1.2-alpha.2` | npm `alpha` dist-tag，跟踪最新开发版 |

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

### api-balance 插件

API 用量余额（`@kihara777/dsh-api-balance`）：在 webui 用量圆圈（发送按钮左侧的上下文已用显示）的弹出面板中提供「用量 / 余额」标签切换——「用量」为原有内容（上下文占用与细分），「余额」展示当前 API KEY 的账户信息（key 尾号、余额是否充足、各币种总余额 / 充值余额 / 赠送余额），并含当日 / 当月 / 30 日内消耗（金额 + token + 分模型明细）与按日 / 按月用量图表。余额数据来自 DeepSeek 官方 `GET /user/balance` 接口（API key 认证），用量数据来自平台控制台内部接口 `GET platform.deepseek.com/api/v0/usage/by_api_key/{amount,cost}`（平台会话令牌认证），host 端 30 秒 TTL 缓存；API key 按 `apiKeyEnv`（默认 `DEEPSEEK_API_KEY`）走 `credentials` 服务解析，回退进程环境变量。

平台令牌两级获取，全自动优先：

- **本机浏览器自动扫描（默认开启）**：host 直接读取本机 Chromium 系浏览器（Edge / Chrome / Brave / Chromium / Vivaldi / Opera，各 Profile）的 `Local Storage/leveldb`——先按 LevelDB 表结构精确解析（footer → index → 数据块 → snappy 解压 → 条目遍历）读出 `userToken`，解析失败时回退裸字节启发式候选——命中即落盘 `$DSH_HOME/api-balance-token`（0600）。用户在本机浏览器登录过平台即无感获取；节流默认每 6 小时最多扫描一次（`browserScanIntervalMs` 可配，`browserScan = false` 关闭），令牌失效（40003/401）后下次查询立即重扫。
- **未登录检测与登录引导**：扫描未命中时面板自动弹出「未检测到平台登录」提示——「前往登录」在新标签页打开登录页并轮询自动拾取令牌；手动输入令牌仅作为弹窗内的二级备选（不想登录时使用）。已连接后面板显示灰显「✓ 已登录」按钮与令牌来源（本机浏览器自动获取 / 手动连接）；每次手动刷新在无令牌时也会自动快扫检查登录态，无需点任何按钮。
- **语音播报**：面板内独立一行提供「播报语音用量」下拉菜单——播报当前用量 / 余额，或试听低用量、余额不足警告音频；菜单默认从按钮上方展开（上方空间不足时自动向下）。播报语言与音色跟随 DSH 界面语言（zh / en）。「⚙ 语音设置」弹窗提供：自动播报开关（余额低于阈值时提醒，30 分钟限流）、TTS 后端选择（浏览器内置语音 / 自定义 TTS API，后者经 host 代理调用规避跨域，URL 模板占位符 `{text}` `{lang}` `{rate}`）、语音包库管理（zip 导入多个包、列表切换使用 / 多选移除，列表可滚动；保存于 `$DSH_HOME/api-balance-voicepack/`，全设备共享），以及「语音包管理」次级菜单中的制作器（浏览器录音或导入音频，录音时展示可视化浮窗与示例文本，可跨语言录制并打包下载 / 编译应用）。

#### 语音包格式指南

语音包为 **zip 压缩包**（方便部署与分享），内含 `manifest.json` 清单与音频文件；面板「⚙ 语音设置」选择 .zip 导入即启用，清除即恢复默认 TTS 整句播报。

zip 结构：

```
voice-pack.zip
├── manifest.json
└── audio/
    ├── dead.mp3
    ├── low.mp3
    └── …
```

```json
// manifest.json
{
  "format": "dsh-api-balance-voice-pack",
  "version": 1,
  "name": "我的语音包",
  "lang": "zh-CN",
  "segments": {
    "dead": "audio/dead.mp3",
    "low": "audio/low.mp3",
    "usage": "audio/usage.mp3",
    "balance": "audio/balance.mp3",
    "tokenUnit": "audio/tokenUnit.mp3",
    "month": "audio/month.mp3",
    "suffix": "audio/suffix.mp3",
    // 可选：问候音效数组（页面刷新时随机播放一个）
    "greetings": ["audio/hello1.mp3", "audio/hello2.mp3"]
  }
}
```

| 片段 | 用途 |
|------|------|
| `dead` | 余额不可用提醒整句 |
| `low` | 低余额提醒整句 |
| `usage` | 「当前用量」播报前缀 |
| `balance` | 「当前余额」播报前缀 |
| `tokenUnit` | 数字后的单位（如「个 token」），可复用 |
| `month` | 「当月」标签 |
| `suffix` | 播报结尾 |

全部片段可选：缺失片段在播报时以 TTS 兜底。可选 `greetings` 为文件路径数组（0–16 个）：语音播报开启时，每次刷新页面随机播放其中一个作为问候/放置音效；无问候音频时改用 TTS 问候语池随机播放。约束：片段键 `[A-Za-z0-9_-]{1,32}`，zip ≤ 16 MB、文件 ≤ 32 个、单音频 ≤ 2 MB；音频建议 mp3 / wav / ogg / webm，单段 2 秒以内、22.05/44.1 kHz 单声道。动态部分（余额数字、token 数量等）不在包内——由当前 TTS 后端（浏览器内置或自定义 TTS API，后者经 host 代理规避跨域）实时合成，按「包片段 + TTS 数字」顺序拼接为完整播报。

**制作与分享**：「语音包管理」→「制作语音包」进入制作器——先选择语音包语言（zh-CN / en / ja，决定示例文本与清单 `lang`，可跨语言录制），再逐段用浏览器麦克风录音（需授予权限；本地或 HTTPS 环境可用）或导入本地音频文件；录音时右下角弹出可视化浮窗（电平表 + 计时 + 示例文本 + 停止/放弃）。完成后「打包下载」生成 zip 分享，或「编译并应用」导入本机库并激活；已导入语音包时，首次编辑会弹出覆盖提示，确认后方可继续（会话内确认一次）。

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config 可选：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # 本机浏览器自动扫描
    #   browserScanIntervalMs = 21600000; # 扫描节流（默认 6 小时）
  }];
}
```

### nixos-shell 插件

NixOS 场景能力整合为**单一插件** `nixos-shell`（`@kihara777/dsh-nixos-shell`），功能需求源自 `nixos-modern-cli` 技能的场景描述，注册两个工具：

- `nixos_shell` — shell 执行器：NixOS PATH 注入 + bash 回退（`spawn bash ENOENT` 修复）、`tools` 参数经 `nix shell nixpkgs#<pkg>… --command` 引导缺失的 POSIX 工具、sudo 守护路由
- `nixos_cli` — 只读 NixOS 诊断：`capabilities`（现代 CLI 能力探测与传统→现代命令对照）、`system-status`、`generations`、`journal`、`audit-store-paths`（配置文件中 `/nix/store/` 绝对路径审计）

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nixos-shell;
    id = "nixos-shell";
    name = "@kihara777/dsh-nixos-shell";
  }];
}
```

> 原「技能插件化」设计（dsh-skill-nixkits，7 技能 7 组合行）已废弃并移除。技能内容仍保留在仓库 `skills/`，供其他编码助手（opencode/codewhale/codex/openclaw/agents）经 `nixkits-skills` 技能安装。

### sudo 守护

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
