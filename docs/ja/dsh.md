# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.1.5-rc.2` |
| 開発チャネル | `dsh-alpha 0.1.6-alpha.2`（npm `alpha` dist-tag） |
| ライセンス | MIT |
| コマンド | `dsh` |

## バージョンチャネル

NixKits は ruyi の薄いラッパーパターン（本体定義 + バージョン/ハッシュ上書きラッパー）に倣い、複数の dsh バージョンを同時に提供する：

| パッケージ | チャネル | バージョン | 説明 |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.1.5-rc.2` | npm `latest` dist-tag、既定 |
| `pkgs.dsh-alpha` | alpha | `0.1.6-alpha.2` | npm `alpha` dist-tag、最新開発版を追跡 |

```nix
# 本機で最新開発版に切り替える
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` は上流の開発チャネル：内蔵プラグイン一覧はバージョンごとに変化する（下記の一覧は stable `0.1.5-rc.2` に対応。alpha は実行時に実際に読み込まれたものを基準とする）。アップグレード前に [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) の確認を推奨。

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

> **dsh ≥ 0.1.6-alpha.2 ではプラグイン改名がハード失敗になる**：内蔵プラグイン `dsh-workflow-worker-thread` は 0.1.6 で `dsh-workflow-ptc` に改名された（`id` とパッケージ名が同時に変わり、`config` は不変）。旧名の組合せ行には対応するパッケージディレクトリがもう存在しない。dsh ≤ alpha.1 は解決できないプラグイン行を**黙って無視**していた——プリセットはそのまま読み込まれ、問題は痕跡を残さない。alpha.2 のプラグインリゾルバはこれを**ハード失敗**に変え、Agent プリセット全体がマウントできず、セッション作成時に `preset "…" failed to mount: row "…" names a plugin that cannot be resolved` と出るだけになる。dsh を更新する前に API で自己検査できる：`agentPresets/list` が返す各プリセットには `broken` フィールドがあり（**このフィールドが無ければ上流の健全性判定を通過しており、マウント可能**）。

### プラグイン更新とゼロ再起動活性化

プラグインパッケージは**安定マウントポイント**経由で読み込む：activation script が毎回の switch/boot で `/run/dsh/current`（dsh 本体とプラグイン木）と `/run/dsh/nixos-shell`（sudo 実行スクリプト）のシンボリックリンクを現在世代の store パスへ張り替える（GC 安全：リンク先は常に現在の toplevel 閉包内にあり、ロールバック時は旧世代のパスへ自動で戻る）。`dsh.service` と `nixkits-sudo@.service` のユニット定義はこれら安定パスのみを参照するため、**プラグインパッケージの更新でユニット内容は変わらない**——switch-to-configuration は dsh を再起動せず、sudo socket も stop/start しない。活性化は実行中のツール呼び出しを一切中断しない。

トレードオフ：dsh は長寿命プロセスのため、プラグイン／プリセットパッケージの更新反映には明示的な再起動が必要——**まず `systemctl daemon-reload`、次に `systemctl restart dsh`**（`nixos_shell` は後者を一時ユニットへ自動分離し、再起動前に呼び出しが返る）。restart だけでは前世代の pre-start スクリプトが実行されることがあり、それこそが `cordis.patch.yml` を `$DSH_HOME` へコピーする工程（プリセットルートはそのファイルに書かれている）なので、「サービスは再起動したのにプリセットが古いまま」という症状になる。再起動後は `$DSH_HOME/profiles/<profile>/cordis.patch.yml` の store パスが実際に切り替わったか確認する。sudo 実行器は接続ごとに生成されるため、新規接続は自動的に新スクリプトを使用し、再起動は一切不要。

## NixKits プラグイン

リポジトリ内で dsh 向けに開発された独立プラグインは**本文書では展開せず**、各プラグインが独立ドキュメントを維持する（マウント方法は上文の `plugins.packages` を参照）：

| プラグイン | 説明 | ドキュメント |
|------|------|------|
| dsh-nixos-shell | NixOS シナリオ能力の統合：`nixos_shell` 実行器（PATH 注入 / `nix shell` ツールブートストラップ / sudo デーモンルーティング）+ `nixos_cli` 読み取り専用診断；NixOS模式 / 維護模式の 2 つの Agent プリセットを同梱 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量パネルの「用量 / 残高」切替：アカウント残高、日 / 月 / 30 日間の消費チャートと音声放送（音声パック形式ガイドを含む） | [dsh-api-balance.md](dsh-api-balance.md) |

## モード

「モード」は dsh の **Agent プリセット**である：各モードは一つのセッション形態であり、専用のアイデンティティプロンプト、ツール面、プロンプト節を備える。プラグインと同級で、それぞれ独立したドキュメントを持ち、互いに影響しない：

| モード | id | 説明 | 配布方式 | ドキュメント |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時に NixOS ホストを検証（非 NixOS は全実行を拒否）；`nixos_shell` / `nixos_cli` と開発プロンプトを読み込む | dsh-nixos-shell パッケージ内、seed-once | [modes/nixos.md](modes/nixos.md) |
| 維護模式 | `maintenance` | NixOS模式から派生；`write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` スキルと保守ワークフローを注入 | dsh-nixos-shell パッケージ内、seed-once | [modes/maintenance.md](modes/maintenance.md) |
| 新聞三要素模式 | `news-three-elements` | 極簡模式から派生した読取専用の創作モード：「新聞三要素」は必ず揃う三人の主人公、素材優先（接続できないときだけ拒否）、素材共創は検索してから書き直す（検索が無ければ退稿）、オンライン技能パッケージ、開始時問答、簡体中文以外は一律拒否 | **独立パッケージ** `dsh-preset-news-three-elements`、roster のプリセットルートとして登録 | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` — NixOS模式
    maintenanceMode = true;   # id `maintenance` — 維護模式（NixOS模式から派生）
    newsThreeElements = true; # id `news-three-elements` — 独立パッケージ、プリセットルートを登録
  };
}
```

> **二つの配布方式**：`nixosMode` / `maintenanceMode` は dsh-nixos-shell パッケージが **seed-once** で `$DSH_HOME/.agent-presets/<id>` へコピーする（対象が既に存在すれば上書きせず、ユーザーの後続編集を尊重する）；`newsThreeElements` は**独立パッケージ** `dsh-preset-news-three-elements` が提供する——モジュールはその `share/dsh-agent-presets` を `agent-presets` roster の追加ルートとして登録し、プリセットは store から直接読まれ、コピーも書込みもなく、更新即最新となる。各モードの挙動・コンポジション構造・保守ルールは上表のドキュメントを参照。

### dsh 0.2.0 におけるプリセット形式の変化（準備段階）

dsh 0.2.0 は Agent プリセットの保持方式を作り直し、**ディレクトリ型プリセットの経路は削除された**：

| | 0.1.x（現行デプロイが使用中） | 0.2.0 |
|---|---|---|
| プリセットの形態 | `$DSH_HOME/.agent-presets/<id>/` ディレクトリ | profile のユーザー patch 層（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）内の一つの loader patch エントリ |
| コンポジションとメタデータ | `agent.cordis.yml`（完全なコンポジション）+ `preset.yml`（`name` / `description`） | `@deepseek-ai/dsh-agent-preset` 行の `config.plugins`（プラグイン行）+ `config.name` / `config.description` |
| 検出方法 | `@deepseek-ai/dsh-agent-presets`（複数形）が root を走査 | Loader ツリーそのもの；複数形パッケージは 0.2.0 に**既に存在しない** |
| roster の並び順 | なし | `config.order`（内蔵プリセットが 1–4 を占め、プリセット間で一意でなければならない） |

**現在の状態：準備段階、未移行。** 本リポジトリには新形式ファイル `packages/dsh-nixos-shell/presets/{nixos-mode,maintenance-mode}/preset.patch.yml` を追加し、旧 `agent.cordis.yml` / `preset.yml` と**二重に併存**させている（0.1.x 経路は依然として旧ファイルを使う）；`develop/check-preset-derivation.py` は両経路の派生関係を同時に検査する。`modules/dsh.nix` は依然として 0.1.x の seed-once 方式で `$DSH_HOME/.agent-presets/<id>` へコピーし、`packages/dsh.nix` も `0.1.5-rc.2` のままで——**現時点でモジュール／ランタイムの変更は一切入っていない**。各モード自体の説明は上表のドキュメントを参照。

新形式ファイルは実機の `dsh 0.2.0-rc.2`（使い捨て `DSH_HOME` + `agentPresets/list`）で検証済み：`nixos`（order 10）と `maintenance`（order 11）の `broken` はいずれも空。いずれか一行のパッケージ名を存在しないものに変える、あるいは `tool-fs-search` の必須項目 `sampleOverCapGlobResults` を削ると、同じエントリが直ちに具体的な `broken` を報告する——判定基準そのものに識別力がある。

旧ファイルに対する**三つの必然的な差異**（そのまま持ってくると壊れる）：

1. **`baseUrl` の意味が変わった**。0.1.x ではプリセット自身のディレクトリだったが、0.2.0 では実測で **profile ディレクトリ**（`$DSH_HOME/profiles/<profile>/`）である。旧ファイルは skills ルートを `new URL('skills/', baseUrl)` と書いており、そのまま移すと `<profile>/skills/` を指して技能が**静かに消える**；新ファイルは `baseUrl` から `@kihara777/dsh-nixos-shell` のパッケージルートを解決し `presets/<mode>/` を連結する——解決に失敗すればプリセット全体が `broken` になり、「技能が無い」状態へ退化しない。
2. メタデータ（旧 `preset.yml` の `name` / `description`）は `config.name` / `config.description` へ移動した。
3. `config.order` が新設された。

**プラグイン行ごとの config schema 差分**（両経路のビルド成果物にある各プラグインの `Config` schema を一行ずつ比較、`0.1.6-alpha.2` → `0.2.0-rc.2`）：

| プラグイン行 | 変化 | 本プリセットへの影響 |
|--------------|------|----------------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | 任意項目 `promoteOnTimeout` を追加（既定 `true`） | 本プリセットは当該キーを設定していない → 0.2.0 からはフォアグラウンドの bash がタイムアウトに達すると殺されず**バックグラウンドジョブへ昇格**する。挙動変化であり、着地前に受け入れるか明示的に固定するかを決める必要がある |
| `dsh-tool-workflow` | 任意項目 `enableRunInBackground` を追加（既定 `true`） | 未設定 → バックグラウンド能力が増える |
| `dsh-tool-ask-user` | 「Config なし」から `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }`（既定 `legacy` / `120`）へ | 未設定 → 旧版と同じ挙動 |
| `dsh-compaction-basic` | 任意項目 `headroomTokens` を追加（`modelPolicies[]` 内にも同名フィールドを追加） | 未設定 → 調整項目が一つ増えるだけ |
| `dsh-tool-jobs` | `maxConsecutiveWakes` は残るが、schema の既定値出力には現れなくなった | 未設定 |
| `dsh-tool-fs-search` | **変化なし**：`sampleOverCapGlobResults` は**必須の真偽値**で、0.1.6 の時点で既にそうだった | 旧ファイルが既に `false` を持つ；新ファイルもそのまま引き継ぐ |
| 残り 20 のプラグイン行 | schema は逐字同一 | 変更不要 |

> 比較対象には `dsh-tool-subagent` の `backgroundMode` / `maxDepth` の合併型、`dsh-plan-mode` が自前実装する厳格な `{ section }` 検証（未知のキーは即エラー）、および本リポジトリの `@kihara777/dsh-nixos-shell` 三行も含まれ、いずれも変化はない。

**着地までに残る作業**（本リポジトリでは未実施）：

- `modules/dsh.nix`：0.2.0 ではプリセットは「ディレクトリをコピーする」ものではなく、`$DSH_HOME/profiles/<profile>/cordis.patch.yml` へ patch エントリを書き込むものになる；
- ホスト側：0.1.x の `agent-presets`（複数形）ホスト行とその settings ネームスペースは 0.2.0 で `agent-preset-registry` になる——`default` は**その行の必須 config**（settings キーではなくなる）となり、settings に残るのは `selectedDefault` のみ（ネームスペース名は行の id）、`roots` の仕組みは丸ごと消える（`settings.yaml` にある既存の `agent-presets.default` は書き換えが必要）；
- 独立パッケージ `dsh-preset-news-three-elements` もディレクトリ型プリセットであり、併せて変換が必要；
- 新形式ファイルの persona にある「プリセットは `.agent-presets/<id>/` に住む」という文言は 0.2.0 では成立しない（ファイル内に `⚠️ 移行 TODO` コメントを残してあり、意図的に未修正——書き換えるとモデルへ送るプロンプトが変わるため）；
- 上表の挙動を変える既定値（`promoteOnTimeout` など）を一件ずつ判断する。

## sudo デーモン

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

dsh 0.1.5-rc.2 の内蔵プラグイン entry id（`nixkits.dsh.plugins.disabled` の有効値、`id -> パッケージ`）：

> **一覧の生成方法**：`dsh --profile web --dump-default-config`（読み取り専用）の出力がそのまま `id -> name` 形式。dsh を更新したら再実行し、導入版の出力を正とする。本一覧は web プロファイルの base + web-app パッチセットに対応する。

```text
  agent -> @deepseek-ai/dsh-agent
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  agent-loop -> @deepseek-ai/dsh-agent-loop
  agent-presets -> @deepseek-ai/dsh-agent-presets
  api-remotes -> @deepseek-ai/dsh-api-remotes
  approval -> @deepseek-ai/dsh-user-approval
  attachment-local -> @deepseek-ai/dsh-attachment-local
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  client-hmr -> @deepseek-ai/dsh-client-hmr
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
  deepseek-llm-api-extensions -> @deepseek-ai/dsh-deepseek-llm-api-extensions
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  file-upload -> @deepseek-ai/dsh-client-file-upload
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  hmr -> @deepseek-ai/cordis-plugin-hmr
  jobs -> @deepseek-ai/dsh-jobs-local
  llm -> @deepseek-ai/dsh-llm
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  llm-retry -> @deepseek-ai/dsh-llm-retry
  locale -> @deepseek-ai/dsh-client-locale
  message-feedback -> @deepseek-ai/dsh-message-feedback
  modules -> @deepseek-ai/dsh-client-modules
  open-in-app -> @deepseek-ai/dsh-host-open-in-app
  permission -> @deepseek-ai/dsh-permission-presets
  plan-mode -> @deepseek-ai/dsh-plan-mode
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  plugin-package-inventory-deepseek -> @deepseek-ai/dsh-plugin-package-inventory-deepseek
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  resources -> @deepseek-ai/dsh-client-resources
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  session-controller -> @deepseek-ai/dsh-api-session-controller
  session -> @deepseek-ai/dsh-session
  session-log-deepseek -> @deepseek-ai/dsh-session-log-deepseek
  session-log-download -> @deepseek-ai/dsh-session-log-export
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  session-projection -> @deepseek-ai/dsh-session-projection
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-reference -> @deepseek-ai/dsh-session-reference
  session-stats -> @deepseek-ai/dsh-session-stats
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  session-turn-outline -> @deepseek-ai/dsh-session-turn-outline
  settings-controller -> @deepseek-ai/dsh-api-settings-controller
  settings -> @deepseek-ai/dsh-settings-file
  shell-env -> @deepseek-ai/dsh-shell-env
  skill-badge -> @deepseek-ai/dsh-skill-badge
  skill -> @deepseek-ai/dsh-skill
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  storage -> @deepseek-ai/dsh-storage
  storage-domain -> @deepseek-ai/dsh-storage-domain
  storage-json -> @deepseek-ai/dsh-storage-json
  subagent -> @deepseek-ai/dsh-subagent
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  subagent-model-selection-settings -> @deepseek-ai/dsh-tool-subagent/model-selection-settings
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
  tools -> @deepseek-ai/dsh-tools
  tool-skill -> @deepseek-ai/dsh-tool-skill
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-web -> @deepseek-ai/dsh-tool-web
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  typert -> @deepseek-ai/dsh-typert-registry
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  typert-loader -> @deepseek-ai/dsh-typert-loader
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-approval -> @deepseek-ai/dsh-client-ui-approval
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-chat -> @deepseek-ai/dsh-client-ui-chat
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
  ui-open-in-app -> @deepseek-ai/dsh-client-ui-open-in-app
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-schedule -> @deepseek-ai/dsh-client-ui-schedule
  ui-session -> @deepseek-ai/dsh-client-ui-session
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-sidebar-documentpreview -> @deepseek-ai/dsh-client-ui-sidebar-documentpreview
  ui-sidebar-files -> @deepseek-ai/dsh-client-ui-sidebar-files
  ui-sidebar-right -> @deepseek-ai/dsh-client-ui-sidebar-right
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
  web-fetch-http -> @deepseek-ai/dsh-web-fetch-http
  web-runtime -> @deepseek-ai/dsh-web-app
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  webserver -> @deepseek-ai/dsh-host-webserver
  web-startup -> @deepseek-ai/dsh-web-app/startup
  workflow-worker-thread -> @deepseek-ai/dsh-workflow-worker-thread
  workspace-controller -> @deepseek-ai/dsh-api-workspace-controller
  workspace -> @deepseek-ai/dsh-workspace
  workspace-files -> @deepseek-ai/dsh-api-workspace-files
