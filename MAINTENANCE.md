# 维护日志

本文件记录 `impure` 分支的变更。规则同 `main`：四语条目数一致、时间戳精确到秒、
提交 SHA 全局去重、摘要一律清单式。

> **本分支的 SHA 与 `main` 的 SHA 不是同一套**——这里只记本分支自己的提交。

## 2026-10-22T06:18:45+09:00

**摘要**：四语 llama-cpp-rocm 文档随组件搬进本分支

- `docs/{zh,en,ja,pcn}/llama-cpp-rocm.md` 从 `main` 迁到本分支
- `main` 不再保留副本，避免两份必然漂移

| 提交 | 说明 |
|------|------|
| `0f15570` | docs(impure): 四语 llama-cpp-rocm 文档随组件搬进本分支 |

## 2026-10-21T23:53:50+09:00

**摘要**：from scratch 的 impure 通道建立

- orphan 分支（与 `main` 无共同历史），只装 `llama-cpp-rocm`
- `llama-cpp-ver` 是浮动 URL 输入，`nixpkgs` 跟随 `nixos-unstable`
- `.gitignore` 钉住 `flake.lock`——本分支故意不锁

| 提交 | 说明 |
|------|------|
| `9c50e5e` | feat(impure): from scratch 的 impure 通道 —— 只装 llama-cpp-rocm |
