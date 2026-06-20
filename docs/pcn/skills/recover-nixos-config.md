# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | 偽中国語

> 誤削除 `/etc/nixos` ファイル Nix store 復旧。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/recover-nixos-config/SKILL.md` |

## 機能

- Nix store 内最新ビルド flake ソーススナップショット特定
- ホスト名 `*-source` ディレクトリ検索
- 最新 generation 対応正ソース識別
- 指定ファイル(flake.nix，flake.lock，各モジュール)復元
- `nix flake check` 復元設定検証

## 使用

ユーザー「/etc/nixos ファイル誤削除」報告起動。
