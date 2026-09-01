# dsh

[中文](../zh/dsh.md) | English | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness (DSH) — Everything is a Plugin.

## Basic Info

| Item | Value |
|------|-------|
| Type | Node.js application (CLI) |
| Upstream | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| Version | `0.1.1-rc.2` |
| Development channel | `dsh-alpha 0.1.2-alpha.3` (npm `alpha` dist-tag) |
| License | MIT |
| Command | `dsh` |

## Version Channels

NixKits ships multiple dsh versions at once, following ruyi's thin-wrapper pattern (main definition + version/hash override wrappers):

| Package | Channel | Version | Notes |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.1.1-rc.2` | npm `latest` dist-tag, default |
| `pkgs.dsh-alpha` | alpha | `0.1.2-alpha.3` | npm `alpha` dist-tag, tracks the latest development build |

```nix
# Use the latest development version on this machine
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` is the upstream development channel: its built-in plugin list changes between versions (the list below covers stable `0.1.1-rc.2`; for alpha, trust what the runtime actually loads). Check the [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) before upgrading.

## Install

```nix
# /etc/nixos/flake.nix — add the flake input and mount the module
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # in nixosConfigurations.<host>.modules:
  #   nixkits.nixosModules.dsh
}
```

```nix
# Module configuration (enabling it also adds dsh to systemPackages)
{ nixkits.dsh.enable = true; }
```

> **Binary cache**: the flake declares the cache (`nixkits.cachix.org`) via `nixConfig`; Nix prompts to enable it on first build. Manual: `cachix use nixkits`.

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

### LAN access (trustedHosts + launch URLs)

The dsh ≥ 0.1.2-alpha web UI entry authenticates with a Host-authority session cookie, so the proxy **no longer rewrites Host** (rewriting makes the backend see a different authority than the browser visited; the cookie cannot match across the proxy and every request 401s). LAN devices visiting `http://<host>:8625` must have their authority listed in `trustedHosts`. dsh prints its tokenized startup URL for 127.0.0.1 only; `launchUrlFile` makes the module capture dsh's startup output (ExecStartPost) and write the LAN devices' authenticated URLs there:

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # LAN authorities
    launchUrlFile = "/run/dsh/launch-urls";             # startup URL output file
  };
}
```

> The token rotates on every dsh restart; exchanged session cookies stay valid until expiry.

### Passwordless entry (autoAuth)

`reverseProxy.autoAuth` uses lighttpd mod_magnet (the module swaps in an `enableMagnet` lighttpd automatically) to 302-inject the current launch token on home-page requests without a session cookie — LAN devices reach the web UI with no manual authentication step. **This DISABLES dsh's entry authentication (the token is no longer secret)** — enable only when the local network is fully trusted, otherwise any device that can reach the proxy port gains full dsh access (including its RCE surface):

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> Note: autoAuth assumes a network-layer security scheme (e.g. an isolated LAN) owns the access boundary.

> **PATH**: the module injects a complete NixOS PATH (`/run/current-system/sw/bin`, …) into the service. Without it, systemd's default PATH cannot find bash and the built-in bash tool fails with `spawn bash ENOENT`.

> **HOME**: the service HOME points at the running user's real home (`users.users.<user>.home`, falling back to dshHome), so the agent inherits the user's own tooling context — git/gh credentials (`~/.config/gh`), `~/.gitconfig`, npm/ssh configs all resolve from `$HOME`. Pointing HOME at dshHome breaks this: git's gh credential helper finds no credentials and pushes fail.

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
    package = pkgs.dsh-nixos-shell;           # NixKits package (npm build)
    id = "nixos-shell";                   # cordis.patch.yml entry id
    name = "@kihara777/dsh-nixos-shell";  # npm package name referenced by the row
  }];
}
```

> **dsh ≥ 0.1.2-alpha plugin compatibility**: `ctx.connection.rpc.intercept` shared RPC channel interceptors are exclusive (one per channel; a second registration throws), and `/api` is already taken by the built-in typert-gateway. Third-party plugins exposing RPC methods should use an exact fetch route instead (`ctx.connection.fetch.register` on e.g. `/api/<plugin>/<method>`, implementing the RPC envelope contract `{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` yourself) — grabbing the channel interceptor displaces the built-in one and 404s every llm/session RPC. Plugin peer deps like `@deepseek-ai/dsh-tools` must match the host dsh channel.

### Plugin updates and zero-restart activation

Plugin packages are loaded through **stable mount points**: an activation script re-links `/run/dsh/current` (dsh with its plugin tree) and `/run/dsh/nixos-shell` (the sudo executor script) to the current generation's store paths on every switch/boot (GC-safe: the targets always sit in the current toplevel closure, and rollback flips back to the old generation's paths). The `dsh.service` and `nixkits-sudo@.service` unit definitions reference only these stable paths, so **plugin package updates no longer change unit content** — switch-to-configuration neither restarts dsh nor stops/starts the sudo socket, and the activation interrupts no in-flight tool call.

