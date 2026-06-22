# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | 偽中国語

> NixOS システム作業與起動。最新 Nix CLI、完全シェル機能、正メンテナンス手順保証。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/nixos-modern-cli/SKILL.md` |

## 機能

- NixOS 従来之 Linux ディストリビュション與誤認 AI モデル矯正
- 最新 vs 従来 CLI コマンド之対照表提供
- `nix shell --command` 使用 POSIX ツール実行ガイド
- 一般的 POSIX ツール → nixpkgs パッケージ対応表搭載
- システムメンテナンス、ログ確認、ガベージコレクション網羅
- NixOS 固有之注意点（PATH、nix-env 之永続性）列挙
- Nix Store パス之罠診断：GC 回収無効化 `/nix/store/` パス特定・修正（例：`gh auth setup-git` 之認証ヘルパー）

## 使用

AI  NixOS 環境検出與自動起動。「最新之 nix コマンド」之明示的要求起動。
