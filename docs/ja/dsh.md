# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.1.1-rc.2` |
| 開発チャネル | `dsh-alpha 0.1.2-alpha.2`（npm `alpha` dist-tag） |
| ライセンス | MIT |
| コマンド | `dsh` |

## バージョンチャネル

NixKits は ruyi の薄いラッパーパターン（本体定義 + バージョン/ハッシュ上書きラッパー）に倣い、複数の dsh バージョンを同時に提供する：

| パッケージ | チャネル | バージョン | 説明 |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.1.1-rc.2` | npm `latest` dist-tag、既定 |
| `pkgs.dsh-alpha` | alpha | `0.1.2-alpha.2` | npm `alpha` dist-tag、最新開発版を追跡 |

```nix
# 本機で最新開発版に切り替える
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` は上流の開発チャネル：内蔵プラグイン一覧はバージョンごとに変化する（下記の一覧は stable `0.1.1-rc.2` に対応。alpha は実行時に実際に読み込まれたものを基準とする）。アップグレード前に [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) の確認を推奨。

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

### 局域网アクセス（trustedHosts + 起動 URL）

dsh ≥ 0.1.2-alpha の web UI 入口は Host authority ベースの session cookie 認証を使うため、リバースプロキシは**Host を書き換えなくなった**（書き換えるとバックエンドが見る authority がブラウザの実際の訪問先と不一致になり、cookie が反代越しに一致せず常に 401 になる）。局域网デバイスが `http://<host>:8625` にアクセスする場合、その authority を `trustedHosts` に列挙する必要がある。dsh が表示する token 起動 URL は 127.0.0.1 のみ。`launchUrlFile` を設定すると、モジュールが dsh 起動時（ExecStartPost が起動出力を捕捉）に局域网デバイス向け認証 URL を当該ファイルへ書き込む：

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # 局域网 authority
    launchUrlFile = "/run/dsh/launch-urls";             # 起動 URL 出力ファイル
  };
}
```

> token は dsh 再起動のたびにローテーションする。交換済みの session cookie は有効期限まで有効。

### 免認証入口（autoAuth）

`reverseProxy.autoAuth` は lighttpd mod_magnet（モジュールが `enableMagnet` 版 lighttpd へ自動切替）で session cookie の無いホームページ要求に 302 で現在の launch token を注入し、局域网デバイスが手動認証なしで到達できる。**このスイッチは dsh の入口認証を無効化する（token はもはや秘密ではない）**——ローカルネットワークが完全に信頼できる場合のみ有効化すること。さもなければ反代ポートへ到達できる任意のデバイスが完全な dsh アクセス（RCE 面を含む）を得る：

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> 注意：autoAuth はネットワーク層のセキュリティ施策（隔離された LAN など）がアクセス境界を担うことを前提とする。

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
    package = pkgs.dsh-nixos-shell;           # NixKits パッケージ（npm ビルド）
    id = "nixos-shell";                   # cordis.patch.yml の entry id
    name = "@kihara777/dsh-nixos-shell";  # 行が参照する npm パッケージ名
  }];
}
```

> **dsh ≥ 0.1.2-alpha プラグイン互換性**：`ctx.connection.rpc.intercept` の shared RPC channel interceptor は排他的（1 チャネルに 1 つのみ、再登録は throw）で、`/api` は内蔵 typert-gateway が既に占有している。RPC メソッドを提供するサードパーティプラグインは正確な fetch route（`ctx.connection.fetch.register` で `/api/<plugin>/<method>` などに登録し、`{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` の RPC envelope 契約を自前実装）を使うこと——チャネル interceptor を奪うと内蔵の interceptor が押しのけられ、すべての llm/session 等の RPC が 404 になる。プラグインの `@deepseek-ai/dsh-tools` 等の peer 依存はホスト dsh のチャネルに合わせること。

### プラグイン更新とゼロ再起動活性化

