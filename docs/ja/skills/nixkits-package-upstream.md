# nixkits-package-upstream (Skill)

[中文](../../zh/skills/nixkits-package-upstream.md) | [English](../../en/skills/nixkits-package-upstream.md) | 日本語 | [偽中国語](../../pcn/skills/nixkits-package-upstream.md)

> NixKits の nixpkgs 上流貢献 適配層：13 包の実現可能性台帳、許諾の根拠の確定、四言語同期、自検の登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| 経路 | `skills/nixkits-package-upstream/SKILL.md` |
| 依存 | [`nixpkgs-package-upstream`](nixpkgs-package-upstream.md)（汎用手法） |

## 機能

- **実現可能性台帳**：13 包それぞれ「提出可能か、何故か」の現状（証拠の基線は nixpkgs master `78f093ad1`）
- **最も踏み易い三点**：`mcp-searxng` は既に nixpkgs に在る、`dsh` は nixpkgs では
  `deepseek-harness` と呼ばれ在途 PR が既に 3 本、`kitsfmt` の上流倉庫は 404
- **陳腐化した自述の更正**：本倉は「nixpkgs は ruyi 包を既に提供しない」と書いたが、実際は一度も無い
- **許諾の根拠**：**実際に取得する産物の中**で、源ファイルの SPDX 頭と清単の許諾欄を先に探す。「LICENSE ファイルが無い」は「許諾が無い」を意味しない
- **dry-run の落点**：`upstream/<包名>/`、`/tmp` ではない
- **登録と同期**：四言語 README 索引、四言語の技能文書頁（言語切替器を含む）、維護日誌、自検の項数

## 使用

AI 助手が NixKits 倉庫で上流貢献を実施する時に起動し、**汎用技能の後に読む**。

残余の倉庫固有環節（`flake.lock` を提交しない、`git fetch origin` で遠端に整列、
言語を跨ぐ書類は一括で提交、pcn に非日文字形を出さない）は `AGENTS.md` と既存技能に従う。
