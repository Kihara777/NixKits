# translate-katalish (スキル)

[中文](../../zh/skills/translate-katalish.md) | [English](../../en/skills/translate-katalish.md) | 日本語 | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-katalish.md) | [偽中国語](../../pcn/skills/translate-katalish.md)

> 文書作成スキルに追加の自然言語サポートを提供。ｶﾀﾘｯｼｭ（カタカナ英語）言語を追加。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | コーディングエージェントスキル（言語バックエンド） |
| パス | `skills/translate-katalish/SKILL.md` |
| 呼び出し元 | write-project-docs（主）、nixkits-check-updates（間接） |

## 機能

- ｶﾀﾘｯｼｭ 言語の追加 — 英単語を半角カタカナに機械的に置換
- 内蔵辞書（約 20 語の技術文書用語）
- 辞書未登録語のルールベース音訳
- Markdown 構文とコードブロックを保持
- ファイル命名規則：`docs/katalish/<name>.md`

## 使用

write-project-docs が ｶﾀﾘｯｼｭ 文書を生成する際に自動呼び出し。直接呼び出しも可能：

- "カタカナ英語版の文書を生成"
- "ｶﾀﾘｯｼｭ 言語版を追加"
- "translate to katakana english"

## 例

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
