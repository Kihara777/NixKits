# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.2.0-rc.2` |
| 開発チャネル | `dsh-alpha 0.2.1-alpha.1`（npm `alpha` dist-tag） |
| ライセンス | MIT |
| コマンド | `dsh` |

## バージョンチャネル

NixKits は ruyi と同じ薄いラッパー方式（主定義 + version/hash を上書きする包装）で複数の dsh バージョンを提供する：

| パッケージ | チャネル | バージョン | 説明 |
|----|------|------|------|
| `pkgs.dsh` | stable | `0.2.0-rc.2` | npm `latest` dist-tag、既定。**プリセット内容**はピン留めした rev に凍結 |
| `pkgs.dsh-alpha` | alpha | `0.2.1-alpha.1` | npm **`alpha`** dist-tag、0.2.x 線の最新プレリリースを追跡。**プリセット内容**はリポジトリ HEAD に追随 |

```nix
# 本機で最新プレリリースを使う
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> **`dsh-alpha` が `alpha` を追う理由**（2026-10-08 に戻した）。npm の三つの dist-tag は現在 `alpha` = **`0.2.1-alpha.1`**、一方 `latest` = `next` = `0.2.0-rc.2` —— `alpha` が逆に `next` を**追い越している**。2026-10-02 に `next` へ切り替えた根拠は「`alpha` = `0.1.7-alpha.2` が古い 0.1.x 線に属し stable より**低い**」ことであったが、**その前提は反転した**。`next` を追い続けることは開発チャネルを `alpha` より古い版に固定することに等しい。判定基準は「どちらの tag 名がよりプレリリースらしいか」ではなく、**どちらの tag が 0.2.x 線でより新しい版を指すか**である：再確認のたびに dist-tags を読み直して版を比べ、`alpha` がリードしなくなったら戻せばよい。
>
> 両チャネルの**挙動差は二点**になった：① dsh バージョン（alpha が新しいため hash / `npmDepsHash` / vendored lock は**各自独立**——版が異なる間は stable の lock を共用できない）；② **プリセット内容**：stable のプリセットは `packages/dsh-nixos-shell-stable.nix` がピン留めした commit に凍結され、alpha はリポジトリ HEAD に追随する（下記「モード」参照）。
>
> ⚠️ **0.2.0 はプリセット形式の断層**であり 0.1.x と互換でない：ディレクトリ式プリセット経路（`$DSH_HOME/.agent-presets/<id>/` + `agent.cordis.yml`）は上流で削除された。アップグレード前に下記「モード」と「dsh 0.2.0 におけるプリセット形式の変化」を読むこと。内蔵プラグイン一覧はバージョンとともに動くので、まず [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) を確認する。

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

「モード」とは dsh の **Agent プリセット**である：各モードは一つのセッション形態であり、固有のアイデンティティ提示詞・道具面・提示詞節を持つ。プラグインと同じ階層に並び、それぞれ独立した文書を持ち、互いに影響しない：

| モード | id | 説明 | 配布方式 | 文書 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時にホストが NixOS であることを検証（非 NixOS は一切の実行を拒否）；`nixos_shell` / `nixos_cli` と開発提示詞を読み込む | dsh-nixos-shell パッケージ内、**profile patch 行** | [modes/nixos.md](modes/nixos.md) |
| 维护模式 | `maintenance` | NixOS模式から派生；`write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` 技能とメンテナンス作業流れを注入 | dsh-nixos-shell パッケージ内、**profile patch 行** | [modes/maintenance.md](modes/maintenance.md) |
| 新闻三要素模式 | `news-three-elements` | 極簡模式から派生した読み取り専用の創作モード：「新聞の三要素」= 必ず揃わねばならない三人の主角；素材優先（引き受けられない物のみ拒否）、素材共同創作は先に検索してから書き換える（検索なしは返稿）、オンライン技能包、開場問答、簡体中文以外は一律拒否 | **独立パッケージ** `dsh-preset-news-three-elements`、**profile patch 行 + 内容ディレクトリ** | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` — NixOS模式
    maintenanceMode = true;   # id `maintenance` — 维护模式（NixOS模式から派生）
    newsThreeElements = true; # id `news-three-elements` — 独立パッケージ
    # プリセット内容の出所：既定では dsh チャネルに従う（stable →
    # dsh-nixos-shell-stable、プリセットはピン留め rev に凍結；alpha →
    # dsh-nixos-shell、HEAD に追随）。通常は書かなくてよい。plugins.packages で
    # 注入した @kihara777/dsh-nixos-shell と別系統のときだけ揃える。
    # package = pkgs.dsh-nixos-shell;
  };
}
```

> **0.2.0 以降、配布方式はただ一つ**：各モードは一本の `@deepseek-ai/dsh-agent-preset` patch 行であり（モジュールが `$DSH_HOME/profiles/<profile>/cordis.patch.yml` へ差し込む）、プラグイン行の本文はそのパッケージの `preset.patch.yml` から**逐字**取る。0.1.x の二経路（`nixosMode`/`maintenanceMode` の seed-once ディレクトリ複製、`newsThreeElements` の roster 追加根）は上流の変更とともに消えた——`roots` 機構自体が存在しない。内容ディレクトリを要するのは新闻三要素模式だけである：そのプラグインは npm パッケージではなくプリセット同梱のファイルなので、モジュールが `$DSH_HOME/.agent-presets/news-three-elements/` へ組み立て（整体再構築、seed-once ではない）、patch 行は相対経路で参照する。各モードの挙動・組合構造・保守規則は上表の文書を参照。

> **本リポジトリが配布しないモードが展開側に二つある**：掌灯模式（`lampkeeper`、order 12）と Ocean Spiral（`ocean-spiral`、order 14）。内容の出所は私有リポジトリ（Kitsunome）だが、0.2.0 の形態は上の三つと全く同じ——patch 行一本 + `$DSH_HOME/.agent-presets/<id>/` へ組み立てた内容ディレクトリで、錨は `new URL('../../.agent-presets/<id>/', baseUrl)`（**Ocean Spiral がリポジトリに入ったのは 2026-10-02**、それ以前は展開副本が唯一の実体で、リポジトリも播種も無かった）。両者の一致性検査もそちら側にある：`develop/check-lampkeeper-derivation.py`、`develop/check-ocean-spiral-derivation.py`。

### dsh 0.2.0 におけるプリセット形式の変化（2026-10-02 落地済み）

dsh 0.2.0 は Agent プリセットの担体を作り直し、**ディレクトリ式プリセット経路は削除された**：

| | 0.1.x（0.2.0 以降は使わない） | 0.2.0（現在） |
|---|---|---|
| プリセットの形態 | `$DSH_HOME/.agent-presets/<id>/` ディレクトリ | profile ユーザー patch 層（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）の loader patch 条目一本 |
| 組合とメタデータ | `agent.cordis.yml`（完全な組合）+ `preset.yml`（`name` / `description`） | `@deepseek-ai/dsh-agent-preset` 行の `config.plugins`（プラグイン行）+ `config.name` / `config.description` |
| 発見方式 | `@deepseek-ai/dsh-agent-presets`（複数形）が root を走査 | Loader 木そのもの；複数形パッケージは 0.2.0 に**存在しない** |
| roster 順序 | 無し | `config.order`（内蔵が 1–4、プリセット間で一意でなければならない） |
| 宿主行 | `agent-presets`（複数形）とその `roots` 表 | `agent-preset-registry`；`default` は**その行の必須 config**、settings 側には `selectedDefault` だけが残る |

**リポジトリ HEAD は新形式のみを保守する**：0.1.x の `agent.cordis.yml` は三つのプリセット全てから削除され、両形式は HEAD に併存しない——分岐するのは「取用点」だけである。stable チャネルのプリセット内容は `packages/dsh-nixos-shell-stable.nix` がピン留めした commit（`0175f85`、**両形式が併存した最後の commit**。0.1.x の利用者は rev で取る）から取り、alpha チャネルは HEAD に追随する。凍結の意味は「stable が更新されない」ではなく**更新時点が判定可能**であること：HEAD 上のプリセット変更はまず alpha チャネルで実走し、確認後に `pinnedRev` を一行だけ明示的に進める——HEAD とともに stable チャネルへ静かに流れ込むことはない。

モジュール側（`modules/dsh.nix`）の接線：

- プリセット本文は、モジュールが元々生成している `cordis.patch.yml` へ**逐字**差し込む（別機構を作らない・プラグイン行を複製しない——複製は必ず漂く）；
- 読むのは `dsh-nixos-shell` 変体の `passthru.presetsSource` である（stable 変体は `builtins.fetchTarball` でピン留め rev を取るので、**評価期に原経路を読む**だけで import-from-derivation は無い）；
- チャネル判定は dsh パッケージ自身が宣言する `passthru.dshChannel` から取る。ゆえにチャネル交代は `nixkits.dsh.package` 一行で済み、プリセット内容が追随する；
- `nixkits.dsh.agentPresets.*` は `- id: agent-preset-registry` patch 行を出すように変えた；旧 `settings."agent-presets"` は**評価期に直接エラー**になる——もうどのプラグインも読まないので、残せば宣言した既定プリセットが静かに失われるだけである；
- 注意：注入した `@kihara777/dsh-nixos-shell` と `presets.package` は**同一変体**でなければならない（プリセット本文は後者から来て、技能根は実行時に前者へ解決される）。不一致なら評価期に `lib.warn` が出る。

**プラグイン単位の config schema 差異**（両チャネルの産物にある各プラグインパッケージの `Config` schema を逐条比較、`0.1.6-alpha.2` → `0.2.0-rc.2`）：

| プラグイン行 | 変化 | 本プリセットへの影響 |
|--------|------|----------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | 任意の `promoteOnTimeout` を追加（既定 `true`） | 本プリセットは**この鍵を書かない**（決定：挙動の既定値は上流に追随）→ 0.2.0 以降、前面 bash がタイムアウトに達すると**背景ジョブへ昇格**し、殺されない |
| `dsh-tool-workflow` | 任意の `enableRunInBackground` を追加（既定 `true`） | 未設定 → 背景能力が増える |
| `dsh-tool-ask-user` | 「Config 無し」から `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }`（既定 `legacy` / `120`）へ | 未設定 → 旧版と同じ挙動 |
| `dsh-compaction-basic` | 任意の `headroomTokens` を追加（`modelPolicies[]` 内にも同名欄） | 未設定 → 調整項目が一つ増えるだけ |
| `dsh-tool-jobs` | `maxConsecutiveWakes` は残るが、schema の既定値出力に出なくなる | 未設定 |
| `dsh-tool-fs-search` | **変化なし**：`sampleOverCapGlobResults` は**必須ブール**で 0.1.6 以来そう | 旧ファイルが既に `false` を持つ。新ファイルもそのまま |
| 残り 20 のプラグイン行 | schema は逐字同一 | 変更不要 |

> 比較範囲には `dsh-tool-subagent` の `backgroundMode` / `maxDepth` 合併型、`dsh-plan-mode` の自前の厳格な `{ section }` 検証（未知鍵はエラー）、本リポジトリの `@kihara777/dsh-nixos-shell` 三行も含まれ、いずれも変化なし。

> ⚠️ **今回のアップグレードで日常挙動を変える新しい既定値は `promoteOnTimeout` だけ**である（決定：**プリセットに書かない**、上流に追随）。効果は、前面 bash 呼び出しがタイムアウトに達しても殺されず**背景ジョブへ昇格**し、呼び出し側が job id を受け取るというもの；`job_output` / `job_list` / `job_kill` がタイムアウト後の収拾手段になる。旧挙動（タイムアウト即殺）が要るなら、プリセットでその行に `config.promoteOnTimeout = false` を明示する——本リポジトリは意図的にこの釘を打たず、上流の既定値の進化が届くようにしている。

**旧ファイルに対する四つの必要な差異**（そのまま写すと壊れる）：

1. **`baseUrl` の意味が変わった**。0.1.x ではプリセット自身のディレクトリ、0.2.0 の実測は **profile ディレクトリ**（`$DSH_HOME/profiles/<profile>/`）。旧ファイルは技能根を `new URL('skills/', baseUrl)` と書いており、そのまま写すと `<profile>/skills/` を指し、技能が**静かに消える**。本リポジトリの二つのプリセットは `baseUrl` から `@kihara777/dsh-nixos-shell` のパッケージ根を解決して `presets/<mode>/` を足し、私有リポジトリの二つは `../../.agent-presets/<id>/` を逆算する——どちらも**存在ガード**付きで、錨を誤れば `broken` になり「技能が無い」状態へ退化しない。
2. メタデータ（旧 `preset.yml` の `name` / `description`）は `config.name` / `config.description` へ移った。
3. `config.order` が新しい鍵である。
4. **プラグイン行の相対経路は錨を書き換える必要がある**：相対指定子は `.` で始まねばならない（loader はその形の name だけを `baseUrl` で解決する。**絶対経路は裸のパッケージ名として import され失敗する**）。さらに `baseUrl` が profile ディレクトリになったので、`./plugins/x.js` は `../../.agent-presets/<id>/plugins/x.js` になる。副作用：プリセット同梱のプラグインファイルが裸のパッケージ名で `@deepseek-ai/*` の peer を import する場合、モジュールは `@deepseek-ai` も `$DSH_HOME/node_modules` へ張らねばならない。さもなければその行は `… never started` としか報告しない（下記「プリセットのマウント判定」参照）。

#### プリセットのマウント判定（本当に載ったかをどう知るか）

**「roster に居る」は移行成功ではない**：プリセットが載らないとき、0.2.0 は `agentPresets/list` の各条目に `broken` 欄を返すだけである——**この欄が無ければ上流の健全性判定を通過**している。判定は実行可能である：

```bash
# 使い捨て実例の手順：dsh を起動 → boot.log から token を取る → cookie に交換 → RPC を呼ぶ
curl -sS -b cookies -H 'content-type: application/json' \
  -d '{"type":"client-request","rpcId":"1","method":"agentPresets/list","payload":{"args":{}}}' \
  http://127.0.0.1:<port>/api/agentPresets/list
```

2026-10-02 の落地検収（使い捨て `DSH_HOME`、`dsh 0.2.0-rc.2`）：**9 条目**（内蔵 4 + `nixos` order 10 + `maintenance` 11 + `lampkeeper` 12 + `news-three-elements` 13 + `ocean-spiral` 14）で **`broken` は全て空**；三つの反証はいずれも**実ファイルの一箇所**だけを変えた：

| 反証 | 変えた箇所（一箇所） | `agentPresets/list` が報告した `broken` |
|------|-----------------|-----------------------------------|
| パッケージ名 | `tool-fs-search` のパッケージ名を存在しない `@deepseek-ai/dsh-tool-fs-searchX` へ | `tool-fs-search (@deepseek-ai/dsh-tool-fs-searchX): never started`（派生元を同じくする 5 プリセットが同時に報告） |
| 錨 | Ocean Spiral の技能根 `../../.agent-presets/ocean-spiral/` → `…ocean-spiral-typo/` | `skill-filesystem (…): ocean-spiral skill roots missing: <経路>` + `oceanspiral-scene (…): never started` |
| 組み立て | `$DSH_HOME/node_modules` の `@deepseek-ai` リンクを一本欠かす | `lampkeeper-shell (../../.agent-presets/lampkeeper/components/lib/index.js): never started` |

最後の一行は**今回の落地で実際に直した罠**である：プリセット同梱のプラグインファイルは `$DSH_HOME/.agent-presets/<id>/…` にあり、裸のパッケージ名で peer を import すると Node は**ファイルのあるディレクトリ**から上へ `node_modules` を探す。モジュールは以前 `@kihara777` しか張っておらず、ゆえに「dsh を再起動すると掌灯模式が broken になる」——両者が同じ `$DSH_HOME` の中で互いを踏んでいた。現在は `@kihara777` と `@deepseek-ai` の二本を張る。

**persona と同梱技能（2026-10-02 落地後の修正）**：二箇所の陳腐化した記述を改めた。いずれももはや未決項ではない。

- **persona**：新形式ファイルの「プリセットは `$DSH_HOME/.agent-presets/<id>/` ディレクトリに住む」という一句は 0.2.0 の正確な記述へ改めた——プリセットは profile `cordis.patch.yml` にある `@deepseek-ai/dsh-agent-preset` の条目であり、**発見を担うのはその一行である**；プリセットは依然として自分のファイルを `.agent-presets/<id>/` の下に置き、profile から相対経路で参照できる——本配備のいくつかのプリセットはまさにそうやってプラグインと技能を同梱している。これを書き換えれば**モデルへ送る提示詞**が変わる。挙動変更にあたるため、保守者が別途批准した。
- **同梱技能**：二つのプリセットはかつて `cordis-plugin-development` と `editing-cordis-compositions` の複製を**同梱**していた。0.2.0 はこの二つ（加えて `agent-experience` / `cordis-composition-reference`）を `@deepseek-ai/dsh-agent-preset` とともに配布するが、こちらの二つは 0.1.x のディレクトリ式プリセットモデルに留まっていた——ゆえに同名が二つ並び、うち一つは廃止された書き方を教えていた（上流の新版は *"Nothing reads that directory any more"* と明言している）。現在、二つのプリセットの `skill-filesystem` 行は**上流のそれを直接マウント**する形に変わっており（内蔵 `cordis` プリセットと同一の式）、上流に無い `skills-nixos/`（NixOS 運用技能）だけを残している。`develop/check-preset-derivation.py` は「もはや複製を同梱しない」ことを断言として釘付けにした；同梱していた二つは今も stable チャネルがピン留めした rev から取用できる（0.1.x 互換）。

### 会話フォーマット v4 のメッセージ来源准入（2026-10-03 事故）

dsh 0.2.0 は**会話フォーマット v4** を持ち込んだ。これは**各メッセージの `source`** に一条の准入判据を課す：

> 対象はオブジェクトであり、`kind` は非空、かつ**字面量 `"plugin"` に等しくない**こと。

字面量 `"plugin"` と同级の `plugin: "<名>"` は **v3 時代**のプラグイン来源形状である（0.1.6 時代の
内蔵プラグインがそう書いており、それを丸写しした第三者のプラグインも同様）。v4 では、
**プリセットのプラグインがそのようなメッセージを一つでも会話へ書き込めば准入が拒否する**。
症状は session 全体が「本機実行失敗」となり、エラーはただ一句：

```text
format v4 message requires a producer-owned source kind
```

2026-10-03 の実測：掌灯模式の `journal-catchup` は**新規 session の開始ごと**に注意書きを一件
steer する。ゆえに 0.2.0-rc.2 上では新規 session が作成のたびに崩れ、session ファイルには
メッセージが一件も残らなかった（header・三件のポリシーイベント・`session/end-seed` のみ）
——保守者は会話を続けるためにシステムを巻き戻すしかなかった。同じ形状は本リポジトリの
ニュース三要素プリセットの二つのプラグイン（`news-language.js` / `news-material.js`）にもあり、
同期して直さなければ次の配備で同じように崩れる。

| 帰属 | v3 形状（v4 が拒否） | v4 形状 |
|---|---|---|
| プラグイン来源 | `{ kind: "plugin", plugin: "<名>", form: "notice", … }` | `{ kind: "plugin:<名>", form: "notice", … }` |
| 同名 producer | `{ kind: "plugin", plugin: "user-approval" }` | `{ kind: "user-approval", … }` |
| 人 | `{ kind: "user" }` | 不変 |

判据は `nix flake check` の `session-sources` 項として固定済み
（`develop/check-session-sources.py`）：本リポジトリのプリセットプラグインに
`kind: "plugin"` が現れれば失敗する。`plugin:` 接頭辞はここでの創作ではない——v4 の移行表が
「同名でないプラグイン」に与える名前（`plugin:` + 完全なプラグイン名）であり、履歴の会話が
移行後に取る形状と一致する。

> **巻き戻しの代価**：v4 の会話は**旧版では読めない**（0.1.6 の JSONL 永続化は未知の format
> version を読んだ時点で拒否する。降格読みはしない）。ゆえに「0.2.0 へ上げてから巻き戻す」と
> それ以前の会話が一切開けなくなる——**昇格の前に**プラグインの来源形状を直すこと。
> 巻き戻しを逃げ道と考えないこと。

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

dsh 0.2.0-rc.2 の内蔵プラグイン entry id（`nixkits.dsh.plugins.disabled` の有効値、`id -> パッケージ`）：

> **一覧の生成方法**：`dsh --profile web --dump-default-config`（読み取り専用）の出力がそのまま `id -> name` 形式。dsh を更新したら再実行し、導入版の出力を正とする。本一覧は web プロファイルの base + web-app パッチセットに対応する。

```text
  tool-plugin-manager -> @deepseek-ai/dsh-plugin-manager/tools
  plugin-manager -> @deepseek-ai/dsh-plugin-manager
  timer -> @deepseek-ai/cordis-plugin-timer
  hmr -> @deepseek-ai/dsh-hmr
  llm -> @deepseek-ai/dsh-llm
  deepseek-llm-api-extensions -> @deepseek-ai/dsh-deepseek-llm-api-extensions
  session -> @deepseek-ai/dsh-session
  session-log-deepseek -> @deepseek-ai/dsh-session-log-deepseek
  typert -> @deepseek-ai/dsh-typert-registry
  typert-loader -> @deepseek-ai/dsh-typert-loader
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  user-questions -> @deepseek-ai/dsh-user-questions
  agent -> @deepseek-ai/dsh-agent
  plugin-package-inventory-deepseek -> @deepseek-ai/dsh-plugin-package-inventory-deepseek
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  jobs -> @deepseek-ai/dsh-jobs-local
  llm-retry -> @deepseek-ai/dsh-llm-retry
  config-editor -> @deepseek-ai/dsh-config-editor
  settings -> @deepseek-ai/dsh-settings
  authorization -> @deepseek-ai/dsh-authorization
  deepseek-account -> @deepseek-ai/dsh-deepseek-account-platform
  credentials -> @deepseek-ai/dsh-credentials-local
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  attachment-local -> @deepseek-ai/dsh-attachment-local
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-projection -> @deepseek-ai/dsh-session-projection
  storage -> @deepseek-ai/dsh-storage
  storage-json -> @deepseek-ai/dsh-storage-json
  storage-domain -> @deepseek-ai/dsh-storage-domain
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  otel -> @deepseek-ai/dsh-otel
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  subprocess -> @deepseek-ai/dsh-subprocess-local
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  approval -> @deepseek-ai/dsh-user-approval
  permission -> @deepseek-ai/dsh-permission-presets
  shell-env -> @deepseek-ai/dsh-shell-env
  tool-bash -> @deepseek-ai/dsh-tool-bash
  tool-pwsh -> @deepseek-ai/dsh-tool-pwsh
  tool-jobs -> @deepseek-ai/dsh-tool-jobs
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  tool-fs -> @deepseek-ai/dsh-tool-fs
  tool-fs-search -> @deepseek-ai/dsh-tool-fs-search
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  skill -> @deepseek-ai/dsh-skill
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  skill-badge -> @deepseek-ai/dsh-skill-badge
  tool-skill -> @deepseek-ai/dsh-tool-skill
  commands -> @deepseek-ai/dsh-commands
  command-feedback -> @deepseek-ai/dsh-command-feedback
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  command-goal -> @deepseek-ai/dsh-command-goal
  plan-mode -> @deepseek-ai/dsh-plan-mode
  token-meter -> @deepseek-ai/dsh-token-meter
  compaction-basic -> @deepseek-ai/dsh-compaction-basic
  command-compact -> @deepseek-ai/dsh-command-compact
  subagent -> @deepseek-ai/dsh-subagent
  subagent-spawn-in-process -> @deepseek-ai/dsh-subagent-spawn-in-process
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  ptc-runtime -> @deepseek-ai/dsh-ptc-runtime-node
  workflow-ptc -> @deepseek-ai/dsh-workflow-ptc
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  timeout-policy -> @deepseek-ai/dsh-tool-call-timeout-policy
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  tool-result-pruner -> @deepseek-ai/dsh-compaction-tool-result-pruner
  image-offload -> @deepseek-ai/dsh-compaction-image-offload
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-goal -> @deepseek-ai/dsh-tool-goal
  tool-ralph -> @deepseek-ai/dsh-tool-ralph
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  web -> @deepseek-ai/dsh-web
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  web-fetch-http -> @deepseek-ai/dsh-web-fetch-http
  tool-web -> @deepseek-ai/dsh-tool-web
  mcp-resources -> @deepseek-ai/dsh-mcp-resources
  tools -> @deepseek-ai/dsh-tools
  system-prompt -> @deepseek-ai/dsh-system-prompt
  agent-loop -> @deepseek-ai/dsh-agent-loop
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek-api-key
  llm-deepseek-account -> @deepseek-ai/dsh-llm-deepseek-account
  desktop-product-telemetry -> @deepseek-ai/dsh-host-product-telemetry-otel
  product-analytics -> @deepseek-ai/dsh-client-product-analytics
  subagent-model-selection-settings -> @deepseek-ai/dsh-tool-subagent/model-selection-settings
  message-feedback -> @deepseek-ai/dsh-message-feedback
  session-log-download -> @deepseek-ai/dsh-session-log-export
  open-in-app -> @deepseek-ai/dsh-host-open-in-app
  ui-open-in-app -> @deepseek-ai/dsh-client-ui-open-in-app
  workspace -> @deepseek-ai/dsh-workspace
  session-reference -> @deepseek-ai/dsh-session-reference
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  session-stats -> @deepseek-ai/dsh-session-stats
  session-turn-outline -> @deepseek-ai/dsh-session-turn-outline
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  session-controller -> @deepseek-ai/dsh-api-session-controller
  job-controller -> @deepseek-ai/dsh-api-job-controller
  terminal-controller -> @deepseek-ai/dsh-api-terminal-controller
  workspace-files -> @deepseek-ai/dsh-api-workspace-files
  ui-settings-account -> @deepseek-ai/dsh-client-ui-settings-account
  account-controller -> @deepseek-ai/dsh-api-account-controller
  settings-controller -> @deepseek-ai/dsh-api-settings-controller
  workspace-controller -> @deepseek-ai/dsh-api-workspace-controller
  cordis-host-runner -> @deepseek-ai/dsh-cordis-host-runner
  cordis-inspect-providers -> @deepseek-ai/dsh-tool-cordis/host
  web-startup -> @deepseek-ai/dsh-web-app/startup
  webserver -> @deepseek-ai/dsh-host-webserver
  web-runtime -> @deepseek-ai/dsh-web-app
  client-hmr -> @deepseek-ai/dsh-client-hmr
  modules -> @deepseek-ai/dsh-client-modules
  connection -> @deepseek-ai/dsh-client-connection
  file-upload -> @deepseek-ai/dsh-client-file-upload
  api-remotes -> @deepseek-ai/dsh-api-remotes
  cordis-client-runner -> @deepseek-ai/dsh-cordis-client-runner
  ui-theme -> @deepseek-ai/dsh-client-ui-theme
  locale -> @deepseek-ai/dsh-client-locale
  shortcuts -> @deepseek-ai/dsh-client-shortcuts
  ui-shortcuts -> @deepseek-ai/dsh-client-ui-shortcuts
  ui-layout -> @deepseek-ai/dsh-client-ui-layout
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-session -> @deepseek-ai/dsh-client-ui-session
  resources -> @deepseek-ai/dsh-client-resources
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-sidebar-right -> @deepseek-ai/dsh-client-ui-sidebar-right
  office-to-pdf -> @deepseek-ai/dsh-office-to-pdf
  ui-sidebar-documentpreview -> @deepseek-ai/dsh-client-ui-sidebar-documentpreview
  ui-sidebar-browser -> @deepseek-ai/dsh-client-ui-sidebar-browser
  ui-sidebar-terminal -> @deepseek-ai/dsh-client-ui-sidebar-terminal
  ui-sidebar-files -> @deepseek-ai/dsh-client-ui-sidebar-files
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-plugin-manager -> @deepseek-ai/dsh-client-ui-plugin-manager
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-conversation -> @deepseek-ai/dsh-client-ui-conversation
  ui-approval -> @deepseek-ai/dsh-client-ui-approval
  ui-chat -> @deepseek-ai/dsh-client-ui-chat
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-tool -> @deepseek-ai/dsh-client-ui-tool
  ui-cordis -> @deepseek-ai/dsh-client-ui-cordis
  ui-deliverables -> @deepseek-ai/dsh-client-ui-deliverables
  workspace-changes -> @deepseek-ai/dsh-workspace-changes
  ui-workspace -> @deepseek-ai/dsh-client-ui-workspace
  ui-workflow-run -> @deepseek-ai/dsh-client-ui-workflow-run
  ui-input-trigger -> @deepseek-ai/dsh-client-ui-input-trigger
  ui-commands -> @deepseek-ai/dsh-client-ui-commands
  ui-skill -> @deepseek-ai/dsh-client-ui-skill
  ui-subagent -> @deepseek-ai/dsh-client-ui-subagent
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-jobs -> @deepseek-ai/dsh-client-ui-jobs
  ui-goal -> @deepseek-ai/dsh-client-ui-goal
  ui-message-feedback -> @deepseek-ai/dsh-client-ui-message-feedback
  ui-model-selection -> @deepseek-ai/dsh-client-ui-model-selection
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-settings-session-log -> @deepseek-ai/dsh-client-ui-settings-session-log
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-settings-shell -> @deepseek-ai/dsh-client-ui-settings-shell
  ui-settings-agent-loop -> @deepseek-ai/dsh-client-ui-settings-agent-loop
  ui-settings-subagent -> @deepseek-ai/dsh-client-ui-settings-subagent
  ui-settings-web-search -> @deepseek-ai/dsh-client-ui-settings-web-search
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-user-questions -> @deepseek-ai/dsh-client-ui-user-questions
  ui-trajectory -> @deepseek-ai/dsh-client-ui-trajectory
  agent-preset-registry -> @deepseek-ai/dsh-agent-preset-registry
  preset-standard -> @deepseek-ai/dsh-agent-preset
  preset-ptc -> @deepseek-ai/dsh-agent-preset
  preset-minimal -> @deepseek-ai/dsh-agent-preset
  preset-cordis -> @deepseek-ai/dsh-agent-preset
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
| `agent-preset-registry` | `selectedDefault`（プリセット id、`.volatile()`——settings 側はこれだけ；行 config の `default` は**必須の行 config** であり settings 欄ではない） | Agent プリセット登録表。**0.1.x の `agent-presets`（複数形）行とその `roots` 機構は 0.2.0 に存在しない**；既定プリセットは本行の `config.default` が宣言し、残留した旧鍵は誰も読まない——本モジュールは残留を評価期エラーにする |
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
| `nixkits.dsh.agentPresets` | **もう settings namespace ではない**：`agent-preset-registry` 行の `config.default`（行 config）を出す。settings 側の `selectedDefault` を書くには逃げ道 `settings."agent-preset-registry".selectedDefault` | `agent-preset-registry` 行 = `@deepseek-ai/dsh-agent-preset-registry`（0.2.0 以降；0.1.x の複数形 `@deepseek-ai/dsh-agent-presets` は既に存在しない） |
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
| **両チャネル**（stable `0.2.0-rc.2`、alpha `0.2.1-alpha.1`） | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |

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
