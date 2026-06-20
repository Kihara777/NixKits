# nixos-modern-cli (Skill)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | 偽中国語

> NixOS 系統作業起動。最新 Nix CLI，完全功能，正手順保証。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Coding Agent Skill |
| | `skills/nixos-modern-cli/SKILL.md` |

## 功能

- NixOS 従来 Linux 誤認 AI 模型矯正
- 最新 vs 従来 CLI 対照表提供
- `nix shell --command` 使用 POSIX 工具実行
- 一般的 POSIX 工具 → nixpkgs 軟件包対応表搭載
- 系統，確認，網羅
- NixOS 固有注意点(PATH，nix-env 永続性)列挙
- Nix Store 罠診断：GC 回収無効化 `/nix/store/` 特定・修復(例：`gh auth setup-git` 認証)

## 使用

AI NixOS 環境検出自動起動。「最新 nix 」明示的要求起動。
