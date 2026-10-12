# 提交计划：opencode-telegram → nixpkgs

**状态：草稿已建、构建通过、运行层验证通过。等狐莉人工核查。**

---

## 一、这个包**只改一个文件**（新增），加一个维护者条目

| 文件 | 动作 |
|---|---|
| `pkgs/by-name/op/opencode-telegram/package.nix` | **新增**（内容 = [`package.nix`](package.nix) 逐字节相同） |
| `maintainers/maintainer-list.nix` | 插入 `kitsunori` 条目 —— 见 [`../MAINTAINER-ENTRY.md`](../MAINTAINER-ENTRY.md) |

## 二、入场评估（每条都有出处）

| 项 | 结论 |
|---|---|
| nixpkgs 里有没有 | **没有**（`pkgs/by-name/op/` 下无此包，`ref=master` 现查） |
| 有没有在途 PR | **没有**（标题搜 `opencode-telegram` 命中 0） |
| 上游 | `grinev/opencode-telegram-bot` —— **1245 stars**、**MIT**、最后提交 **2026-10-11**、未归档 |
| 宿主程序 | **`opencode` 已在 nixpkgs 里**（`pkgs/by-name/op/opencode/`），另有 `opencode-desktop` |
| 版本 | **0.26.4**（上游最新 tag，从 0.26.3 升上来） |

## 三、与 NixKits 那版的**关键差异：riscv64 那套机器全部去掉**

NixKits 的包里有约 60 行 riscv64 交叉构建机器（gcc shim、`--force_build=1`、
`build-release` 手调、qemu smoke test）。**nixpkgs 版不该带**，理由是实的：

- 上游 `better-sqlite3@13` 的 `prebuilds/` **恰好覆盖 8 个平台**：
  `darwin-{arm64,x64}`、`linux-{arm64,x64}`、`linuxmusl-{arm64,x64}`、`win32-{arm64,x64}`
  —— **没有 riscv64，也没有 i686**
- 它**没有 install 脚本**（v13 起改成纯预编译分发），所以 `npm ci --ignore-scripts`
  之后能不能跑，完全取决于 tarball 里有没有本平台那一份
- 那套机器是**我们**为 NixOS-on-riscv64 做的，在 nixpkgs 的构建矩阵里是死代码

所以 `platforms` 写**精确的四个**（有预编译的那四个），多一个都是虚报。

## 四、两个 commit

### commit 1

```
maintainers: add kitsunori

Assisted-by: DeepSeek Harness (DeepSeek-V41-Flash)
```

### commit 2

正文待写（`commit-message.txt`）。标题：`opencode-telegram: init at 0.26.4`

## 五、判据（已跑）

| 判据 | 结果 |
|---|---|
| 求值 + 构建 | ✅ `r5q4k3sk…` |
| **运行层：包装器能起** | ✅ `--help` 有 `Usage:` 输出 |
| **运行层：原生模块可用** | ✅ 开库 → 建表 → 写入 → 读回 `{"x":42}`，SQLite 3.53.3 |
| **运行层反证臂** | ✅ 用 `overrideAttrs` 造一份删掉 `linux-x64.node` 的派生 → **必须失败**（`Cannot find module`，exit 1） |
| `check-draft.sh` 机械项 | ✅ 全过 |
| src hash 独立复算 | ✅ **真的重新下了一遍**，一致 |
| nixfmt | ✅ |

**仍未验**：aarch64 / darwin 构建（本地只有 x86_64）；上游的自带测试
（`vitest run`）**尚未接进构建**——见第六节。

## 六、待定：要不要跑上游自带测试

上游有 `tests/` 与 `vitest.config.ts`，`npm test` = `vitest run`。
装上就能多一层判据，但要先弄清它需要什么（网络？真的 opencode 实例？）。

**没弄清之前不写进判据，也不在 PR 正文里声称。**

## 七、路上的一个教训

反证臂最初写成 `node -e "require('<删掉预编译的那份>')"`，它**成功**了，
于是判据报红说「反证臂没翻脸」。

查清：**`require()` 是懒的**——它自己成功，不碰绑定；**构造实例**时才会去找 `.node`。

**反证臂必须与正臂同强度**，否则它给出的安心是假的。已改成与正臂同一段代码。

> 附带：我第一版还试过 `cp -r` 出来再 `rm` 预编译——store 文件是只读的，
> `rm` 全失败，那个「反证」什么都没改。**别手工动 store 的副本**
> （而且 `chmod -R` 会顺着符号链接打到 `/nix/store`，本仓第一天踩过）。
> 正确做法是用 `overrideAttrs` 让 nix 自己产出那一份。