Trade-off: dsh is a long-lived process, so plugin updates take effect only after an explicit `systemctl restart dsh` (`nixos_shell` auto-detaches that command into a transient unit, returning before the restart lands); the sudo executor spawns per connection, so new connections pick up the new script automatically with no restart at all.

## NixKits plugins

Plugins developed in this repo for dsh are **not expanded in this document** — each keeps its own dedicated doc (mounting is covered by `plugins.packages` above):

| Plugin | Description | Doc |
|------|------|------|
| dsh-nixos-shell | Consolidated NixOS scenario capabilities: the `nixos_shell` executor (PATH injection / `nix shell` tool bootstrap / sudo-daemon routing) + `nixos_cli` read-only diagnostics; ships the NixOS mode / maintenance mode Agent presets | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | 「Usage / Balance」 tab switch in the webui usage panel: account balance, daily / monthly / 30-day consumption charts and voice broadcast (incl. the voice-pack format guide) | [dsh-api-balance.md](dsh-api-balance.md) |

## Agent presets

`nixkits.dsh.presets` writes the Agent presets shipped with dsh-nixos-shell into `$DSH_HOME/.agent-presets/<id>` **seed-once** (copied only when the target does not exist, respecting later user edits):

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;       # id `nixos` — NixOS mode
    maintenanceMode = true; # id `maintenance` — maintenance mode (derived from NixOS mode)
  };
}
```

| Preset | Description |
|------|------|
| NixOS mode (id `nixos`) | validates the NixOS host at initialization (non-NixOS rejects all requests with an explicit reason); loads `nixos_shell` / `nixos_cli` and the NixOS development prompts |
| Maintenance mode (id `maintenance`) | based on NixOS mode; injects `write-project-docs` / `write-maintenance-log` / `translate-*` skills (the repo `skills/` tree embedded at build time — always current in a fresh session) and the repo-maintenance workflow prompts |

Detailed preset behavior, composition structure, and derivation maintenance rules: see [dsh-nixos-shell.md](dsh-nixos-shell.md).

## Sudo daemon

Inside the dsh sandbox `sudo` loses its setuid bit, so the agent cannot elevate (e.g. `nixos-rebuild`). `sudo.enable` deploys a systemd **socket-activated root executor** (`nixkits-sudo@.service`, running `nixkits-sudo-exec` once per connection) and injects `NIXKITS_SUDO_SOCKET` into the dsh service. The nixos-shell plugin probes that socket at apply time, advertises the `sudo` parameter when present, and routes requests through it:

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # default
  };
}
```

> **Security model**: the socket file is owned by the dsh service user with mode `0600` (`SocketUser`/`SocketMode`), so only that user can connect — equivalent to passwordless root for that user; enable only when both the user and the agent's behavior are trusted.


## Plugin inventory

Built-in plugin entry ids for dsh 0.1.1-rc.2 (valid values for `nixkits.dsh.plugins.disabled`, `id -> package`):

> **Regenerating this list**: `dsh --profile web --dump-default-config` (read-only) prints the `id -> name` pairs directly; re-run it after upgrading and treat the installed version's output as authoritative. The `headless-runner` / `headless-startup` rows come from the headless profile composition, not the web profile's base + web-app patch set.

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


### Declaratively configurable host namespaces

`nixkits.dsh.settings` can only write into **namespaces registered host-side via `settings.register`** — these values live in `$DSH_HOME/settings.yaml` and are consistent across browsers. DSH 0.1.2-alpha ships these registered namespaces and fields:

| namespace | fields | description |
|-----------|--------|-------------|
| `locale` | `language` etc. | interface language |
| `ui-theme` | `dark`/`light`/`system`/`fontSize`/`preference`/`body` etc. | appearance & theme |
| `ui-chat` | `transcriptView` etc. | conversation view |
| `ui-conversation` | `busyEnter` (`queue`/`steer`) | Enter behavior while busy |
| `ui-onboarding` | — | onboarding-step state |
| `agent-presets` | — | agent presets |

> **Settings-menu storage boundary**: not every entry in the settings UI is declaratively configurable via `nixkits.dsh.settings`. The **dsh-api-balance interface / voice settings** (voice alerts, bottom stats-bar horizontal scroll, Enter-newline + Shift+Enter-send swap, mobile session-switch keyboard suppression, TTS backend) are **browser localStorage state** (per-browser, enabled by default, toggled in the UI) and do **not** go through the `settings.register` system — so `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` does **not** override them. Configure these per-browser preferences in the plugin's `⚙ Settings` panel, or deploy a separate browser per device.
