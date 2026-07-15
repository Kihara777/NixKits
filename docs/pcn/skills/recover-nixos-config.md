# recover-nixos-config (技能)

[中文](../../zh/skills/recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md)  | 偽中国語

> 誤削除 `/etc/nixos` 書類 Nix store 自復旧。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/recover-nixos-config/SKILL.md` |

## 機能

- Nix store 内最新構築 flake 源快照特定
- 主機名以 `*-source` 目録検索
- 最新 generation 対応正源識別
- 指定書類（flake.nix、flake.lock、各部品）復元
- `nix flake check` 以復元設定検証

## 使用

利用者「/etc/nixos 書類誤削除」報告時起動。
