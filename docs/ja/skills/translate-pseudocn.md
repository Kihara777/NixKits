# translate-pseudocn (スキル)

[中文](../../zh/skills/translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md)

> 文書作成スキルに偽中国語（pcn）言語サポートを提供。write-project-docs から自動検出。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | コーディングエージェントスキル（言語バックエンド） |
| パス | `skills/translate-pseudocn/SKILL.md` |
| 言語コード | pcn |
| 呼び出し元 | write-project-docs（自動検出） |

## 機能

- 偽中国語（pcn）翻訳 — 日本語テキストの仮名除去 + 語順変換
- SOV→SVO 語順調整、助詞置換、句読点変換
- 内蔵辞書（約 13 語の JA→ZH マッピング）
- コードブロック、数字、記号を保持

## 使用

write-project-docs が `translate-*` 命名規則により自動検出・呼び出し：

- "偽中国語文書を生成"
- "pcn 言語版を追加"
