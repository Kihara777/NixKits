# nixkits-check-updates（スキル）

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](nixkits-check-updates.md)

> NixKits の全外部パッケージのアップストリーム更新を確認し、自動的に適用します。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent スキル |
| パス | `skills/nixkits-check-updates/SKILL.md` |

## 機能

- ローカル NixKits リポジトリ内であることを確認
- 4 つの外部パッケージの最新 GitHub Release をチェック
- バージョン、ハッシュ、npmDepsHash を自動更新
- ドキュメントを同期（3 言語）
- ローカルインストール済みバージョンを報告

## 対象

`flake.nix` からパッケージを動的に読み取り、以下を除外：
- 自前（ソースがローカルリポジトリ内）
- 動的バージョン（ビルド時に最新を取得）
- nixpkgs 追従パッチ

残りの外部パッケージすべてを自動チェックします。
