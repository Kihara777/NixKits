# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | 日本語  | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> NixKits 規約に基づく MAINTENANCE.md の執筆・更新。ソフトウェア更新、バグ修正、スキル／ドキュメント変更、CI/CD 変更、リポジトリ横断の子プロジェクト連鎖更新の五種類に対応し、全言語同期。

## 自動発見契約

`translate-*` 命名規則により言語拡張を検出：`skills/translate-*/` を走査し、各 SKILL.md の frontmatter フィールド（`language_code` / `display_name` / `base_language`）を読み取り、多言語同期パイプラインで利用可能な言語として登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/write-maintenance-log/SKILL.md` |

## 機能

- ソフトウェア更新記録の作成（概要 + コミット ID 表 + バージョン表）
- バグ修正記録の作成（概要 + コミット ID 表）
- **リポジトリ横断の子プロジェクト連鎖更新記録の作成**：主リポジトリの条目は薄いラッパーの座標変更（`rev` / hash）のみを記録し、**子リポジトリの該当条目セクションへリンクする**。子リポジトリの条目は自身の完全なバージョン変更を記録する——両者は内容が異なり重複ではない
  - アンカー導出：ISO 8601 タイムスタンプを**小文字化 → `-` `_` 以外の各文字を `-` に置換**（`:` と `+` が各々ひとつの `-` になり、既存の `-` は保持される）
- メンテナンスログの 全言語同期（zh/en/ja/pcn）
- 先行スキル（更新チェック、NixKits は nixkits-check-updates）や git commit メッセージから概要を自動抽出
- 統一フォーマット：ISO 8601 精密時刻、LIFO 順序、未変更 hash 省略

## エントリポイント

- **修正を記録**：ソフトウェア更新後に自動呼出し、または「記入维护记录」で手動起動
- **ログを更新**：「メンテナンスログを更新」「補全维护记录」で git 履歴から走査・補完

## 使用

ソフトウェア更新後に自動起動、またはユーザーが修正記録を要求したときに起動。