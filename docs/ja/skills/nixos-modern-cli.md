# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | [偽中国語](../../pcn/skills/nixos-modern-cli.md)

> NixOS システムで作業するときに起動。最新 Nix CLI、完全なシェル機能、正しいメンテナンス手順を保証。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixos-modern-cli/SKILL.md` |

## 機能

- NixOS を従来の Linux ディストリビューションと誤認する AI モデルを矯正
- 最新 vs 従来 CLI コマンドの対照表を提供
- `nix shell --command` を使用した POSIX ツール実行をガイド
- 一般的な POSIX ツール → nixpkgs パッケージ対応表を搭載
- システムメンテナンス、ログ確認、ガベージコレクションを網羅
- NixOS 固有の注意点（PATH、nix-env の永続性など）を列挙
- Nix Store パスの罠を診断：GC 回収で無効化された `/nix/store/` パスを特定・修正（例：`gh auth setup-git` の認証ヘルパー）

## 使用

AI が NixOS 環境を検出したときに自動起動。または「最新の nix コマンド」の明示的要求で起動。
