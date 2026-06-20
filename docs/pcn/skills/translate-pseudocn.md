# translate-pseudocn (技能)

[中文](../../zh/skills/translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md) | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> 文書作成技能偽中国語pcn言語支持提供write-project-docs 自動検出

## 基本情報

|項目|値|
|------|-----|
||技能言語|
||`skills/translate-pseudocn/SKILL.md`|
|言語代碼|pcn|
|呼出元|write-project-docs自動検出|

## 功能

- 偽中国語pcn翻訳 — 日本語仮名除去 + 語順変換
- SOV→SVO 語順調整助詞置換句読点変換
- 内蔵辞書約 13 語 JA→ZH
- 代碼数字記号保持

## 使用

write-project-docs `translate-*` 命名規則自動検出呼出：

- "偽中国語文書生成"
- "pcn 言語追加"