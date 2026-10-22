# 维护日志

中文 | [English](docs/MAINTENANCE.en.md) | [日本語](docs/MAINTENANCE.ja.md) | [偽中国語](docs/MAINTENANCE.pcn.md)

本文件记录 `impure` 分支的变更。规则同 `main`：四语条目数一致、时间戳精确到秒、
提交 SHA 全局去重、摘要一律清单式。

> **本分支的 SHA 与 `main` 的 SHA 不是同一套**——这里只记本分支自己的提交。

## 2026-10-22T14:32:43+09:00

**摘要**：安全策略四语、维护日志加语言切换器

- `SECURITY.md` 加切换器，新增 `docs/SECURITY.{en,ja,pcn}.md`
- 四语 `MAINTENANCE.*` 各自加切换器（条目内容不动）

| 提交 | 说明 |
|------|------|
| `4cb0059` | docs(impure): 安全策略四语 + 维护日志加语言切换器 |

## 2026-10-22T14:05:07+09:00

**摘要**：补齐 AGENTS、SECURITY、四语 README 与维护日志

- 新增 `AGENTS.md`（只写本分支特有约定）与 `SECURITY.md`（不可复现的风险与缓解）
- `README.md` 加语言切换器，补 `docs/README.{en,ja,pcn}.md`
- 建立本分支维护日志（记录 9c50e5e、0f15570 两个提交）

| 提交 | 说明 |
|------|------|
| `3c5da27` | docs(impure): 补齐仓库文件 —— AGENTS / SECURITY / 四语 README 与维护日志 |

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
