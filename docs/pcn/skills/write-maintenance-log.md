# write-maintenance-log (技能)

[中文](../../zh/skills/write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md)  | 偽中国語

> NixKits 規約基 MAINTENANCE.md 執筆・更新。軟体更新、誤修正、技能／文書変更、CI/CD 変更、倉庫横断 子 project 連鎖更新 五類対応、全言語同期。

## 自動発見契約

`translate-*` 命名規則言語拡張検出：`skills/translate-*/` 走査、各 SKILL.md frontmatter 欄（`language_code` / `display_name` / `base_language`）読取、多言語同期管路利用可能言語登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/write-maintenance-log/SKILL.md` |

## 機能

- 軟体更新記録作成（概要 + 送信 ID 表 + 版表）
- 誤修正記録作成（概要 + 送信 ID 表）
- **概要 二種 排版**：一文、或 **markdown 清単**（変更 自然 複数項目 分割時、走査 易）；両者 長 予算 同一（zh ≤ 400 文字）
  - 清単形式 多言語同期時 **項目数 一致必須**——一項目 不足 翻訳漏、一項目 過剰 水増
- **形態 要件 CI 判定 固定済**（`develop/check-maintenance-log.py`、`nix flake check` 実行）：zh 概要 ≤ 400 文字、清単項目数 四言語 一致、説明 block 一行 且 本語 標記。**訳文 長 門 設 不**——中、英、日 情報密度 異 故（実測 字面比 中位数：en 1.87、ja 1.17、pcn 1.03）、密度対応 倍率 以 判定
- **倉庫横断 子 project 連鎖更新記録 作成**：主倉 条目 薄包装 座標変更（`rev` / hash）限定 記録、**子倉 該当条目 節 対 連結**。子倉 条目 自身 完全 版変更 記録——両者 内容 異、重複 非
  - anchor 導出：ISO 8601 timestamp **小文字化 → `-` `_` 以外 各文字 `-` 置換**（`:` 與 `+` 各 一 `-` 化、既存 `-` 保持）
- 保守記録全言語同期（zh/en/ja/pcn）
- 先行技能（更新確認、NixKits 用 nixkits-check-updates）及 git commit 消息自概要自動抽出
- 統一書式：ISO 8601 精密時刻、LIFO 順序、未変更 hash 省略

## 入口点

- **修正記録**：軟体更新後自動呼出、又「記入维护记录」以手動起動
- **記録更新**：「保守記録更新」「補全维护记录」以 git 履歴自走査・補完

## 使用

軟体更新後自動起動、又利用者修正記録要求時起動。
