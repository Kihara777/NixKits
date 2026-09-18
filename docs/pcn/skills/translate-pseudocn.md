# translate-pseudocn (技能)

[中文](../../zh/skills/translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md)  | 偽中国語

> 文書作成技能偽中国語（pcn）言語支援提供。write-project-docs 自自動検出。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能（言語後端） |
| 路 | `skills/translate-pseudocn/`（`SKILL.md` + `dictionary.md`）|
| 配套書類 | `dictionary.md` —— 内蔵 片仮名→日文漢字 対応辞書（実測 **75** 項）。翻訳時 及 仮名残留 自己点検時 参照 |
| 言語符号 | pcn |
| 呼出元 | write-project-docs（自動検出） |

## 機能

- 偽中国語（pcn）翻訳 — 日本語本文仮名除去 + 語順変換
- SOV→SVO 語順調整、助詞置換、句読点変換
- 内蔵 片仮名→日文漢字 辞書（`dictionary.md`、**75** 項：軟体/硬体/版/上流 等 通常語 + IT 用語）
- 符号塊、数字、記号保持

## 使用

write-project-docs `translate-*` 命名規則自動検出・呼出：

- "偽中国語文書生成"
- "pcn 言語版追加"
