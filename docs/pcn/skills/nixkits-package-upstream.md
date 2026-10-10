# nixkits-package-upstream (技能)

[中文](../../zh/skills/nixkits-package-upstream.md) | [English](../../en/skills/nixkits-package-upstream.md) | [日本語](../../ja/skills/nixkits-package-upstream.md)  | 偽中国語

> NixKits nixpkgs 上流貢献 適配層：13 包 実現可能性台帳、許諾缺口処置、四言語同期、自検登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixkits-package-upstream/SKILL.md` |
| 依存 | [`nixpkgs-package-upstream`](nixpkgs-package-upstream.md)（汎用手法） |

## 機能

- **実現可能性台帳**：13 包 各「提出可能可否、何故」現状（証拠基線 nixpkgs master `78f093ad1`）
- **最踏易三点**：`mcp-searxng` 既 nixpkgs 内在、`dsh` nixpkgs 内 `deepseek-harness` 称呼
  在途 PR 既三本、`kitsfmt` 上流倉庫 404
- **陳腐化自述更正**：本倉「nixpkgs ruyi 包 既提供無」記載、実際 一度 無
- **許諾缺口**：許諾根拠 **実際取得 tag 内部** 必然。後 main 追加物 根拠不成立
- **dry-run 落点**：`upstream/<包名>/`、`/tmp` 非
- **登録同期**：四言語 README 索引、四言語技能文書頁（言語切替器含）、維護日誌、自検項数

## 使用

AI 助手 NixKits 倉庫 上流貢献実施時起動、**汎用技能 後 読**。

残余 倉庫固有環節（`flake.lock` 提交無、`git fetch origin` 遠端整列、
言語跨書類 一括提交、pcn 非日文字形 無）`AGENTS.md` 既存技能 従。