プラグインパッケージは**安定マウントポイント**経由で読み込む：activation script が毎回の switch/boot で `/run/dsh/current`（dsh 本体とプラグイン木）と `/run/dsh/nixos-shell`（sudo 実行スクリプト）のシンボリックリンクを現在世代の store パスへ張り替える（GC 安全：リンク先は常に現在の toplevel 閉包内にあり、ロールバック時は旧世代のパスへ自動で戻る）。`dsh.service` と `nixkits-sudo@.service` のユニット定義はこれら安定パスのみを参照するため、**プラグインパッケージの更新でユニット内容は変わらない**——switch-to-configuration は dsh を再起動せず、sudo socket も stop/start しない。活性化は実行中のツール呼び出しを一切中断しない。

トレードオフ：dsh は長寿命プロセスのため、プラグイン更新の反映には明示的な `systemctl restart dsh` が必要（`nixos_shell` はこのコマンドを一時ユニットへ自動分離し、再起動前に呼び出しが返る）。sudo 実行器は接続ごとに生成されるため、新規接続は自動的に新スクリプトを使用し、再起動は一切不要。

### api-balance プラグイン

API 使用量残高（`@kihara777/dsh-api-balance`）：webui の使用量リング（送信ボタン左のコンテキスト使用量表示）のポップオーバーパネルに「用量 / 残高」タブ切替を追加——「用量」は元の内容（コンテキスト占有率と内訳）、「残高」は現在の API キーのアカウント情報（キー末尾、残高可否、通貨別の総残高 / チャージ残高 / 付与残高）に加え、当日 / 当月 / 30 日間の消費（金額 + トークン + モデル別内訳）と日別 / 月別の使用量チャートを表示する。残高データは DeepSeek 公式 `GET /user/balance`（API キー認証）、使用量データはプラットフォームコンソール内部 API `GET platform.deepseek.com/api/v0/usage/by_api_key/{amount,cost}`（プラットフォームセッショントークン認証）から取得し、ホスト側で 30 秒 TTL キャッシュ。API キーは `credentials` サービス経由で `apiKeyEnv`（デフォルト `DEEPSEEK_API_KEY`）を解決し、プロセス環境変数へフォールバックする。

プラットフォームトークンは二段構えで取得し、全自動を優先する：

- **ローカルブラウザ自動スキャン（デフォルト有効）**：ホストがローカルの Chromium 系ブラウザ（Edge / Chrome / Brave / Chromium / Vivaldi / Opera、全プロファイル）の `Local Storage/leveldb` を直接読み、base64 候補（55–85 文字）を抽出して `GET /api/v0/users/get_user_summary` で逐一検証（`code === 0` が有効）、最初の一致を `$DSH_HOME/api-balance-token`（0600）へ保存する。ローカルブラウザで一度プラットフォームにログインしていれば手動操作なしで取得できる。節流はデフォルト 6 時間に 1 回まで（`browserScanIntervalMs` で設定、`browserScan = false` で無効化）。トークン失効（40003/401）後は次回クエリで即再スキャンし、パネルの「本機ブラウザを再スキャン」ボタンで強制再スキャンできる。
- **手動ワンクリック認可（フォールバック）**：パネルの「プラットフォーム接続」で platform.deepseek.com/usage を開き回伝コマンドをクリップボードへコピー、コンソールに貼り付けて実行するとトークンが返送される。タッチデバイスは「手動入力」を利用できる。

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-api-balance;
    id = "api-balance";
    name = "@kihara777/dsh-api-balance";
    # config（任意）：
    #   apiKeyEnv = "DEEPSEEK_API_KEY";   # credential-ref
    #   baseURL = "https://api.deepseek.com";
    #   browserScan = true;               # ローカルブラウザ自動スキャン
    #   browserScanIntervalMs = 21600000; # スキャン節流（デフォルト 6 時間）
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
    package = pkgs.dsh-nixos-shell;
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

dsh 0.1.1-rc.2 の内蔵プラグイン entry id（`nixkits.dsh.plugins.disabled` の有効値、`id -> パッケージ`）：

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
