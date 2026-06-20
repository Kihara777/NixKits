# recover-nixos-config (Skill)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md) | [偽中国語](../../pcn/skills/recover-nixos-config.md)

> 誤削除 `/etc/nixos` 文件 Nix store 復旧

## 基本情報

|項目|値|
|------|-----|
||Coding Agent Skill|
||`skills/recover-nixos-config/SKILL.md`|

## 機能

- Nix store 内最新構建 flake 特定
- 名 `*-source` 目錄検索
- 最新 generation 対応正識別
- 指定文件flake.nixflake.lock各模塊復元
- `nix flake check` 復元設定検証

## 使用

/etc/nixos 文件誤削除報告起動