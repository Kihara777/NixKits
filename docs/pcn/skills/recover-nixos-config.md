# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | 偽中国語

> 誤削除 `/etc/nixos` ァ Nix store 復旧。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Coding Agent Skill |
| | `skills/recover-nixos-config/SKILL.md` |

## 功能

- Nix store 内最新構建 flake 特定
- 名 `*-source` 検索
- 最新 generation 対応正識別
- 指定ァ(flake.nix，flake.lock，各模塊)復元
- `nix flake check` 復元設置検証

## 使用

「/etc/nixos ァ誤削除」報告起動。
