# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) 

> NixOS システム作業起動。最新 Nix CLI，完全シェル機能，正メンテナンス手順保証。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixos-modern-cli/SKILL.md` |

## 機能

- NixOS 従来 Linux ディストリビューション誤認 AI モデル矯正
- 最新 vs 従来 CLI コマンド対照表提供
- `nix shell --command` 使用 POSIX ツール実行ガイド
- 一般的 POSIX ツール → nixpkgs パッケージ対応表搭載
- システムメンテナンス，ログ確認，ガベージコレクション網羅
- NixOS 固有注意点(PATH，nix-env 永続性)列挙
- Nix Store パス罠診断：GC 回収無効化 `/nix/store/` パス特定・修正(例：`gh auth setup-git` 認証ヘルパー)

## 使用

AI  NixOS 環境検出自動起動。「最新 nix コマンド」明示的要求起動。
