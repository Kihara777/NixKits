# AGENTS.md — impure 分支

本文件只适用于 `impure` 分支。仓库**通用**的工作流（分批提交、四语文档同步、
维护日志规范）定义在 `main` 分支的 `AGENTS.md`——先读那份，再看这份。
**这里只写本分支特有的约定**，重复的部分不复制（复制必然漂移）。

## 定位

`llama-cpp-rocm` 的**唯一浮动源**。orphan 分支（与 `main` 无共同历史），
只装这一个包，供 `main` 或 `/etc/nixos` 以 input 引用。

## 硬约定

1. **不提交 `flake.lock`**（`.gitignore` 里钉着）。
   本分支的 `llama-cpp-ver` 是 GitHub `releases/latest` 的 JSON、`nixpkgs` 是
   `nixos-unstable`——两者都**故意**跟随上游。提交 lock 会让「永远跟最新」失效，
   而那正是本分支存在的意义。要可复现请用 `main`。

2. **overlay 的 curried 形式是有意的**：`{ llama-cpp-ver }: (final: prev: ...)`
   ——版本号要作为参数注入。勿改成标准 overlay。

3. **只装 `llama-cpp-rocm`**。本分支是「浮动的隔离区」，不是第二个主仓。
   往里加第二个包会扩大浮动面，而浮动面越小越好审。

4. **没有 lock 带来的一个坑**：直接
   `nix flake metadata github:.../impure` 会报
   `cannot write modified lock file` —— 本分支没有 lock，而该命令想写一份。
   求值请加 `--no-write-lock-file`：
   `nix eval --no-write-lock-file --raw 'github:Kihara777/NixKits/impure#packages.x86_64-linux.llama-cpp-rocm.name'`
   （2026-10-22 实测 → `llama-cpp-0.7.0`）。下游正常用法不受影响：它在自己的
   `flake.lock` 里记下本分支的 rev（`nix flake lock --update-input nixkits-impure`）。

5. **验证方式与 `main` 不同**：本分支没有 `nix flake check` 的那些自检脚本
   （它们不在这个分支上）。改动的判据是：
   - `nix flake check`——至少确认 flake 能求值；
   - `nix build .#llama-cpp-rocm`——**真构建**，不是 `--dry-run`；
   - 改了 `module.nix` 的话：在本机 `nixos apply` 一次并核对服务起来。

6. **四语文档同步**：`README.md`（zh）→ `docs/README.{en,ja,pcn}.md`；
   `docs/zh/llama-cpp-rocm.md` → `docs/<lang>/llama-cpp-rocm.md`。
   改哪一份就**同批**改全部四份。

7. **维护日志**：`MAINTENANCE.md` + `docs/MAINTENANCE.{en,ja,pcn}.md`，
   记录**本分支**的提交 SHA（不是 `main` 的）。其余规则同 `main`：
   四语条目数一致、时间戳精确到秒、SHA 全局去重。

## 升级 llama.cpp

不需要手动改版本号：`llama-cpp-ver` 每次求值都取上游最新 release。
下游（`/etc/nixos`）用 `nix flake lock --update-input nixkits-impure` 拉新 rev。

上游若改了构建方式（CMake 选项、依赖），改 `overlay.nix` 的 `postPatch` 等处；
**这里的 hash 不是源码 tarball 的 hash**——取的只是版本号，内容由上游 tag 固定。

## 提交与推送

同 `main`：按逻辑类别分批提交，每批之后立即 push。
