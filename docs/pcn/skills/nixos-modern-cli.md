# nixos-modern-cli (技能)

[中文](../../zh/skills/nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | 偽中国語

> NixOS 体系作業時起動。最新 Nix CLI、完全殻機能、正確保守手順保証。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixos-modern-cli/SKILL.md` |

## 機能

- NixOS 従来 Linux 配布誤認 AI 模型矯正
- 最新 vs 従来 CLI 指令対照表提供
- `nix shell --command` 使用 POSIX 道具実行手引
- 一般 POSIX 道具 → nixpkgs 包対応表搭載
- 体系保守、記録確認、塵集回收網羅
- NixOS 固有注意点（PATH、nix-env 永続性等）列挙
- Nix Store 路罠診断：GC 回收以無効化 `/nix/store/` 路特定・修正（例：`gh auth setup-git` 認証補助器）

## 使用

AI NixOS 環境検出時自動起動。又「最新 nix 指令」明示的要求以起動。
