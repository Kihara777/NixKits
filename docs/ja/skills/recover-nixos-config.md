# recover-nixos-config（スキル）

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](recover-nixos-config.md)

> Coding Agent スキル：誤って削除した `/etc/nixos` の設定ファイルを Nix store から復旧します。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent スキル |
| パス | `skills/recover-nixos-config/SKILL.md` |

## トリガー

ユーザーが `/etc/nixos` 配下のファイル（flake.nix、flake.lock など）を誤って削除し、かつシステムが以前に正常にビルドされていた場合に自動発動します。

## 復旧の仕組み

`nixos-rebuild` の成功ごとに、Nix はその時点の `/etc/nixos` flake ソースのスナップショットを Nix store（`*-source` ディレクトリ）に保存します。ローカルバックアップがなくても削除されたファイルを復元できます。

`skills/` ディレクトリを任意のコーディングエージェントスキルディレクトリにコピー：
## 使い方

`/etc/nixos` のファイル消失を AI アシスタントが検出すると自動的に呼び出されます。手動操作は不要です。復旧手順：

1. Nix store からホスト名に一致するソーススナップショットを検索
2. 最新世代のソースディレクトリを特定
3. ファイル内容を確認
4. 消失したファイルを `/etc/nixos` にコピー
5. `nix flake check` で検証
