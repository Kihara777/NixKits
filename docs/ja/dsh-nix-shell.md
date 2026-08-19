# dsh-nix-shell

[中文](../zh/dsh-nix-shell.md) | [English](../en/dsh-nix-shell.md) | 日本語  | [偽中国語](../pcn/dsh-nix-shell.md)

DeepSeek Harness（DSH）向け NixOS 対応シェルツールプラグイン。NixOS では dsh プロセスの PATH に bash が含まれないことが多く（`/bin/bash` が存在しない）、標準の bash ツールは毎回 `spawn bash ENOENT` で失敗する。本プラグインはモデルツール `nix_shell` を登録し、PATH で解決できる bash を優先（健全な環境では通常のシェルツールに退化）、失敗時は Nix store 内のシェルパスへフォールバックし、各子プロセスに NixOS の完全な PATH を注入する。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH ホストプラグイン（npm パッケージ）|
| npm 名 | `@kihara777/dsh-nix-shell` |
| バージョン | `0.2.0` |
| ライセンス | MIT |
| ツール名 | `nix_shell` |

## アーキテクチャ

```
モデル ⇐ ツール登録（ctx.tools）⇐ プラグイン ⇐ ctx.subprocess ⇐ bash -c <command>
                                       ⇑ ctx.timer（デッドライン）
```

- ホスト専用プラグイン：能力接続点（`subprocess`/`timer`/`tools`）のみ消費し、サービスを提供しない — `tool-bash` と同様にコンポジションへ単独で置ける
- peer（`cordis`/`dsh-subprocess`/`dsh-timer`）はホスト dsh ツリーが提供（エコシステムの慣例に一致）
- **サンドボックス実行ポリシーは適用しない** — 標準のサンドボックス bash ツールが起動できないホスト向けの橋渡し。モジュールの PATH 修正（[dsh](dsh.md) 参照）展開後は標準ツールを優先すること

## 設定

| 項目 | 既定 | 説明 |
|------|------|------|
| `toolName` | `nix_shell` | 登録ツール名 |
| `shellPath` | `/run/current-system/sw/bin/bash` | PATH 解決失敗時のフォールバックシェル |
| `pathEnv` | NixOS レイアウト | 子プロセスへ注入する PATH（`$USER` 展開対応）|
| `defaultTimeoutMs` | `300000` | 既定タイムアウト |
| `maxTimeoutMs` | `3600000` | タイムアウト上限 |
| `stdoutMaxBytes` / `stdoutSpillMaxBytes` | 2 MiB / 16 MiB | メモリ上限と全量スピル上限 |
| `graceMs` | `5000` | 終了猶予 |
| `sudoSocketPath` | `""`（無効） | 外部 sudo デーモンのソケットパス。環境変数 `NIXKITS_SUDO_SOCKET` からも取得 |

## sudo デーモン統合

dsh サンドボックス内では `sudo` の setuid が失われ昇格できない。プラグインは**初期化時**に外部 sudo デーモンのソケット（コンポジション config の `sudoSocketPath`、フォールバックとして環境変数 `NIXKITS_SUDO_SOCKET`）を検出し、存在すれば `sudo`/`justification` パラメータを有効化。`sudo: true` のリクエストはローカル実行せず、Unix ソケット経由でリクエスト全体（command/cwd/env/timeout）をデーモンへ渡し、root で実行する：

```
nix_shell(sudo=true)
  └─ Unix ソケット ──▶ systemd ソケットアクティベーション（nixkits-sudo@.service, root）
                         └─ nixkits-sudo-exec.js：接続ごとに 1 リクエスト、JSON リクエスト/レスポンス
```

- **アクセス制御境界**：ソケットファイルは dsh サービスユーザー所有で `0600`（`SocketUser`/`SocketMode`）— そのユーザーのみ接続可能で、事実上そのユーザーへのパスワードレス root 実行を意味する
- **監査**：`justification` 必須、結果と共に返却。サービス stderr は journal へ
- モジュールで一行有効化：`nixkits.dsh.sudo.enable = true`（ソケット + 接続ごとの root サービス生成 + `NIXKITS_SUDO_SOCKET` 注入）
- デーモン不在時は `sudo` パラメータが現れず、ソケット消失後は呼び出しが明確なエラーを返す

## 使い方

`nixkits.dsh.plugins.packages` による宣言的インストール（node_modules 注入 + コンポジション行生成）：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nix-shell;
    id = "tool-nix-shell";
    name = "@kihara777/dsh-nix-shell";
  }];
}
```

手動コンポジション行（npm パッケージが dsh から解決できる場合）：

```yaml
- id: tool-nix-shell
  name: '@kihara777/dsh-nix-shell'
```

ツール呼び出し：

```
nix_shell(command = "nix flake check", workdir = "/path/to/flake")
```
