# 安全策略 — impure 分支

[中文](../SECURITY.md) | [English](SECURITY.en.md) | [日本語](SECURITY.ja.md) | 偽中国語

## 本分支 固有 危険：意図的 再現不能

`llama-cpp-ver` 求値 毎 GitHub 上 llama.cpp **最新 release JSON** 取得、
`nixpkgs` 追随 `nixos-unstable`、`flake.lock` **意図的 非提交**。即：

- 時 変 `nix build` 結果 異 可能性 有；
- 上流 誤 tag 或 release 改竄 時、**次 求値 其 取得**。而「自分 構築 此」
  示 lock 手元 無；
- CI 成果物 亦 commit 由 再現 不能。

此 **意図的 trade-off**：浮動 一 package 只 分支 閉込、`main` 固定 可能 化。
**本分支 二番目 package 追加 不可** —— 浮動面 小 程 監査 易。

## 緩和策

| 措置 | 説明 |
|---|---|
| **内容 上流 tag 固定** | 版 浮動、取得 `releases/latest` tag、同一 tag 源内容 不変 |
| **hash 変更 review 必須** | 版 上 時 overlay hash 変。其 diff 人 審査点 |
| **上流 唯一** | `ggml-org/llama.cpp` 本機推論経路 唯一 上流、第二 源 導入 無 |
| **CI 内 上流 binary 実行 無** | 本分支 構建 與 install 只。実際 llama.cpp 実行 下流 配備 事 |

## 脆弱性 報告

`main` 同：`main` 分支 `SECURITY.md` 参照 —— 非公開 経路 使用、
**公開 issue 開 不可**。本分支 自身（overlay / module / flake 定義）関 報告、
其 連絡 内「impure 分支」明記 願。