```

## 設定の宣言的構成

dsh の設定メニュー項目は `$DSH_HOME/settings.yaml`（ファイルバックアップ、ホットリロード）に格納される。`nixkits.dsh.settings` で宣言的構成が可能（namespace → section）：

```nix
{
  nixkits.dsh.settings = {
    "web-search-deepseek" = {
      model = "deepseek-flash";
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


### 宣言的に設定可能な host ネームスペース

`nixkits.dsh.settings` は**host 側で `settings.installSection` / `settings.register` により登録された**名前空間にのみ書き込める——これらの値は `$DSH_HOME/settings.yaml` に置かれ、ブラウザ間で一致する。`0.1.6-alpha.2` が登録する全 **15** 名前空間とフィールド（プラグインソースの `z.object({...})` / `Schema.object({...})` から一つずつ実測抽出）：

| namespace | フィールド | 説明 |
|-----------|-----------|------|
| `agent-default-model` | `provider`、`model`、`reasoningEffort`（`off`/`low`/`high`/`max`） | 新規セッションの既定モデル |
| `agent-loop` | `maxParallelToolCalls`（整数 ≥1、既定 10） | 1 ターンあたりの並列ツール呼び出し上限 |
| `agent-presets` | `default`（プリセット id；スキーマに既定値なし、組合行の `standard` が受け止める）、`modeSelectionEnabled`（ブール、基線 true） | Agent プリセットと切替入口 |
| `llm-deepseek` | `protocol`、`apiKeyEnv`、`baseURL`、`thinking`、`reasoningEffort`、`maxTokens`、`defaultContextWindow`、`streamIdleTimeoutMs`、`models`、`retryPolicy`、ほかファイル/画像のバイト予算 | ネイティブ DeepSeek アダプタ |
| `llm-pi-ai` | `providers`（辞書：ルート → プロバイダ profile） | pi-ai アダプタのプロバイダルート表（本機の llama-local ルートはここ） |
| `locale` | `preference`（BCP 47；内蔵 `zh`/`en`） | インターフェース言語 |
| `permission` | `defaultPreset`（**必須**；値は presets 表のキー名） | 権限プリセット |
| `shell` | `cwd`（**既定値なし**）、`timeoutMs`、`maxTimeoutMs`、`maxOutputBytes`、`maxSpillBytes`、`graceMs` | ローカル shell 実行器の制限（Linux は bash-local、win32 は pwsh-local で `pwshPath` が増える） |
| `subagent` | `maxDepth`（整数 ≥0、既定 1）、`maxActiveSubagents`（整数 ≥1、既定 8） | サブエージェントの深さと同時実行上限 |
| `subagent-model-selection` | `enabled`（ブール、既定 false）、`allowedModels`（`{provider, model}` 配列） | サブエージェントのモデル選択 |
| `ui-chat` | `transcriptView`（`normal`/`compact`） | 会話記録の表示密度 |
| `ui-conversation` | `busyEnter`（`queue`/`steer`） | ビジー時の Enter 動作 |
| `ui-onboarding` | `welcomeNoticeVersion` | オンボーディング手順の状態（dsh が自ら書き込む） |
| `ui-theme` | `preference`（`light`/`dark`/`system`）、`fontSize`（12–17） | 外観とテーマ |
| `web-search-deepseek` | `apiKey`（secret）、`apiKeyEnv`、`baseURL`、`model`（既定 `deepseek-v4-flash`）、`apiVersion`、`maxTokens`（≥1、既定 4096）、`maxUses`（≥1、既定 5） | Web 検索バックエンド |

> ⚠️ 本表はかつて `0.1.5-rc.2` に基づいて転記され、うち **5 行が実測と不一致**だったため、2026-09-23 に項目ごとに照合して修正した：
> `locale` のフィールドは `language` ではなく `preference`；`ui-theme` は `preference`/`fontSize` のみ
> （`dark`/`light`/`body` フィールドは無い——`dark`/`light` は `preference` の**値**）；
> `shell` に `dshHome` フィールドは存在せず、実際は実行器の制限 6 項目；`subagent-model-selection`
> のトップレベルは `enabled`/`allowedModels`（`provider`/`model` は**配列要素**のフィールド）；
> `agent-default-model` は `provider`/`model` のみ必須で、`reasoningEffort` は省略可能。
>
> **判据**：本表はプラグインソースを読むことによってのみ得られる。「もっともらしく見える」フィールド名はどれも記憶の産物でありうる——
> 次回 dsh をアップグレードする際は再実測すること。本表に増分の推測を重ねないこと。

> ⚠️ **2026-10-02 の第 2 回照合（`0.1.6-alpha.2`）**：項目数は 12 から **15** に訂正——旧表は
> **host 名前空間を 3 つ見落としていた**：`llm-deepseek`、`llm-pi-ai`、`subagent`（前二者は
> モデルアダプタが、最後は `@deepseek-ai/dsh-subagent` が登録する。旧来の grep は
> `installSection` の呼び出し箇所しか見ておらず、これらを取りこぼしていた）。同じ照合で
> 旧判断を一つ覆した：「`shell` の `cwd` は既定値なし ⇒ 部分宣言は不可」は**誤り**——
> schemastery で `.required()` を書いていないフィールドは元から任意である（実測：
> `z.object({cwd: z.string()})({})` は通る）。欠落が `missing required value` になるのは
> `.required()` を付けた場合だけである。
>
> 照合の口径：インストールツリー全体で `grep -rn 'settings\.installSection(\|settings\.register('`
> の**呼び出し箇所**を正とする（`@deepseek-ai/dsh-settings` 自身とその読み手 `dsh-tool-cordis`
> はこの API の**実装**であり、namespace を登録する側ではない）。

> **設定メニューのストレージ境界**：設定 UI の全項目が `nixkits.dsh.settings` で宣言的に設定できるわけではない。**dsh-api-balance の界面 / 音声設定**（音声アラート、下部統計バー横スクロール、Enter改行 + Shift+Enter送信の交換、モバイルセッション切替時のキーボード抑止、TTS バックエンド）は**ブラウザ localStorage 状態**（ブラウザごとの独立・既定 ON・UI 内で切替）であり、`settings.installSection` システムを経由しない——そのため `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` はこれらを上書き**しない**。こうした「ブラウザごとの設定」は当プラグインの `⚙ 設定` パネルで行うか、デバイスごとに別ブラウザを用意する。

### 構造化オプションとエスケープハッチの役割分担

上表の 15 名前空間はいずれも `nixkits.dsh.settings.<namespace>` から直接書き込める——それは**型なしのエスケープハッチ**である。その代償は二種類あり、**一つは静かで、一つは音を立てる**：

- **フィールド名の書き間違い → 完全に静か**。schemastery の `z.object` は**開いている**：未知のキーはそのまま保持され、本来書きたかったフィールドはスキーマ既定値を食べ続ける。実測（`0.1.6-alpha.2`）：`schema({ maxParallelToolCall: 4 })` は `{ maxParallelToolCalls: 10, maxParallelToolCall: 4 }` を返す——評価時のエラーも実行時のエラーもログも無く、**値が効かなかったことだけ**が残る。
- **型の誤り / 範囲外の値 → 音は出るが、ログの中だけ**。dsh はそのセクションを拒否する：起動時は当該 namespace の登録自体が失敗し、実行中のホットリロードでは `settings: keeping last good "<ns>" after invalid stored section` の warn を出して直前の良い値を保持する。

そこで本モジュールはこのうち 13 に**構造化オプション**を提供する（Nix 側で上流スキーマを写し取り、上述の二種類の誤りを評価時のエラーに変える）：

| オプション | 書き込む namespace | 対応プラグイン |
|------|------------------|----------|
| `nixkits.dsh.defaultModel` | `agent-default-model` | `@deepseek-ai/dsh-agent-default-model` |
| `nixkits.dsh.agentLoop` | `agent-loop` | `@deepseek-ai/dsh-agent-loop` |
| `nixkits.dsh.subagentModelSelection` | `subagent-model-selection` | `@deepseek-ai/dsh-tool-subagent` |
| `nixkits.dsh.permission` | `permission` | `@deepseek-ai/dsh-permission-presets` |
| `nixkits.dsh.agentPresets` | `agent-presets` | `@deepseek-ai/dsh-agent-presets` |
| `nixkits.dsh.subagent` | `subagent` | `@deepseek-ai/dsh-subagent` |
| `nixkits.dsh.shell` | `shell` | `@deepseek-ai/dsh-bash-local` / `dsh-pwsh-local`（namespace は `@deepseek-ai/dsh-shell` に属する） |
| `nixkits.dsh.webSearchDeepSeek` | `web-search-deepseek` | `@deepseek-ai/dsh-web-search-deepseek` |
| `nixkits.dsh.llmDeepSeek` | `llm-deepseek` | `@deepseek-ai/dsh-llm-deepseek` |
| `nixkits.dsh.locale` | `locale` | `@deepseek-ai/dsh-client-locale` |
| `nixkits.dsh.ui.theme` | `ui-theme` | `@deepseek-ai/dsh-client-ui-theme` |
| `nixkits.dsh.ui.chat` | `ui-chat` | `@deepseek-ai/dsh-client-ui-chat` |
| `nixkits.dsh.ui.conversation` | `ui-conversation` | `@deepseek-ai/dsh-client-ui-conversation` |

**三者は意味が一貫している**：オプションは既定で `enable = false`（settings.yaml に書き込まず、当該 namespace はスキーマ既定へフォールバック）；`enable = true` ならサブオプションに従って当該セクションを生成；**`nixkits.dsh.settings.<同名 namespace>` が常に優先**され、構造化オプションが生成した値に勝る。

残る二つの namespace には**意図的に構造化オプションを与えない**。理由はそれぞれ異なる：

- `ui-onboarding`：純粋にクライアント側のオンボーディング状態（`welcomeNoticeVersion` はユーザーがオンボーディングを終えた時に dsh 自身が書き込む）。宣言的に書く正当な用途が無く、書けば外部から与えたバージョン番号に従ってオンボーディングが再生または skip されるだけ——ユーザーがクリックして進むべき状態であって、Nix が決める状態ではない。
- `llm-pi-ai`：フィールドは `providers` 辞書（ルート → プロバイダ profile）であり、profile は**深くネストしている**（`models` カタログ、`modelOverrides`、`compat`、`thinkingBudgets`、`retryPolicy` など）。しかも `api` の列挙は内蔵 pi-ai プロトコル登録簿 `supportedProtocols()` に由来する——**pi-ai のバージョンで動く開いた集合**なので、型化すれば「設定できるように見えて新しいプロトコルを拒む」形で即座に腐る。本機では既により適した置き場所がある：`nixkits.dsh.plugins.settings."llm-pi-ai".providers`（組合行 config。上の「プラグインの宣言的管理」節を参照）。

フィールドの書き込み方針（どれが具体的な既定値を持ち、どれが `null` で「宣言しない」を表すか）：

- スキーマに既定値があり、内蔵の組合行 config もそれと一致する → 具体的な既定値を無条件に書き込む（宣言しない場合と意味は同じ）；
- スキーマに既定値が無い（デプロイ/アダプタ/プロセス環境が決める）、または組合基線がスキーマ既定から**逸れている** → `null` を「宣言しない」として使い、描画時に落とす。

二つ目は潔癖ではない：`shell` の `timeoutMs` がその実例である——スキーマ既定は 120000 だが、内蔵 `bash-sandbox` 行は **60000** に設定している。「enable は全量書き込み」なら `shell.enable = true` が 60000 を静かに 120000 へ変えてしまい、それは本モジュールが防ぐために存在する静かな値の書き換えそのものである。だから `nixkits.dsh.shell.timeoutMs = null`（既定）は 60000 を保ち、明示的に 120000 を書いた時だけ上流既定に戻る。同様に `web-search-deepseek.baseURL` と `llm-deepseek.baseURL` は `null` のままにする：未指定時は `$DEEPSEEK_SEARCH_BASE_URL` / `$DEEPSEEK_BASE_URL` にフォールバックするため、リテラルを書き込むと環境変数を覆い隠す。

また `web-search-deepseek.apiKey` は意図的に写し取らない：`role("secret")` を持つため、settings.yaml に書けば API キーが `/nix/store`（世界可読）に落ちる。鍵は `apiKeyEnv` と systemd `LoadCredential` を通す。

```nix
{
  nixkits.dsh = {
    # 新規セッションの既定モデル
    defaultModel = {
      enable = true;
      provider = "deepseek-official";
      model = "deepseek-flash";  # 三つの目録すべてに存在し、いずれでも image モダリティを宣言する唯一の id
      reasoningEffort = "max";
    };
    # 1 ターンの並列ツール呼び出し上限
    agentLoop = { enable = true; maxParallelToolCalls = 10; };
    # サブエージェントが選べるモデルの許可リスト（enable は当該機能の enabled も同時に開く）
    subagentModelSelection = {
      enable = true;
      allowedModels = [
        { provider = "deepseek-official"; model = "deepseek-flash"; }
      ];
    };
    # 新規セッションの既定権限プリセット（値は組合行の presets 表から）
    permission = { enable = true; defaultPreset = "danger-full-access"; };
    # 新規セッションが既定でマウントする Agent プリセット
    agentPresets = { enable = true; default = "lampkeeper"; };
    # サブエージェントの深さと同時実行上限
    subagent = { enable = true; maxDepth = 2; maxActiveSubagents = 12; };
    # ローカル shell 実行器：変えたいフィールドだけ書く。未指定は組合基線のまま（timeoutMs の基線は 60000）
    shell = { enable = true; timeoutMs = 300000; maxTimeoutMs = 1800000; };
    # Web 検索バックエンド
    webSearchDeepSeek = { enable = true; model = "deepseek-flash"; maxTokens = 8192; };
    # ネイティブ DeepSeek アダプタ：思考とストリームのアイドルタイムアウト
    llmDeepSeek = {
      enable = true;
      thinking = "enabled";
      reasoningEffort = "high";
      streamIdleTimeoutMs = 3600000;  # チャンク間の間隔タイムアウトであり、総所要時間ではない
    };
    # インターフェース言語を中国語に固定；未設定なら各ブラウザの Accept-Language に従う
    locale = { enable = true; preference = "zh"; };
    ui = {
      theme = { enable = true; preference = "dark"; fontSize = 14; };
      chat = { enable = true; transcriptView = "compact"; };
      conversation = { enable = true; busyEnter = "queue"; };
    };
  };
}
```


### デフォルトモデル（defaultModel）

`nixkits.dsh.defaultModel` は新規セッションのデフォルトモデル向けの構造化された宣言的オプション（`@deepseek-ai/dsh-agent-default-model` 経由で `settings."agent-default-model"` に書き込む）。既定は `enable = false`（注入なし）；`enable = true` で下記サブオプションを描画し、**明示的な `nixkits.dsh.settings."agent-default-model"` が常に優先**される：

```nix
{
  nixkits.dsh.defaultModel = {
    enable = true;
    provider = "deepseek-official";  # 既定
    model = "deepseek-flash";        # 既定
    reasoningEffort = "off";         # 既定
  };
}
```

#### モデル目録は dsh のバージョンに追随する

`deepseek-official` ルートのモデル目録はアダプタに**内蔵**されており（`dsh-llm-deepseek` の `DEFAULT_MODELS`）、設定ファイルからは読まれない。したがって dsh のバージョンごとに変化する：

| dsh バージョン | 目録の項目 | うち image モダリティを宣言するもの |
|----------------|-----------|-----------------------------------|
| stable `0.1.5-rc.2`、alpha `0.1.6-alpha.1` | `deepseek-flash`、`deepseek-v4-flash`、`deepseek-v4-pro`、`deepseek-v4-flash-vision-exp` | `deepseek-flash`、`deepseek-v4-flash-vision-exp` |
| alpha `0.1.6-alpha.2` | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |

`deepseek-flash` は三つの目録**すべてに存在**し、かつ**いずれでも image モダリティを宣言する**唯一の id であり、モジュールの既定値がこれを選ぶ理由でもある。もう一方の画像対応 id `deepseek-v4-flash-vision-exp` は古い二つの目録にしか無く、上流が 2026-09-10 に廃止したため既定値には使えない。

上流が 2026-09-10 に DeepSeek-V4.1-Flash を公開した際、V4 Flash と V4 Flash Vision Exp を廃止し、モデル名は `deepseek-flash`（画像理解を備える）と `deepseek-v4-pro` に収束した。旧 id は互換のため引き続き呼び出せるが、処理は V4.1-Flash が行い、Flash の料金で課金される（[モデルと価格](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/)の脚注を参照）。

> ⚠️ **目録に無い id は「名前が違うだけの同じもの」ではない**：dsh は未収録の id を**テキスト専用**モデルとして扱う（`modelInfo` が `inputModalities: ["text"]` にフォールバックする）。その帰結は二つの経路に分かれ、**片方は鳴り、片方は無言である**：
>
> - **新しく添付した画像はその場で拒否される**：`session/prompt` の添付准入が同じ `inputModalities` を読み、`MODEL_DOES_NOT_SUPPORT_IMAGES` を投げる。UI には「現在のモデルは画像に対応していません」と表示される。
> - **履歴に既にある画像は無言で捨てられる**：送信前に `projectImagesForTextModel` がテキスト記述に置き換える —— エラーは出ず、モデルは画像を一度も見ていない。
>
> 既定値を選ぶときは目録に存在する id を選ぶこと。この判定は dsh のバージョンで変わるため、同じ設定が更新後に「画像を見る」から「画像を拒む」へ転じうる。

#### reasoningEffort の段階とコスト

| reasoningEffort | 動作 | コスト |
|-----------------|------|--------|
| `off` | non-thinking：思考連鎖なし、`thinking:disabled` にマップ | **最安**（reasoning token なし）、遅延最小；**FIM 補完がこの段のみ対応** |
| `low` | 思考オン・最小力度 | off よりやや高（少量の reasoning token） |
| `high` | 既定段（dsh-llm-deepseek アダプタの default は high）、品質/速度均衡 | 出力に推論セグメントが含まれ token 比率増 |
| `max` | 最高力の思考、品質最強 | **最高額**（出力 token 比率最大） |

> `off` → `thinking:disabled` は FIM（Fill-In-The-Middle 補完）を有効化する前提条件（DeepSeek は FIM を「非思考モードのみ対応」と明記）。上流の [FIM 補完 API](https://api-docs.deepseek.com/api/create-completion/) で `model` に取れる値は `deepseek-flash` と `deepseek-v4-pro` の二つのみで、いずれも「非思考モードのみ対応」。
