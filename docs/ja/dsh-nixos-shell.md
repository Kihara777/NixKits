# dsh-nixos-shell

[中文](../zh/dsh-nixos-shell.md) | [English](../en/dsh-nixos-shell.md) | 日本語  | [偽中国語](../pcn/dsh-nixos-shell.md)

NixOS シナリオ能力のための DeepSeek Harness（DSH）プラグイン — shell 実行・ツールブートストラップ・sudo デーモンルーティング・読み取り専用 NixOS 診断を**単一プラグインに統合**。機能要件は `nixos-modern-cli` スキルのシナリオに由来する（宣言的で不変な NixOS、最小限の PATH、モダン CLI、システムメンテナンス、Nix store パスの落とし穴）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH Host プラグイン（npm パッケージ） |
| npm 名 | `@kihara777/dsh-nixos-shell` |
| バージョン | `0.1.0` |
| ライセンス | MIT |
| 要件 | ホスト dsh ツリー（`subprocess`/`timer`/`tools` 能力接続点と peer 依存） |
| 後継 | `dsh-nix-shell`（shell ツール + sudo デーモン）と `dsh-skill-nixkits`（7 スキルプラグイン、廃止） |

## ツール

### nixos_shell — shell 実行器

| パラメータ | 説明 |
|-----------|------|
| `command` | 実行する shell コマンド（必須） |
| `tools` | 任意の POSIX ツール名リスト。コマンドは `nix shell nixpkgs#<pkg>… --command` 経由で実行。ホワイトリスト：python3、python、grep、ls、cat、head、tail、wc、tr、sort、mkdir、rm、cp、mv、find、env、sed、bash、awk、git、curl、jq、ripgrep、rsync、htop、tree、unzip |
| `workdir` / `timeoutMs` / `env` | 作業ディレクトリ / タイムアウト（設定上限あり）/ 追加環境変数（注入 NixOS PATH にマージ） |
| `run_in_background` | `true` で dsh-jobs バックグラウンドジョブを登録し job id を即時返す（`job_output` で読取・`job_kill` で停止、クライアント側タイムアウトなし — `sudo: true` ジョブはデーモン側のリクエスト毎上限あり）。`nixos-rebuild` 等の長いコマンド向け — 実行時間超過によるツール結果喪失を防ぐ。ローカルジョブは増分出力対応；`sudo: true` ジョブはデーモン協議 v3 で実行し、`job_kill` は明示的帯内取消行でデーモンに子プロセスを殺させる。**注意**：rebuild の活性化段階で dsh サービスが再起動し（插件パスはサービスユニットに焼き込み）、プロセス内ジョブ記録は消える — rebuild 後は `nixos_cli op=generations` で完了を検証すること。コマンド自体はデーモン内で完了まで走り続ける（断絶は決して取消ではない） |
| `sudo` / `justification` | sudo デーモンソケット検出時に有効：`sudo: true` で外部 root 実行器へルーティング。`justification` は必須で結果にエコーされる |

挙動：PATH 解決可能な `bash` を優先し、失敗時は Nix store の shell パスへフォールバック（内蔵ツールの `spawn bash ENOENT` を修正）；全子プロセスに完全な NixOS PATH を注入；出力は切り詰め + スピルファイル。

### nixos_cli — 読み取り専用 NixOS 診断

| op | 説明 |
|----|------|
| `capabilities` | nixos-cli / nix-command / 解決 shell / sudo デーモンを検出し、推奨 rebuild コマンドと伝統→モダンコマンド対照を返す |
| `system-status` | `systemctl is-system-running` + 失敗ユニット一覧 |
| `generations` | システムプロファイル世代一覧（新→旧）。`limit` 既定 20・上限 200、現在世代と総数を返す |
| `journal` | 指定ユニットのログ末尾（`unit` 必須、`*`/`%` ワイルドカード対応、末尾 `@` は自動で `*` を補いテンプレート全インスタンスを対象。`lines` 既定 50・上限 500） |
| `audit-store-paths` | `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` 内の `/nix/store/` 絶対パス（gc 後に無効化）を走査し、git 認証ヘルパーの形式を検査して修正規則を提示 |

変更を伴うメンテナンス（`nix store gc`、`nix store optimise`、rebuild）は `nixos_shell` の `sudo: true` で実行 — 昇格には常に明示的な justification が付く。

## アーキテクチャ

```
nixos-shell プラグイン
├─ nixos_shell ── ローカル: ctx.subprocess（PATH 注入 + スピル/タイムアウト）
│                └─ sudo: Unix ソケット → nixkits-sudo@.service（root、systemd ソケット活性化）
└─ nixos_cli ──── 読み取り専用ローカル実行（systemctl / nix-env / journalctl / 設定ファイル走査）
```

