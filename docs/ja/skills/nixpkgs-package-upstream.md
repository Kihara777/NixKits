# nixpkgs-package-upstream (Skill)

[中文](../../zh/skills/nixpkgs-package-upstream.md) | [English](../../en/skills/nixpkgs-package-upstream.md) | 日本語 | [偽中国語](../../pcn/skills/nixpkgs-package-upstream.md)

> 自前で梱包したソフトウェアを上流の nixpkgs へ提出する汎用手順：評価 → 監査 → dry-run → 実施。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | Coding Agent Skill |
| 経路 | `skills/nixpkgs-package-upstream/SKILL.md` |
| 依存 | 無し（倉庫固有の環節は適配層が提供） |

## 機能

- **実現可能性の評価**：六つの問いを一件ずつ証拠付きで確認——既に master に在るか、
  かつて削除されたか、在途の PR が在るか、許諾が**実際に取得する tag の中**で
  指認できるか、維持の意思が在るか、依存が nixpkgs 共通の包集合と衝突しないか
- **要求の監査**：by-name の構造と `nixpkgs-vet` の 12 検査・3 棘輪、必須の `meta`、
  nixfmt の格式、commit 接頭辞が CI を駆動すること、DCO は不要、issue を先に開く必要も無い
- **AI 貢献政策**：`Assisted-by:` trailer が強制の披露形式で、`Co-authored-by:` は
  形式を満たさない。環の中に責任者が必ず要る
- **dry-run**：**実際の nixpkgs 樹**に対して評価・構築・産物の核験、そして**産物を実行**
  （四層の判据）
- **実施**：二つの commit の順序（維護者条目が先）、分岐と PR、待機と加速の手段
- **罠の一覧**：許諾の缺口、倉庫の自述の陳腐化、同名別包、文書の漂移、事前編訳の二進、
  そして符号連結の樹への再帰的 chmod が nix store へ届いてしまうこと

## 使用

AI 助手が「この包を nixpkgs へ提出して」「上流へ貢献して」と依頼された時に起動する。

倉庫固有の環節（四言語の文書、維護日誌、自検の登録）は適配層の技能
[`nixkits-package-upstream`](nixkits-package-upstream.md) に在る。

## 判据の出処

本技能の硬性要求は全て nixpkgs 自身の文書か CI の実装から取り、出処を明記している：

- `pkgs/README.md`（新規包の規則、命名、meta、取得元）
- `pkgs/by-name/README.md`（構造、制限）
- `nixpkgs-vet` の `README.md`（12 検査と 3 棘輪）
- `CONTRIBUTING.md`（commit の約定、AI 政策、評審の手順）
- `.github/workflows/lint.yml` と `.github/PULL_REQUEST_TEMPLATE.md`

**これらの書類は漂移する**。故に本技能の第 0 歩は「先に同期し、然る後に採信する」——
「現在の nixpkgs は如何なる姿か」という結論は常に現取する。
