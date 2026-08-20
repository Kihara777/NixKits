# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.1.0-rc.6` |
| ライセンス | MIT |
| コマンド | `dsh` |

## インストール

```nix
# /etc/nixos/flake.nix — flake 入力の追加とモジュールのマウント
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # nixosConfigurations.<host>.modules 内:
  #   nixkits.nixosModules.dsh
}
```

```nix
# モジュール設定（有効化すると dsh は systemPackages にも追加される）
{ nixkits.dsh.enable = true; }
```

> **バイナリキャッシュ**：flake は `nixConfig` でキャッシュ（`nixkits.cachix.org`）を宣言済み。初回ビルド時に Nix が有効化を促す。手動：`cachix use nixkits`。

## 使い方

```bash
dsh --help
dsh web   # ブラウザ UI を起動
```

## サービス設定

常駐 web サービスとして実行するには `nixkits.dsh` モジュールを使用。dsh は RCE 安全のため loopback のみ（`127.0.0.1:8615`）をリッスンし、lighttpd リバースプロキシで对外ポート `8625` に公開（ファイアウォール自動開放）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh は非 loopback を拒否
    port = 8615;          # 内部 loopback ポート
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外ポート
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

> **PATH**：モジュールはサービスへ完全な NixOS PATH（`/run/current-system/sw/bin` など）を自動注入する。これが無いと systemd の既定 PATH では bash が見つからず、内蔵 bash ツールが `spawn bash ENOENT` で失敗する。

> **HOME**：サービスの HOME は実行ユーザーの実ホーム（`users.users.<user>.home`、無ければ dshHome にフォールバック）を指し、エージェントはユーザー自身のツール環境を継承する——git/gh 認証情報（`~/.config/gh`）、`~/.gitconfig`、npm/ssh 設定はすべて `$HOME` から解決される。HOME を dshHome に向けると、git の gh credential helper が認証情報を見つけられず push が失敗する。

## プラグイン宣言的管理

dsh のプラグインは `cordis.patch.yml` からランタイムにホットリロードされる（再起動不要）。`nixkits.dsh.plugins` で宣言的なオン/オフと設定が可能：

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # 無効化
    settings."dsh-web-app" = { printUrl = false; };           # 設定上書き
    extraPatch = "...";  # 生フラグメント（MCP insert リストなど）
  };
}
```

| オプション | 説明 |
|------|------|
| `disabled` | 無効化するプラグイン entry id、`- id: <id> / disabled: true` に描画 |
| `settings` | プラグイン config 上書き（id → JSON、YAML flow style） |
| `packages` | サードパーティプラグインパッケージ：dsh の node_modules へ注入 + コンポジション行生成（下記） |
| `extraPatch` | 生 cordis.patch.yml フラグメント（MCP サーバーなど） |

### サードパーティプラグインパッケージ

`plugins.packages` はサードパーティ npm プラグインパッケージを dsh の node_modules ツリーへ注入する（コンポジション行はインストールルートからパッケージ名を解決するため、パッケージは実ディレクトリとして存在する必要がある — シンボリックリンクは Node の realpath によりプラグイン自身の store パスへ戻され、peer 解決が壊れる）。生成される cordis.patch.yml にコンポジション行も自動登録する：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.nixos-shell;           # NixKits パッケージ（npm ビルド）
    id = "nixos-shell";                   # cordis.patch.yml の entry id
    name = "@kihara777/dsh-nixos-shell";  # 行が参照する npm パッケージ名
  }];
}
```

### nixos-shell プラグイン

NixOS シナリオ能力は**単一プラグイン** `nixos-shell`（`@kihara777/dsh-nixos-shell`）へ統合され、機能要件は `nixos-modern-cli` スキルのシナリオに由来する。2 つのツールを登録する：

- `nixos_shell` — shell 実行器：NixOS PATH 注入 + bash フォールバック（`spawn bash ENOENT` 修正）、`tools` パラメータで `nix shell nixpkgs#<pkg>… --command` にラップして不足する POSIX ツールを提供、sudo デーモンルーティング
- `nixos_cli` — 読み取り専用 NixOS 診断：`capabilities`（モダン CLI の検出と伝統→モダンコマンド対照）、`system-status`、`generations`、`journal`、`audit-store-paths`（設定ファイル内の `/nix/store/` 絶対パス監査）

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.nixos-shell;
    id = "nixos-shell";
    name = "@kihara777/dsh-nixos-shell";
  }];
}
```

> 旧「スキルプラグイン化」設計（dsh-skill-nixkits、7 スキル / 7 コンポジション行）は廃止・削除済み。スキル内容はリポジトリの `skills/` に残り、他のコーディングアシスタント（opencode/codewhale/codex/openclaw/agents）向けに `nixkits-skills` スキルでインストールされる。

### sudo デーモン

dsh サンドボックス内では `sudo` の setuid が失われ、エージェントは昇格できない（例：`nixos-rebuild`）。`sudo.enable` は systemd の**ソケットアクティベーション型 root 実行器**（`nixkits-sudo@.service`、接続ごとに `nixkits-sudo-exec` を実行）を配備し、dsh サービスへ `NIXKITS_SUDO_SOCKET` を注入する。nixos-shell プラグインは初期化時にこのソケットを検出し、存在すれば `sudo` パラメータを有効化してリクエストをルーティングする：

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # 既定
  };
}
```

> **セキュリティモデル**：ソケットファイルは dsh サービスユーザー所有で `0600`（`SocketUser`/`SocketMode`）— そのユーザーのみ接続可能で、事実上そのユーザーへのパスワードレス root 実行を意味する。ユーザーとエージェントの挙動の両方を信頼できる場合のみ有効化すること。

## プラグイン一覧

dsh 0.1.0-rc.6 の内蔵プラグイン entry id（`nixkits.dsh.plugins.disabled` の有効値、`id -> パッケージ`）：

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

## 設定の宣言的構成

dsh の設定メニュー項目は `$DSH_HOME/settings.yaml`（ファイルバックアップ、ホットリロード）に格納される。`nixkits.dsh.settings` で宣言的構成が可能（namespace → section）：

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

- namespace は設定 UI のセクションに対応（`web-search-deepseek`、`llm-deepseek`、`ui-onboarding` など）
- 値は JSON 互換データ（string/number/boolean/list/object）必須
- JSON（合法 YAML）として描画、ホットリロード；空 `{}` または欠落時はスキーマ既定値にフォールバック
