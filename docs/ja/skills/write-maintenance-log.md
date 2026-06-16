# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](write-maintenance-log.md)

> NixKits の統一規約に従って MAINTENANCE.md を執筆・更新。ソフトウェア更新とバグ修正の両方の記録タイプに対応。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/write-maintenance-log/SKILL.md` |

## 機能

- ソフトウェア更新記録の作成（概要 + コミット ID 表 + バージョン表）
- バグ修正記録の作成（概要 + コミット ID 表）
- メンテナンスログの 3 言語同期（zh/en/ja）
- 先行スキル（nixkits-check-updates）や git commit メッセージから概要を自動抽出
- 統一フォーマット：ISO 8601 精密時刻、LIFO 順序、未変更 hash 省略

## エントリポイント

- **修正を記録**：ソフトウェア更新後に自動呼出し、または「記入维护记录」「今回の修正を記録」で手動起動
- **ログを更新**：「メンテナンスログを更新」「補全维护记录」で git 履歴から欠落レコードを走査・補完

## 使用

ソフトウェア更新後に自動起動、またはユーザーが修正記録を要求したときに起動。