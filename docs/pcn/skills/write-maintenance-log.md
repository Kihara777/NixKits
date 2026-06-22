# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | 偽中国語

> NixKits 規約基 MAINTENANCE.md 之執筆・更新。ソフトウェア更新與バグ修正之両方対応、全言語同期。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md 之 frontmatter フィールド（`language_code` / `display_name` / `base_language`）読取、多言語同期パイプライン利用可能言語與登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| パス | `skills/write-maintenance-log/SKILL.md` |

## 機能

- ソフトウェア更新記録之作成（概要 + コミット ID 表 + 版表）
- バグ修正記録之作成（概要 + コミット ID 表）
- メンテナンスログ之 全言語同期（zh/en/ja/katalish/pcn）
- 先行スキル（nixkits-check-updates） git commit メッセージ概要自動抽出
- 統一フォーマット：ISO 8601 精密時刻、LIFO 順序、未変更 hash 省略

## エントリポイント

- **修正記録**：ソフトウェア更新後自動呼出、「記入维护记录」手動起動
- **ログ更新**：「メンテナンスログ更新」「補全维护记录」 git 履歴走査・補完

## 使用

ソフトウェア更新後自動起動、ユーザー修正記録要求與起動。