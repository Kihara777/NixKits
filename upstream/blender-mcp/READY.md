# 提交就绪：排查表与文件清单（blender-mcp → nixpkgs）

> **这份文件不写「怎么提交」。** 提交计划、两个 commit 的正文、PR 摘要只在
> [`pr-body.md`](pr-body.md) 里有一份 —— **不在这里复制**。
>
> 2026-10-10 重写。此前这一份与 `pr-body.md` 并行描述同一件事，而且**它整体停留在
> Kihara777 时代**：旧 handle、旧插入点（`kiyotoko`/`kjeremy`）、旧提交身份、旧模型名，
> 共 12 处。两份描述同一件事 ＝ 它们一定会漂；今天我已经在别处撞过四次这种漂。
> 现在分工是：**计划归 `pr-body.md`，排查与清单归这里，取证归 `VERIFICATION.md`。**

## 一、就绪判据（每条都有产物可核）

| # | 条件 | 判据 |
|---|---|---|
| 1 | 包定义与将提交的那份**逐字节相同** | `cmp` 仓库那份 vs 分支上那份 |
| 2 | 求值 / 构建 / 产物 / **运行** 四层全过 | `bash build.sh`（`NIXPKGS_PATH` 指一棵真 nixpkgs） |
| 3 | 每条判据都**翻过脸** | `bash tests/criterion-self-test.sh` |
| 4 | `nixfmt` 通过 | `build.sh` 的第一步 |
| 5 | 注释**全英文** | 非 ASCII 字符数 = 0（评审第 ③ 条） |
| 6 | 不引用本 PR 之外的路径 | 无 `NixKits` / `build.sh` / `pr-body.md` 等字样（评审第 ① 条） |
| 7 | `maintainers` **非空且能解析** | 求值出 `grg41`（评审第 ② 条） |
| 8 | 许可有依据 | `SPDX-License-Identifier` 在源文件里 + 上游 issue #59 |
| 9 | 机械项一遍过 | `bash ../check-draft.sh blender-mcp/package.nix` |
| 10 | 披露三处同值 | 两个 commit trailer + PR 正文，均为 `DeepSeek-V41-Flash` |
| 11 | 跨文件一致性 | `bash ../check-consistency.sh` |

### 明确**未**验到的（不许当成验过）

- 完整 `nix-update` 跑通（只验到它能认出这个 Gitea host 与 tag 前缀）；
- 在真 nixpkgs 检出里跑 `nixpkgs-vet`（要两个 git 检出）；
- aarch64 构建；
- `r-ryantm` 的实际行为。

`Lint / nixpkgs-vet` 与 `Lint / treefmt` **在 #572360 上由上游 CI 跑过并通过** ——
那是经验事实，不是推理。

### 一个被实测推翻的设计

`blender ? null` **挡不住 `callPackage` 的自动绑定**。这个坑的通用形态已写进
`skills/nixpkgs-package-upstream`（陷阱 ⑪）与 `MIND.md`（形态 A），不在这里重复。

## 二、如果被拦下，先看哪里

| 症状 | 第一件事 |
|---|---|
| `nixpkgs-vet` 报 `strictDeps` / `__structuredAttrs` | 把 vet 拉下来对着 fork 真跑一次，别猜 |
| 审阅者问许可 | 引 issue #59，以及 `SPDX-License-Identifier` 在每个源文件里这个事实 |
| 审阅者问那个 `--replace-fail` 补丁 | 引 [`VERIFICATION.md`](VERIFICATION.md) 第二节；并说明**可以把它提给上游** |
| 审阅者问为什么排除 Blender 那个测试文件 | 它要真实运行的 Blender 编辑器实例，沙箱里没有；其余三个文件 102 项全跑 |
| hash 类报错（`npmDepsHash` 等） | 与本包无关（纯 Python） |
| 审阅者问「你自己看过这份 diff 吗」 | 引 PR 正文里那一段，并说明逐行读过后找出的是哪两处 |

## 三、这份目录里各文件是干什么的

| 文件 | 用途 |
|---|---|
| [`package.nix`](package.nix) | **待提交的包定义** —— 与将放到 `pkgs/by-name/bl/blender-mcp/package.nix` 的那份逐字节相同 |
| [`commit-message.txt`](commit-message.txt) | commit 2 的正文（**单一来源**，用 `git commit -F` 直接喂） |
| [`pr-body.md`](pr-body.md) | 提交计划、两个 commit 的正文、PR 标题与正文 |
| [`build.nix`](build.nix) | 求值入口：`builtins.getFlake "path:<nixpkgs>"` 读一棵真树，并注入 `grg41` 以模拟合并后的状态 |
| [`build.sh`](build.sh) | 四层判据（求值 / 构建 / 产物 / 运行）+ nixfmt |
| [`tests/criterion-self-test.sh`](tests/criterion-self-test.sh) | 反证：每条判据都要能被已知坏输入撞响 |
| [`VERIFICATION.md`](VERIFICATION.md) | 两个「提交后会被问到」的点的取证：自动更新、替换锚点 |
| [`../MAINTAINER-ENTRY.md`](../MAINTAINER-ENTRY.md) | 维护者条目的确切内容与插入位置（**两个包共用**） |
| [`../maintainer-entry.nix`](../maintainer-entry.nix) | 该条目的**代码侧单一来源**（各 `build.nix` 从这里 import） |
| [`../check-draft.sh`](../check-draft.sh) | 机械判据：评审提过的每一类问题 |
| [`../check-consistency.sh`](../check-consistency.sh) | 盯「同一件事存在于多处」的地方 |
| README 本文件 | 就绪判据、排查表、文件清单 |
