# write-maintenance-log (技能)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md)  | 偽中国語

> NixKits 規約基 MAINTENANCE.md 執筆・更新。軟体更新及誤修正両対応、全言語同期。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md frontmatter 欄（`language_code` / `display_name` / `base_language`）読取、多言語同期管路利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/write-maintenance-log/SKILL.md` |

## 機能

- 軟体更新記録作成（概要 + 送信 ID 表 + 版表）
- 誤修正記録作成（概要 + 送信 ID 表）
- 保守記録全言語同期（zh/en/ja/pcn）
- 先行技能（nixkits-check-updates）及 git commit 消息自概要自動抽出
- 統一書式：ISO 8601 精密時刻、LIFO 順序、未変更 hash 省略

## 入口点

- **修正記録**：軟体更新後自動呼出、又「記入维护记录」以手動起動
- **記録更新**：「保守記録更新」「補全维护记录」以 git 履歴自走査・補完

## 使用

軟体更新後自動起動、又利用者修正記録要求時起動。
