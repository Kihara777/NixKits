# メンテナンスログ

本ファイルは `impure` ブランチの変更を記録する。規則は `main` と同じ：
四言語で条目数一致、タイムスタンプは秒単位、commit SHA は全体で重複なし、
摘要は必ず箇条書き。

> **本ブランチの SHA は `main` の SHA とは別系統** ——ここには本ブランチ自身の
> コミットのみを記す。

## 2026-10-22T14:05:07+09:00

**概要**：AGENTS・SECURITY・四言語 README・メンテナンスログを補完

- `AGENTS.md`（本ブランチ固有の規約のみ）と `SECURITY.md`（再現不能のリスクと緩和）を追加
- `README.md` に言語切替器を追加し、`docs/README.{en,ja,pcn}.md` を補完
- 本ブランチのメンテナンスログを建立（9c50e5e と 0f15570 を記録）

| コミット | 説明 |
|------|------|
| `3c5da27` | docs(impure): AGENTS / SECURITY / 四言語 README / ログを補完 |

## 2026-10-22T06:18:45+09:00

**概要**：四言語の llama-cpp-rocm 文書がコンポーネントと共に本ブランチへ移る

- `docs/{zh,en,ja,pcn}/llama-cpp-rocm.md` を `main` から本ブランチへ移した
- `main` は副本を残さない ——二つが必ず乖離することを避ける

| コミット | 説明 |
|------|------|
| `0f15570` | docs(impure): 四言語 llama-cpp-rocm 文書をコンポーネントと共に移動 |

## 2026-10-21T23:53:50+09:00

**概要**：from scratch の impure チャネルを建立

- orphan ブランチ（`main` と共通履歴なし）、`llama-cpp-rocm` のみを収録
- `llama-cpp-ver` は浮動 URL input、`nixpkgs` は `nixos-unstable` 追従
- `.gitignore` が `flake.lock` を固定 —— 本ブランチは意図的に lock しない

| コミット | 説明 |
|------|------|
| `9c50e5e` | feat(impure): from scratch の impure チャネル —— llama-cpp-rocm のみ |