sudo デーモンは systemd ソケット活性化の root 実行器（`nixkits-sudo-exec.js`、プラグインに同梱）：接続ごとに 1 リクエストの JSON プロトコル（v3：クライアントはリクエスト 1 行を書き接続を開いたまま保持、デーモンは先頭行で実行を開始し完了時に応答を返して終了。リクエスト後の入力行はすべて明示的取消 — 子プロセスの**プロセスグループ全体**へ SIGTERM、猶予後に SIGKILL。シェル包装のみ殺すとパイプ書き込み端を継承した孤児孫プロセスが残りデーモンが応答不能になるため — これが `job_kill` の帯内取消機構）。**断絶は取消ではない**：rebuild の活性化段階で dsh サービスが再起動して接続が切れるが、断絶＝取消として扱うと switch が活性化の途中で殺され部分活性化状態が残る。よって対向消失時は子プロセスが分離状態で完了まで走り続ける（デーモン側上限 6 時間、rebuild コマンドは自動でこの上限を使用）。アクセス制御はソケットファイル（dsh サービスユーザー所有、`0600`）。PATH マージ順は継承 env が先、明示的 NixOS profile PATH が後（テンプレートユニットの systemd 既定 PATH は基本 store パスのみ）。

### rebuild / dsh 再起動の自動分離

`nixos_shell` は `nixos-rebuild` / `nixos apply` / `systemctl restart dsh` コマンド（`sudo: true`）を認識し、`systemd-run --collect` の一時ユニット（独立 cgroup）で実行するよう自動ラップする。呼び出しは即座にユニット名を返す（結果の `detachedUnit`）。理由：これらをデーモン経由で実行すると、コマンドが引き起こす dsh 再起動や socket 停止が呼び出しチェーン自身（@ インスタンスと子プロセスは同一 cgroup、または harness プロセスが本呼び出しの宿主）を殺し、活性化途中で死に socket が自動復旧できず、呼び出し結果も失われる。分離実行ならプロセスは完走する。進捗は `nixos_cli op=journal unit=nixkits-rebuild-<id>`、結果は `nixos_cli op=generations` で確認。

分離呼び出しの結果は**ビルドの成否を主張しない**：`detached: true` + `detachedUnit` + `note` を返し `exitCode` は `null`（systemd-run は引き継ぎのみ——引き継ぎ成功はビルド成功ではない）。実際の結果は必ず journal/generations で検証する。

モジュール側は「安定マウントポイント」（dsh.md 参照）でこれに連携する：プラグインパッケージの更新は dsh/sudo のユニット内容をもはや変えないため、通常の rebuild は何も再起動しない。プラグイン更新は明示的な `systemctl restart dsh`（同じく自動分離）で反映し、sudo 実行器は接続ごとに生成されるため新規接続は自動的に新スクリプトを使用する。

sudo ソケットは apply 時ではなく**呼び出し時**に検証する：rebuild の活性化中は socket が一時的に消えるため、その窓で起動したセッションが `sudo` パラメータを恒久的に失うことはない——socket 復旧後はそのまま使える。

## 使い方

`nixkits.dsh` モジュールによる宣言的インストールを推奨（node_modules 注入 + コンポジション行生成）：

```nix
{
  nixkits.dsh = {
    sudo.enable = true;                 # sudo デーモンを配備し NIXKITS_SUDO_SOCKET を注入
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
  };
}
```

ツール呼び出し：

```
nixos_shell(command = "nix flake check", tools = ["git" "jq"])

# 変更を伴うメンテナンス：sudo デーモン経由で root 実行
nixos_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")

nixos_cli(op = "capabilities")
nixos_cli(op = "journal", unit = "dsh", lines = 30)
nixos_cli(op = "audit-store-paths")
```

## Agent プリセット

パッケージは「NixOS模式」プリセット（`presets/nixos-mode/`、id `nixos`）を同梱する：創造モード基盤で、セッション初期化時にホストが NixOS であることを検証する——非 NixOS では全実行を拒否するツールガードと拒否プロンプト節を登録し、NixOS では開発ガイドのプロンプト節を注入して本プラグインの 2 ツール（`nixos_shell` / `nixos_cli`）をマウントする。モジュールは `nixkits.dsh.presets.nixosMode = true` で `$DSH_HOME/.agent-presets/nixos` へ一度だけシードする（ユーザーの後続編集は尊重）：

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
  };
}
```

ゲートはパッケージ内サブパス `@kihara777/dsh-nixos-shell/nixos-gate` で、プリセットのコンポジションでのみマウントされ、グローバルセッションには影響しない。

### メンテナンスモードプリセット

パッケージは「維護模式」プリセット（`presets/maintenance-mode/`、id `maintenance`）も同梱する：NixOS模式基盤で、さらに `maintenance-skills` エントリをマウントする——初期化時に、ビルド時に埋め込まれたリポジトリの `skills/` ツリー（単一ソース、新規セッションで常に最新）からランタイムスキル `write-project-docs`、`write-maintenance-log`、全 `translate-*` 言語拡張（apply 時に自動発見）を登録し、リポジトリ保守ワークフローのプロンプト節（分割コミット、push 後の保守ログ、ドキュメント同期、汎化）を注入する。モジュールは `nixkits.dsh.presets.maintenanceMode = true` で `$DSH_HOME/.agent-presets/maintenance` へ一度だけシードする。
