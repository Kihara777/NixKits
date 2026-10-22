# 維護記録

本文件 記録 `impure` 分支 之 変更。規則 與 `main` 同：四言語 条目数 一致、時刻 秒単位
正確、commit SHA 全体 重複 無、摘要 必 箇条書。

> **本分支 SHA 與 `main` SHA 別系統** —— 此処 只 本分支 自身 之 commit 記録。

## 2026-10-22T14:05:07+09:00

**摘要**：AGENTS・SECURITY・四言語 README・維護記録 補完

- `AGENTS.md`（本分支 固有 規約 只）與 `SECURITY.md`（再現不能 危険 與 緩和）追加
- `README.md` 語言切替器 追加、`docs/README.{en,ja,pcn}.md` 補完
- 本分支 維護記録 建立（9c50e5e 與 0f15570 記録）

| 提交 | 説明 |
|------|------|
| `3c5da27` | docs(impure): AGENTS / SECURITY / 四言語 README / 記録 補完 |

## 2026-10-22T06:18:45+09:00

**摘要**：四言語 llama-cpp-rocm 文書 與 component 一緒 本分支 移

- `docs/{zh,en,ja,pcn}/llama-cpp-rocm.md` 由 `main` 移 至 本分支
- `main` 副本 残 無 —— 二 必 乖離 回避

| 提交 | 説明 |
|------|------|
| `0f15570` | docs(impure): 四言語 llama-cpp-rocm 文書 與 component 一緒 移動 |

## 2026-10-21T23:53:50+09:00

**摘要**：from scratch 之 impure channel 建立

- orphan 分支（與 `main` 共通履歴 無）、`llama-cpp-rocm` 只 収録
- `llama-cpp-ver` 是 浮動 URL input、`nixpkgs` 追随 `nixos-unstable`
- `.gitignore` 固定 `flake.lock` —— 本分支 意図的 非 lock

| 提交 | 説明 |
|------|------|
| `9c50e5e` | feat(impure): from scratch 之 impure channel —— llama-cpp-rocm 只 |
