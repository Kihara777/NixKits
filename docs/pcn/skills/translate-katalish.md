# translate-katalish (技能)

[中文](../../zh/skills/translate-katalish.md) | [English](../../en/skills/translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md) | 偽中国語

> 文書作成技能追加自然言語支援提供。片仮名英語（ｶﾀﾘｯｼｭ）言語追加。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能（言語後端） |
| 路 | `skills/translate-katalish/SKILL.md` |
| 呼出元 | write-project-docs（主）、nixkits-check-updates（間接） |

## 機能

- 片仮名英語言語追加 — 英単語半角片仮名機械的置換
- 内蔵辞書（約 20 語技術文書用語）
- 辞書未登録語規則基音訳
- Markdown 構文及符号塊保持
- 書類命名規則：`docs/katalish/<name>.md`

## 使用

write-project-docs 片仮名英語文書生成時自動呼出。直接呼出可能：

- "片仮名英語版文書生成"
- "片仮名英語言語版追加"
- "translate to katakana english"

## 例

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
