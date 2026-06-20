# translate-katalish (技能)

[中文](../../zh/skills/translate-katalish.md) | [English](../../en/skills/translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [Katalish](../../katalish/skills/translate-katalish.md) | Pseudo-Chinese

> 文書作成技能追加自然言語支持提供ｶﾀﾘｯｼｭ英語言語追加

## 基本情報

|項目|値|
|------|-----|
||技能言語|
||`skills/translate-katalish/SKILL.md`|
|呼出元|write-project-docs主nixkits-check-updates間接|

## 機能

- ｶﾀﾘｯｼｭ 言語追加 — 英単語半角機械的置換
- 内蔵辞書約 20 語技術文書用語
- 辞書未登録語音訳
- Markdown 構文代碼保持
- 文件命名規則：`docs/katalish/<name>.md`

## 使用

write-project-docs ｶﾀﾘｯｼｭ 文書生成際自動呼出直接呼出可能：

- "英語版文書生成"
- "ｶﾀﾘｯｼｭ 言語版追加"
- "translate to katakana english"

## 例

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```