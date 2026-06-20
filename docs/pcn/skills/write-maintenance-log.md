# write-maintenance-log (Skill)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> NixKits 規約基 MAINTENANCE.md 執筆更新軟件更新修正両方対応5 言語同期

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査各 SKILL.md frontmatter `language_code` / `display_name` / `base_language`読取多言語同期利用可能言語登録

## 基本情報

|項目|値|
|------|-----|
||Coding Agent Skill|
||`skills/write-maintenance-log/SKILL.md`|

## 機能

- 軟件更新記録作成概要 + ID 表 + 版本表
- 修正記録作成概要 + ID 表
- 維護日誌 5 言語同期zh/en/ja/katalish/pcn
- 先行技能nixkits-check-updates git commit 概要自動抽出
- 統一格式化：ISO 8601 精密時刻LIFO 順序未変更 hash 省略

## 

- **修正記録**：軟件更新後自動呼出記入维护记录手動起動
- **日誌更新**：維護日誌更新補全维护记录 git 履歴走査補完

## 使用

軟件更新後自動起動修正記録要求起動