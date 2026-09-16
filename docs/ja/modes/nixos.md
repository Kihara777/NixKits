# NixOS模式（Agent プリセット）

[中文](../../zh/modes/nixos.md) | [English](../../en/modes/nixos.md) | 日本語  | [偽中国語](../../pcn/modes/nixos.md)

> 創造モードを基盤とする NixOS 専用エージェント：セッション初期化時にホストを検証し（非 NixOS は全実行を拒否）、`nixos_shell` / `nixos_cli` と NixOS 効率開発プロンプトを読み込む。

## 基本情報

| 項目 | 値 |
|------|-----|
| モード id | `nixos` |
| 配布方式 | dsh-nixos-shell パッケージ内 `presets/nixos-mode/`、seed-once で `$DSH_HOME/.agent-presets/nixos` へコピー |
| 有効化オプション | `nixkits.dsh.presets.nixosMode = true` |
| 派生元 | 創造モード（dsh 同梱の `cordis` プリセット） |
| ドキュメント | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（本モードを配布するパッケージ） |

## 動作

- **ホスト検証**：`nixos-gate` は apply 時に `/etc/NIXOS` と `/etc/os-release` を読む；非 NixOS なら全実行を拒否するツールガードを登録し、拒否プロンプト節（他モードへの切替を要求）を注入する——NixOS を入れていないマシンでも安全にマウントできる。
- **ツール**：`nixos_shell`（PATH 注入 / `nix shell` ツールブートストラップ / sudo デーモンルーティング）と `nixos_cli`（読み取り専用診断：capabilities / system-status / generations / journal / audit-store-paths）。
- **プロンプト**：NixOS 効率開発ガイド（宣言的システムの本質、パッケージ管理、パスの落とし穴）。
- **スキル**（5 個）：プリセット自身の `cordis-plugin-development`、`editing-cordis-compositions` に加え、リポジトリの `skills/` ツリーからビルド期のサブセット `skills-nixos/` 経由で登録される `nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning`。
- **コンポジション**：創造モードの完全なツール面 + `persona` 行（`complete: true`）+ `nixos-gate` + `nixos-shell` の 2 行。

## persona 行（プリセットのアイデンティティ）

コンポジションで `@deepseek-ai/dsh-persona` 行をマウントし、そのセッションにアイデンティティプロンプトを与える（デプロイ既定の persona を上書き）：

| フィールド | 型 | 既定値 | 説明 |
|------|------|--------|------|
| `prefix` | string | —（**必須**） | アイデンティティプロンプトの前置き。欠落時はプラグインの読込に失敗（`$.prefix missing required value`） |
| `suffix` | string | `""` | ランタイムコンテキストの後に付加する後置き |
| `complete` | boolean | `false` | `true` のとき persona を完全なプロンプトとして扱い、ランタイムコンテキストを付加しない |
| `includeRuntimeContext` | boolean | `true` | ランタイムコンテキスト（モデル、作業ディレクトリ等）を付加するか |

> **アップグレード時の注意**：`prefix` は dsh 0.1.5-alpha.2 以降**必須**（従前のフィールド名は `text`）。プリセットが依然 `text` を書いていると、persona プラグインの読込失敗が**セッション生成経路全体を巻き込む**——`session/create` が失敗すると、設定画面・llm 提供方一覧・セッション履歴がすべて読込不可となり、前端では `llm/listProviders failed: Failed to fetch` と `commands/list` の無限リトライとして現れる。**この症状は「モデル設定画面のエラー」と根本原因を同じくするため、ネットワークやリバースプロキシの問題と誤診しないこと**；dsh 更新後はプリセット内の各プラグイン行の config schema を検証すること。

## インストール

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

rebuild 後、セッションのモード選択器で「NixOS模式」を選べばよい。

## 注意

- **seed-once**：`$DSH_HOME/.agent-presets/nixos` が存在しない場合のみコピーする；以後このディレクトリはユーザー所有（モジュールが書込み権限を開放）となり、リポジトリ更新でも上書きされない。
- ゲート入口はパッケージ内サブパス `@kihara777/dsh-nixos-shell/nixos-gate` で、プリセットのコンポジションでのみマウントされ、グローバルセッションには影響しない。
