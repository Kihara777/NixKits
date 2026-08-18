# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.0-rc.6` |
| 许可 | MIT |
| 命令 | `dsh` |

## 安装

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

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
| `extraPatch` | 手写 cordis.patch.yml 片段（如 MCP 服务） |

## 插件清单

dsh 0.1.0-rc.6 的内置插件 entry id（`nixkits.dsh.plugins.disabled` 的可用值，`id -> 插件包`）：

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
