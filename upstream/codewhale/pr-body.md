# 提交计划：codewhale → nixpkgs

**状态：草稿已建、构建通过、运行层验证通过。等狐莉人工核查。**

---

## 一、入场评估（每条现查）

| 项 | 结论 |
|---|---|
| nixpkgs 里有没有 | **没有** |
| 在途 PR | **没有**（标题搜 `codewhale` 命中 0） |
| 上游 | `codewhale-hq/Codewhale` —— **41078 stars**、**MIT**、最后提交 2026-10-11、未归档 |
| 版本 | v0.10.1（= 我们的版本，最新 release） |
| `Cargo.lock` | 在仓库根 ✓（`cargoHash` 就是从它算的） |

## 二、只改一个文件（新增），加一个维护者条目

| 文件 | 动作 |
|---|---|
| `pkgs/by-name/co/codewhale/package.nix` | **新增**（= [`package.nix`](package.nix) 逐字节相同） |
| `maintainers/maintainer-list.nix` | 插入 `kitsunori` —— 见 [`../MAINTAINER-ENTRY.md`](../MAINTAINER-ENTRY.md) |

## 三、从 NixKits 那版**去掉了什么**，以及为什么

| 去掉的 | 理由 |
|---|---|
| `env` 整块（`CFLAGS_riscv64_*` / `CC_x86_64_*` / `NIX_CFLAGS_COMPILE`） | 全是交叉编译的绕行，为 riscv64 存在 |
| `buildInputs` 里的 `stdenv.cc.cc.libgcc` | 同上：交叉 gcc 的 `libgcc_s.so.1`，给 `autoPatchelfHook` 解析用 |
| `autoPatchelfHook` | 源码构建不需要它（那是给预编译二进制的） |
| `buildPackages` 参数 | 只有那段交叉用的 |
| `codewhale-tui` 符号链接 | 0.10.1 已经合并成单个可执行文件；那个名字只是给旧脚本的别名 |

**保留**：`buildAndTestSubdir = "crates/cli"`、`doCheck = false`（上游测试要网络）、
`codew` 符号链接（上游自己的 Release 就是这么发的，并建议 Cargo 用户加它）。

### ⚠️ 没有包含：那个 218 行的 ptrace 拦截器

NixKits 的包里有一个 `codewhale-sudo-ptrace.c`，它改写
`prctl(PR_SET_NO_NEW_PRIVS)` / `prctl(PR_SET_SECCOMP)` —— **那是关掉内核加固**。

**准确的事实是**：它**只在 `allowSudo = true` 时编译进包**，
而 nixpkgs 形态下 `allowSudo` 必然是 `false`，所以它不是「nixpkgs 会收到的代码」。
**但要在 PR 正文里主动说清**，否则审阅者从上游仓库看到它会问。

## 四、两个 commit

### commit 1

```
maintainers: add kitsunori

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

### commit 2

正文待写。标题：`codewhale: init at 0.10.1`

## 五、判据（已跑）

| 判据 | 结果 |
|---|---|
| 求值 + 构建 | ✅ `91kryqnk…` |
| **两个 vet 棘轮求值出 true** | ✅ `{"strictDeps":true,"structuredAttrs":true}` |
| src hash 独立复算 | ✅ **真的重新下了一遍**，一致 |
| `cargoHash` | ✅ 由构建报错给出（`sha256-DUobhZ6h…`），非手抄 |
| **运行层：`--version`** | ✅ `codewhale 0.10.1 (dev)` |
| **运行层：`codew` 符号链接** | ✅ 指向 `codewhale`，且能跑 |
| **运行层：`doctor`** | ✅ 打印 `Version Information` 与 `codewhale: 0.10.1` —— **真实代码路径**（解析配置路径），不是 argv 解析 |
| **运行层反证臂** | ✅ `overrideAttrs` 去掉 `postInstall` → `codew` **必须不存在**（证明第 ③ 步量的是我们的代码） |
| `check-draft.sh` 机械项 | ✅ 16 项 0 失败 |
| nixfmt | ✅ |

**仍未验**：
- aarch64-linux 构建（本地只有 x86_64）
- **上游自带测试**：`doCheck = false`，因为上游测试需要网络。**本 PR 不声称跑过测试。**
- `--version` 输出带 `(dev)` 后缀 —— 源码 tarball 里没有 git 元数据，二进制因此
  自报 `dev`。**这是事实，写在正文里；不影响功能。**

## 六、一个必须记住的量具教训

我一度用 `grep -rl '__structuredAttrs' $P/pkgs/by-name/*/*/package.nix` 数出
**「0 个包设它」**，并据此差点判断棘轮不适用。

**那个 glob 根本没展开**（条目太多），grep 于是一个都没扫到。
换 `grep -rl … $P/pkgs/by-name` 之后真实数字是 **2192 个文件**，
而 `ripgrep/package.nix:22` 就明明白白写着 `__structuredAttrs = true;`。

**分母是 0 的「全过」，要先怀疑量具，不是先下结论。**
