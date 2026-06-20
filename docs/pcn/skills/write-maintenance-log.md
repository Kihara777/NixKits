# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | 偽中国語

> NixKits 規約基 MAINTENANCE.md 執筆・更新。軟件更新修復両方対応，全言語同期。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査，各 SKILL.md frontmatter (`language_code` / `display_name` / `base_language`)読取，多言語同期利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Coding Agent Skill |
| | `skills/write-maintenance-log/SKILL.md` |

## 功能

- 軟件更新記録作成(概要 + ID 表 + 版本表)
- 修復記録作成(概要 + ID 表)
- 全言語同期(zh/en/ja/katalish/pcn)
- 先行(nixkits-check-updates) git commit 概要自動抽出
- 統一：ISO 8601 精密時刻，LIFO 順序，未変更 hash 省略

## 

- **修復記録**：軟件更新後自動呼出，「記入维护记录」手動起動
- **更新**：「更新」「補全维护记录」 git 履歴走査・補完

## 使用

軟件更新後自動起動，修復記録要求起動。