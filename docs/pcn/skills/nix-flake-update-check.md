# nix-flake-update-check (技能)

[中文](../../zh/skills/nix-flake-update-check.md) | [English](../../en/skills/nix-flake-update-check.md) | [日本語](../../ja/skills/nix-flake-update-check.md)  | 偽中国語

> **任意 nix flake 倉庫** 的 包上流更新確認 且 昇級——builder 別 hash flow、着手前 対話的確認、同 account 子 project 連鎖並列確認、版意味論 変化 時 文書 機械的置換 非 書直 、文書 外部 link 失効監査、GitHub Actions SHA 固定更新確認、flake.lock 扱、修正内蔵版確認、nixpkgs 漂移 罠。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nix-flake-update-check/`（`SKILL.md` + `builders.md` + `traps.md`）|
| 定位 | **汎用**（特定倉庫 非結合） |
| 相棒 | 倉庫固有 工程 適配層技能 補完（NixKits 用 `nixkits-check-updates`） |

## 機能

- `flake.nix` 自 外部包 **動的検出**、自己 hosting / 動的版 / nixpkgs 追従 / 修正内蔵 除外
- **builder 別** hash 更新 flow（npm / cmake / Rust `buildRustPackage` / `fetchurl` / python）
- **GitHub Actions 更新確認**：自行実装（`gh api` tag 解決 → commit SHA 取得 → 書戻 與 comment 版数 同期）。action SHA 固定 後 更新通知 届 無 盲点 補；**Dependabot 等 外部自動化 依存 不**
- **文書 外部 link 失効監査**：全（多言語 含）外部 link 抽出 個別 探査。`404` `gh api` 再確認 後 初 確定（`curl` 404 権限 又 制限 可能 性 有）。`403` 多 場合 scraping 対策 且 dead link 非。修正 時 **表示 text 也 同期** 全言語 一度 修正。vendored 第三者 content 書換 不
- **機械的置換 非 文書 書直 触发判据**：依存 範囲 厳密固定 化、起動時／build 時 硬 検証 追加、依存 増減、build 方式 変更、対応 platform 狭——一 該当 則 人 文書 読 必要。「何時 書直」規定 且「如何 書」規定 不 明記
- hash 罠：SRI 形式、`fetchFromGitHub` 與 archive tarball 不一致、`lib.fakeHash`、npm 2 回構築
- Rust 包 **`Cargo.lock` 同期**必要（最 漏 易）
- `flake.lock` 三路分岐：gitignore 済 → skip；動的版 有 → 除外必須；他 → hash 與 共 commit
- `.patch` 文件内 硬符号版（version / url / hash）識別 與 更新 flow
- **同 account 子 project 連鎖確認**：本倉 参照 同 account 子倉（薄包装 / input / submodule）検出、循環無・依存衝突無・独立昇級可能 先 検証 上 連鎖並列 実行。子 project 結果 主倉 結果 視、各自 倉庫 記録 計上、主倉 子 project 条目 対 連結
  - **追従 判据 field 単位**：子倉 `rev` 固定値 與 異 雖 直 昇級 不可——変更 **build 入力** 落 可否 判断 要。release metadata（`publishConfig` / `repository` / `keywords`）與 文書 意味的入力 非 故 **追従 不**；`dependencies` / `files` / `main` / `exports` / `version` 意味的入力 故 **必 追従**。判別 不能 場合「追従」側 倒
- **外部自働化 PR 処置**：`npmDepsHash` 不知故 npm 更新 PR 必 失敗。branch 取回 後 hash 補完 且 merge
- **対話的確認**：着手前 一度 批次質問 全 保留事項 解決（大版跨、依存衝突 解法、channel 選択、配備可否）。「推測 → 訂正 → 再実行」往復 避；質問機構 無 代理 保留 list 一度 輸出 停止
- nixpkgs 漂移 罠：`inputs.*.follows`、`doInstallCheck`、`pythonRuntimeDepsCheckHook`、引数無 `nix flake lock`
- **fail-closed 実行時依存検証**：上流 起動時 正確 版 照合 故、build 成功 ≠ 使用可能。必 一度 実行 検証

## 設計：何故 二 技能 分割

本技能 旧名 `nixkits-check-updates`、NixKits 倉庫 強結合（四言語文書 path 硬符号、dsh 插件一覧、保守記録技能）。故 他 nix flake 倉庫 **其 侭 使用 不可**。

「汎用核心 + 倉庫適配層」分割 結果：

- 汎用手法（本技能）任意 nix flake 倉庫 直接 再利用 可能
- NixKits 固有 経験（事故教訓、文書規約）適配層 残、**移植性 為 希薄化 不要**

## 適配層 契約

本技能「変更 記録」迄 cover。倉庫固有 工程 適配層 補完。適配層 以下 説明 必要：

| 工程 | 適配層 述 内容 |
|------|----------------------|
| 文書同期 | 文書 path、言語一覧、同期 特殊節 |
| 変更記録 | 該倉庫 使用 記録技能 又 文件 |
| 動的版入力 | lock 不可 浮動 input 有無 |
| 既知 事故教訓 | 過去 更新起因 障害 與 回避策 |
| 追加同期項 | 内蔵一覧、生成文件 等 |
| 子 project 一覧 | 本倉 参照 同 account 子倉、各自 build 体系、子倉 log 用 path 與 言語規約 |

衝突 場合 **適配層 優先**。

## 使用

利用者「更新確認」又「包版更新」依頼時起動。
現倉庫 適配層技能 有 場合、先 適配層 load 後 本技能 実行。

## 構造：主 flow + 二 配套参考

単一 file 曾 918 行 達、実行中 目的 箇所 探 難。「独立 data 配套 file 分割」規則 従 再構成：

| file | 内容 | 読 時機 |
|------|------|--------|
| `SKILL.md` | 対話的確認 + 第 1〜9 步 主 flow + 適配層契約 | 常時 |
| `builders.md` | builder 別 hash 更新 flow、`flake.lock` 処理 | 第 4 步 |
| `traps.md` | nixpkgs 漂移 罠、fail-closed 検証、外部 link 失効監査、Actions 更新、修正内蔵版 | 第 7 步 自検 該当 時 |

**第 7 步「commit 前 六 自問」新設**：変体 複数 有 可否？依存表 一致 可否？source 取得 仍 有効 可否？実際 実行 可否？文書 記述 仍 成立 可否？`flake.lock` commit 可否？——六 何 及 同日 実測 事故 抽出、該当 則 `traps.md` 進 可、全文 読 不要。

**締 第 10 步**（適配層）：process 振返 與 規範 検証。特 **test branch 生 汎用 教訓 即座 main 戻 要**——当該 branch 取決 依 merge 不、教訓 残 不可。
