# dsh

[中文](../zh/dsh.md) | English | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness (DSH) — Everything is a Plugin.

## Basic Info

| Item | Value |
|------|-------|
| Type | Node.js application (CLI) |
| Upstream | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| Version | `0.1.0-rc.6` |
| License | MIT |
| Command | `dsh` |

## Install

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## Usage

```bash
dsh --help
dsh web   # launch the browser UI
```

## Service

Run as a resident web service via the `nixkits.dsh` module. dsh listens loopback-only (`127.0.0.1:8615`) for RCE safety, exposed to the outside via a lighttpd reverse proxy on port `8625` (firewall auto-opened):

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # fixed: dsh rejects non-loopback
    port = 8615;          # internal loopback port
    reverseProxy = {
      enable = true;
      port = 8625;        # public lighttpd port
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

> **PATH**: the module injects a complete NixOS PATH (`/run/current-system/sw/bin`, …) into the service. Without it, systemd's default PATH cannot find bash and the built-in bash tool fails with `spawn bash ENOENT`.

## Declarative plugin management

dsh plugins hot-reload from `cordis.patch.yml` at runtime (no restart). `nixkits.dsh.plugins` provides declarative on/off and config:

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # disable plugins
    settings."dsh-web-app" = { printUrl = false; };           # config overrides
    extraPatch = "...";  # raw fragment (e.g. MCP insert list)
  };
}
```

| Option | Meaning |
|------|------|
| `disabled` | plugin entry ids to disable, rendered as `- id: <id> / disabled: true` |
| `settings` | plugin config overrides (id → JSON, YAML flow style) |
| `packages` | third-party plugin packages: injected into dsh's node_modules + generated composition rows (below) |
| `extraPatch` | raw cordis.patch.yml fragment (e.g. MCP servers) |

### Third-party plugin packages

`plugins.packages` injects third-party npm plugin packages into dsh's node_modules tree (composition rows resolve package names from the install root, and the packages must be real directories there — a symlink would be realpathed back into the plugin's own store path, breaking peer resolution) and registers the composition row in the generated cordis.patch.yml:

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nix-shell;         # NixKits package (npm build)
    id = "tool-nix-shell";                # cordis.patch.yml entry id
    name = "@kihara777/dsh-nix-shell";    # npm package name referenced by the row
  }];
}
```

### Skill bundle

`skills.enable` mounts the NixKits skill directory as deployment-bundled skills (`skill-filesystem`'s `bundledSkillDir`, rank 600) for every session — no home-directory writes, atomic upgrades with `nixos-rebuild`:

```nix
{
  nixkits.dsh.skills = {
    enable = true;
    package = pkgs.nixkits-skills;  # default; replaceable with a custom bundle
  };
}
```

## Plugin inventory

Built-in plugin entry ids for dsh 0.1.0-rc.6 (valid values for `nixkits.dsh.plugins.disabled`, `id -> package`):

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

## Declarative settings

dsh settings-menu options live in `$DSH_HOME/settings.yaml` (file-backed, hot-reloaded). `nixkits.dsh.settings` provides declarative config (namespace → section):

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

- namespace maps to a settings-UI section (e.g. `web-search-deepseek`, `llm-deepseek`, `ui-onboarding`)
- values must be JSON-compatible (string/number/boolean/list/object)
- rendered as JSON (valid YAML), hot-reloaded; empty `{}` or missing falls back to schema defaults
