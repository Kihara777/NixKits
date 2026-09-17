# nixkits-check-updates (技能)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)  | 偽中国語

> NixKits 倉庫 的 **包更新適配層**——汎用技能 `nix-flake-update-check` 之上、本倉庫特有 四言語文書同期、dsh 内蔵插件一覧同期、同 account 子倉 連鎖確認 座標、保守記録記入、過去 事故教訓 補完。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | 符号化代理技能 |
| 路 | `skills/nixkits-check-updates/SKILL.md` |
| 依存 | `nix-flake-update-check`（汎用 flow、先 読込 必須） |

## 構造：汎用核心 + 倉庫適配層

更新確認能力 二 技能 分割、責務 分離：

| 技能 | 責務 | 移植性 |
|------|------|--------|
| `nix-flake-update-check` | 汎用手法：包検出、builder 別 hash flow、同 account 子 project 連鎖並列確認、flake.lock 扱、修正内蔵版確認、nixpkgs 漂移 罠 | 任意 nix flake 倉庫 |
| `nixkits-check-updates` | 本倉庫適配：四言語文書、插件一覧、子倉 座標、保守記録、過去 事故教訓 | NixKits 専用 |

此 分割 依、汎用手法 他 nix flake 倉庫 直接 再利用 可能、NixKits 固有 経験（事故教訓、文書規約）移植性 為 希薄化 不要。両者 衝突 場合 **適配層 優先**。

## 本倉庫固有 工程

- **四言語文書同期**：`docs/<lang>/<pkg>.md`（zh 基準 + en/ja/pcn）、zh 先 書 後 翻訳
- **dsh 插件一覧同期**：`dsh` 更新時 内蔵 `cordis.patch.yml` 的 entry id 一覧 同期
- **保守記録**：`write-maintenance-log` 技能 呼出、四言語 同期
- **同 account 子倉 連鎖確認**：`dsh-api-balance` 薄包装 子倉 `Kihara777/dsh-api-balance` 参照、其 自身 版変更 併 確認 要（座標 下記）
- **`llama-cpp-ver` 浮動入力**：lock 不可 故 `flake.lock` commit 不
- **汎化義務**：汎用性 改善 発見 時 `nix-flake-update-check` 書戻

## 子倉参照：dsh-api-balance

連鎖確認 汎用手法（循環、深度上限、依存衝突 判据）`nix-flake-update-check` 第 9 步 在、本倉 具体 座標 適配層 限定 知：

| 項目 | 値 |
|---|---|
| 子倉 | `Kihara777/dsh-api-balance` |
| 参照方式 | `fetchFromGitHub` 依 `rev` 固定（**flake input 非**） |
| 子倉 build 体系 | 純 JS npm 包（`package.json`、build script 無） |
| 鎖 長 | 1 層（此 子倉 更 同 account 親 無） |
| 配布 | **npm 公開 不**（保守者 視覚障害 故 2FA 手続 完了 不能） |

要点：

- 子倉 **nix flake 非**——`nix flake check` 及 flake.lock 扱 適用 不
- `rev` 変更 時 **`src` hash 與 `npmDepsHash` 両方 変更** 故、`nix build` 2 回 必要
- 子倉 `@deepseek-ai/dsh-*` 依存 **peer 性質**：host 比 低 版 正常状態、判据「子倉 要求 host 提供 比 **高** 可否」、非「両者 相等 可否」
- 子倉 切出 後 **文書 限定** commit 有 且 版番号 未変更、判据 依 薄包装 再固定 **発生 不**
## 確認範囲

`flake.nix` 動的読取、以下除外：

- 自己 hosting 包（倉庫内源有）
- 動的版追跡（構築時最新取得）
- nixpkgs 追従（修正上乗）
- 修正内蔵版（手動確認）

残余外部包 全自動確認対象。

## hash 注意点

完全 規則 `nix-flake-update-check` 参照。要点：

- SRI hash 標準 base64（`+` `/` `=`）使用、URL-safe 変種（`-` `_`）不可
- `fetchFromGitHub` source hash GitHub archive tarball 自**事前計算不可** — `nix build` hash mismatch 誤取得必要
- `npmDepsHash` 空場合、空文字列 `""` 非 `lib.fakeHash` 使用
- npm 包 2 回 `nix build` 必要：1 回目 source hash、2 回目 npmDepsHash

## 使用

利用者「更新確認」又「包版更新」依頼時起動。
保守 mode（`maintenance`）既 本技能 與 `nix-flake-update-check` 注入済。
