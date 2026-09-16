# 維護模式（Agent プリセット）

[中文](../../zh/modes/maintenance.md) | [English](../../en/modes/maintenance.md) | 日本語  | [偽中国語](../../pcn/modes/maintenance.md)

> NixOS模式を基盤とするリポジトリ保守専用エージェント：ドキュメント作成・保守ログ技能と上流更新チェック技能を注入し、NixKits リポジトリ保守ワークフローのプロンプトを読み込む。

## 基本情報

| 項目 | 値 |
|------|-----|
| モード id | `maintenance` |
| 配布方式 | dsh-nixos-shell パッケージ内 `presets/maintenance-mode/`、seed-once で `$DSH_HOME/.agent-presets/maintenance` へコピー |
| 有効化オプション | `nixkits.dsh.presets.maintenanceMode = true` |
| 派生元 | [NixOS模式](nixos.md)（コンポジション末尾に固定行ブロックを追加） |
| ドキュメント | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（本モードを配布するパッケージ） |

## 動作

NixOS模式の全能力に加えて：

- **ランタイムスキル**：`maintenance-skills` エントリは apply 時に、**ビルド時に埋め込まれた**リポジトリの `skills/` ツリーから `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates` を登録し、全 `translate-*` 言語拡張を自動発見する——技能内容はリポジトリ `skills/` を単一ソースとし、新規セッションでも常に最新。
- **保守ワークフロープロンプト**：分割コミット → push 後の保守ログ追記（全言語同期）→ ドキュメント同期 → 技能への汎化。
- その他（システム検証、`nixos_shell` / `nixos_cli`、開発プロンプト）は NixOS模式と同一。

## 派生関係

維護模式のコンポジション = NixOS模式コンポジションの**末尾に固定の `maintenance-skills` 行ブロックを追加**（コメント含む）したもので、両プリセットの `skills/` ツリーはファイル単位で一致する——それ以外の差異は一切認めない。

```yaml
- id: maintenance-skills
  name: '@kihara777/dsh-nixos-shell/maintenance-skills'
```

`develop/check-preset-derivation.py` がこの派生関係を検証し、`nix flake check` に組み込まれている（CI が毎 push 実行）；ドリフト時はチェックが失敗し、修正するまでコミットできない。追加ブロック自体を意図的に変更する場合は、スクリプト内の `MAINTENANCE_DELTA` 定数も同期更新する。詳細はリポジトリ `AGENTS.md`「预设」節を参照。

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
    presets.maintenanceMode = true;
  };
}
```

## 注意

- NixOS模式と同様 **seed-once**：`$DSH_HOME/.agent-presets/maintenance` が既に存在する場合は上書きしない。変更はそのディレクトリを直接編集する（モジュールが書込み権限を開放）。
- NixOS模式を変更したら、同じ変更を維護模式へ必ずミラーすること。さもないと `nix flake check` が派生ドリフトで失敗する。
