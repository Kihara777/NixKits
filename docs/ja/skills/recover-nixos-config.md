# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md)

> 誤って削除した `/etc/nixos` ファイルを Nix store から復旧。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/recover-nixos-config/SKILL.md` |

## 機能

- Nix store 内の最新ビルドの flake ソーススナップショットを特定
- ホスト名で `*-source` ディレクトリを検索
- 最新 generation に対応する正しいソースを識別
- 指定ファイル（flake.nix、flake.lock、各モジュール）を復元
- `nix flake check` で復元した設定を検証

## 使用

ユーザーが「/etc/nixos のファイルを誤って削除した」と報告したときに起動。
