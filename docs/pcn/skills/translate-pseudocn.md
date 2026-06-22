# translate-pseudocn (技能)

[中文](../../zh/skills/translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md) | 偽中国語

> 文書作成技能偽中国語（pcn）言語支援提供。write-project-docs 自動検出。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能（言語バックエンド） |
| パス | `skills/translate-pseudocn/SKILL.md` |
| 言語コド | pcn |
| 呼出元 | write-project-docs（自動検出） |

## 機能

- 偽中国語（pcn）翻訳 — 日本語テキスト之仮名除去 + 語順変換
- SOV→SVO 語順調整、助詞置換、句読点変換
- 内蔵辞書（約 13 語之 JA→ZH マッピング）
- コドブロック、数字、記号保持

## 使用

write-project-docs `translate-*` 命名規則自動検出・呼出：

- "偽中国語文書生成"
- "pcn 言語版追加"
