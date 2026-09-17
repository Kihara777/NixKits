# nixkits-check-updates (Skill)

[中文](../../zh/skills/nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | 日本語  | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> NixKits リポジトリの**パッケージ更新アダプタ層**——汎用スキル `nix-flake-update-check` の上に、本リポジトリ固有の四言語ドキュメント同期、dsh 内蔵プラグイン一覧同期、同アカウント子リポジトリ連鎖チェックの座標、メンテナンスログ記録、過去の事故教訓を補完する。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Coding Agent Skill |
| パス | `skills/nixkits-check-updates/SKILL.md` |
| 依存 | `nix-flake-update-check`（汎用フロー、先にロード必須） |

## 構造：汎用コア + リポジトリ適応層

更新チェック能力は二つのスキルに分割され、責務を分離している：

| スキル | 責務 | 移植性 |
|--------|------|--------|
| `nix-flake-update-check` | 汎用手法：パッケージ検出、ビルダー別 hash フロー、同アカウント子プロジェクトの連鎖並列チェック、flake.lock の扱い、パッチ内蔵バージョン確認、nixpkgs ドリフトの罠 | 任意の nix flake リポジトリ |
| `nixkits-check-updates` | 本リポジトリ適応：四言語ドキュメント、プラグイン一覧、子リポジトリの座標、メンテナンスログ、過去の事故教訓 | NixKits 専用 |

この分割により、汎用手法は他の nix flake リポジトリでそのまま再利用でき、NixKits 固有の経験（事故教訓、ドキュメント規約）を移植性のために薄める必要もない。両者が衝突する場合は**適応層を優先**する。

## 本リポジトリ固有の工程

- **四言語ドキュメント同期**：`docs/<lang>/<pkg>.md`（zh 基準 + en/ja/pcn）、zh を先に書いてから翻訳
- **dsh プラグイン一覧同期**：`dsh` 更新時に内蔵 `cordis.patch.yml` の entry id 一覧を同期
- **メンテナンスログ**：`write-maintenance-log` スキルを呼び出し、四言語で同期
- **同アカウント子リポジトリの連鎖チェック**：`dsh-api-balance` 薄いラッパーは子リポジトリ `Kihara777/dsh-api-balance` を参照しており、その自身のバージョン変更も併せて確認する（座標は下記）
- **`llama-cpp-ver` 浮動入力**：ロック不可のため `flake.lock` はコミットしない
- **汎化義務**：汎用性のある改善を見つけたら `nix-flake-update-check` へ書き戻す

## 子リポジトリ参照：dsh-api-balance

連鎖チェックの汎用手法（循環、深さ上限、依存衝突の判据）は
`nix-flake-update-check` 第 9 步にあり、本リポジトリの具体的な座標は適応層のみが知る：

| 項目 | 値 |
|---|---|
| 子リポジトリ | `Kihara777/dsh-api-balance` |
| 参照方式 | `fetchFromGitHub` による `rev` 固定（**flake input ではない**） |
| 子リポジトリのビルド体系 | 純 JS の npm パッケージ（`package.json`、ビルドスクリプトなし） |
| 鎖の長さ | 1 層（この子リポジトリに更なる同アカウントの親はない） |
| 配布 | **npm へは公開しない**（保守者が視覚障害のため 2FA 手続きを完了できない） |

要点：

- 子リポジトリは **nix flake ではない**——`nix flake check` や flake.lock の扱いを適用しない
- `rev` を変えると **`src` hash と `npmDepsHash` の両方が変わる**ため、`nix build` は 2 回必要
- 子リポジトリの `@deepseek-ai/dsh-*` 依存は **peer 的性質**：ホストより低いバージョンは正常状態であり、判据は「子リポジトリの要求がホストの提供より**高い**か」であって「両者が等しいか」ではない
- 子リポジトリは切り出し後に**ドキュメントのみ**のコミットがあり版番号は未変更であり、判据により薄いラッパーの再固定は**発生しない**
## チェック範囲

`flake.nix` を動的に読み取り、以下を除外：

- セルフホストパッケージ（リポジトリ内にソースあり）
- 動的バージョン追跡（ビルド時に最新を取得）
- nixpkgs 追従（パッチオーバーレイ）
- パッチ内蔵バージョン（手動確認）

残りの外部パッケージはすべて自動チェック対象。

## hash の注意点

完全な規則は `nix-flake-update-check` を参照。要点：

- SRI hash は標準 base64（`+` `/` `=`）を使用し、URL-safe 変種（`-` `_`）は不可
- `fetchFromGitHub` の source hash は GitHub archive tarball から**事前計算できない** — `nix build` の hash mismatch エラーから取得する必要あり
- `npmDepsHash` を空にする場合は空文字列 `""` ではなく `lib.fakeHash` を使用
- npm パッケージは 2 回の `nix build` が必要：1 回目で source hash、2 回目で npmDepsHash

## 使用

ユーザーが「更新をチェック」または「パッケージバージョンを更新」と依頼したときに起動。
メンテナンスモード（`maintenance`）は既に本スキルと `nix-flake-update-check` を注入している。
