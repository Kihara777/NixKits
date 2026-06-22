# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | 偽中国語

> 誤削除 `/etc/nixos` 書類 Nix store 復旧。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| | `skills/recover-nixos-config/SKILL.md` |

## 機能

- Nix store 内之最新構築之 flake 特定
- 名 `*-source` 検索
- 最新 generation 対応正識別
- 指定書類（flake.nix、flake.lock、各部品）復元
- `nix flake check` 復元設定検証

## 使用

「/etc/nixos 之書類誤削除」報告起動。
