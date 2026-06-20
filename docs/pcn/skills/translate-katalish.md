# translate-katalish (スキル)

[中文](../../zh/skills/translate-katalish.md) | [English](../../en/skills/translate-katalish.md) | [日本語](../../ja/skills/translate-katalish.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md) | 偽中国語

> 文書作成スキル追加自然言語サポート提供。ｶﾀﾘｯｼｭ(カタカナ英語)言語追加。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | コーディングエージェントスキル(言語バックエンド) |
| パス | `skills/translate-katalish/SKILL.md` |
| 呼出元 | write-project-docs(主)，nixkits-check-updates(間接) |

## 機能

- ｶﾀﾘｯｼｭ 言語追加 — 英単語半角カタカナ機械的置換
- 内蔵辞書(約 20 語技術文書用語)
- 辞書未登録語ルールベース音訳
- Markdown 構文コードブロック保持
- ファイル命名規則：`docs/katalish/<name>.md`

## 使用

write-project-docs  ｶﾀﾘｯｼｭ 文書生成際自動呼出。直接呼出可能：

- "カタカナ英語版文書生成"
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
