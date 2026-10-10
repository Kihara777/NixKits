# nixpkgs-package-upstream (技能)

[中文](../../zh/skills/nixpkgs-package-upstream.md) | [English](../../en/skills/nixpkgs-package-upstream.md) | [日本語](../../ja/skills/nixpkgs-package-upstream.md)  | 偽中国語

> 自前梱包軟体 上流 nixpkgs 提出 汎用手順：評価 → 監査 → dry-run → 実施。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixpkgs-package-upstream/SKILL.md` |
| 依存 | 無（倉庫固有環節 適配層提供） |

## 機能

- **実現可能性評価**：六問 各一件 証拠付確認——既 master 内在、過去削除有無、
  在途 PR 有無、許諾 **取得 tag 内部** 指認可否、維持意思有無、依存 nixpkgs 共通包集合衝突有無
- **要求監査**：by-name 構造 `nixpkgs-vet` 12 検査 3 棘輪、必須 `meta`、
  nixfmt 格式、commit 接頭辞 CI 駆動、DCO 不要、issue 先開 不要
- **AI 貢献政策**：`Assisted-by:` trailer 強制披露形式、`Co-authored-by:` 形式不満。
  環 内部 責任者 必至
- **dry-run**：**実際 nixpkgs 樹** 対 評価・構築・産物核験、**産物実行**（四層判据）
- **実施**：二 commit 順序（維護者条目 先）、分岐 PR、待機 加速手段
- **罠一覧**：許諾缺口、倉庫自述陳腐化、同名別包、文書漂移、事前編訳二進、
  符号連結樹 再帰的 chmod nix store 到達

## 使用

AI 助手「此包 nixpkgs 提出」「上流貢献」依頼時起動。

倉庫固有環節（四言語文書、維護日誌、自検登録）適配層技能
[`nixkits-package-upstream`](nixkits-package-upstream.md) 内在。

## 判据出処

本技能硬性要求 全 nixpkgs 自身文書 CI 実装 取得、出処明記：

- `pkgs/README.md`（新規包規則、命名、meta、取得元）
- `pkgs/by-name/README.md`（構造、制限）
- `nixpkgs-vet` `README.md`（12 検査 3 棘輪）
- `CONTRIBUTING.md`（commit 約定、AI 政策、評審手順）
- `.github/workflows/lint.yml` `.github/PULL_REQUEST_TEMPLATE.md`

**此等書類漂移**。故本技能第 0 歩「先同期、然後採信」——
「現在 nixpkgs 如何姿」結論 常時現取。
