---
name: nixkits-check-updates
description: NixKits 仓库的软件包更新适配层——在通用技能 nix-flake-update-check 之上，补充本仓库特有的四语文档同步、dsh 内置插件清单同步、同账户子仓（dsh-api-balance）的链式检查坐标、维护日志记录与历史事故教训（comfyui 漂移、codewhale-riscv64 CI 失败）。
---

# NixKits 软件包更新（仓库适配层）

本技能是 **NixKits 仓库特有**的适配层。通用更新方法（包型分流的 hash 流程、
flake.lock 处置、补丁内版本检查、nixpkgs 漂移陷阱）定义在
**`nix-flake-update-check`** 技能中——**先加载它**，再用本技能补充下列
NixKits 特有环节。

```
→ 先加载技能: nix-flake-update-check   （通用流程）
→ 再加载技能: nixkits-check-updates   （本文件，仓库适配）
```

> 两个技能冲突时，**以本适配层为准**——它了解 NixKits 的真实约定。

## 本仓库的特有约定

| 项 | NixKits 的取值 |
|---|---|
| 包目录 | `packages/*.nix`（部分包在同名子目录内，如 `packages/ruyi/`） |
| 文档布局 | `docs/<lang>/<pkg>.md`，**四语**：`zh`（基准）/ `en` / `ja` / `pcn` |
| 变更记录 | `MAINTENANCE.md` + `docs/MAINTENANCE.{en,ja,pcn}.md`，由 `write-maintenance-log` 技能维护 |
| 不可锁定输入 | `llama-cpp-ver`（浮动追踪 llama.cpp 最新版），故 **`flake.lock` 不提交** |
| 额外同步 | 升级 `dsh` 时须同步内置插件清单（见下） |
| 子项目 | `dsh-api-balance` 薄封装引用同账户子仓 `Kihara777/dsh-api-balance`（见下） |
| 泛化要求 | 修复后评估可泛化内容，更新回 `nix-flake-update-check` |

## 第 5 步补充：四语文档同步

NixKits 的文档是**四语**体系。版本号变更必须同步全部语言，且
**`docs/zh/` 先写，再翻译到其他语言**：

```bash
for lang in zh en ja pcn; do
  [ -f "docs/$lang/<pkg>.md" ] && sed -i "s/$OLD_VER/$NEW_VER/g" "docs/$lang/<pkg>.md"
done
```

同时更新 `README.md` 及 `docs/*/README.md` 中的版本表（四语同步）。

> `pcn`（偽中国語）的翻译规则见 `translate-pseudocn` 技能：**必须剥离全部
> 假名**。`check-maintenance-log` / `check-doc-links` 会拦截残留假名。

## 第 5 步补充：dsh 内置插件清单同步

升级 `dsh` 时，除版本号外还必须同步内置插件清单——dsh 的
`cordis.patch.yml` entry id 是 `nixkits.dsh.plugins.disabled` 的取值来源，
版本升级后插件可能增删。提取并写入 4 语言文档的「插件清单」章节：

```bash
DSH=$(nix build .#dsh --print-out-paths --no-link)
LIST=$(for f in "$DSH/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/"dsh-*/cordis.patch.yml; do
  awk '/^    - id: /{id=$3} /^      name: /{name=$2; gsub(/[.,\047]/, "", name); print id" -> "name}' "$f"
done | sort -u)
```

将提取的 `id -> name` 列表替换文档中「插件清单」代码块的内容
（标题保留各语言本地化，清单正文 id/name 跨语言一致）。

## 第 8 步补充：记录维护日志

更新完成后**必须**调用 `write-maintenance-log` 技能：

```
→ 触发技能: write-maintenance-log
```

要点（完整规范以该技能为准）：LIFO 插入、时间戳精确到秒（`git log` 获取）、
四语同步、提交表按时间升序、推送后核对各语言条目数一致
（`grep -c '^20' MAINTENANCE.md docs/MAINTENANCE.*.md`）。

## NixKits 专有排除项

通用排除规则之外，本仓库还有：

- **`llama-cpp-ver` 浮动输入**：overlay `llama-cpp-rocm` 通过该输入动态获取
  上游最新版本号，**不可锁定**——这是 `flake.lock` 不进 `.gitignore` 之外的
  必然结果：`flake.lock` 已被 `.gitignore` 排除，故第 4 步的 flake.lock
  前置检测会命中「情况 1」直接跳过。
- **`godot-ai`**：受上游依赖限制，无独立构建 workflow（详见 AGENTS.md）。
- **`codewhale-src`**：不是独立包，而是 `codewhale.nix` 在 riscv64 上的源构建分支。

## NixKits 历史事故教训

以下是本仓库实测踩过的坑，通用技能做不到（它不知道本仓库的具体配置）。
**更新相关包前先读**：

### comfyui / python 包（2026-08-09 事故）

nixpkgs 漂移到 `f13ff45` 后 `diffusers-0.38.0` 构建失败。根因是
`pythonRuntimeDepsCheckHook`（nixpkgs ≥ 2026-08-05）——修复方式见通用技能
「常见陷阱」第 3 条。

配套操作纪律：修复后**不要**执行无参数 `nix flake lock`，否则 nixpkgs
再次漂移、问题重演。用 `--update-input` 或固定 rev。详见通用技能陷阱第 4 条。

### codewhale-riscv64（CI 连续失败）

曾因用 `nix-prefetch-url` 预取 archive tarball 的 hash 作为
`fetchFromGitHub` 的 hash，导致 riscv64 CI **连续失败**——两者 hash 不一致。
正确姿势见通用技能「交叉编译注意」节。

### Rust 包 Cargo.lock 同步

`codewhale-src` 的升级暴露出「只改 version + hash 会漏掉 Cargo.lock」的问题，
已泛化为通用技能中 Rust 包流程的第 3 步。

## 第 9 步补充：本仓的子项目引用关系

通用技能第 9 步给出「同账户子项目链式检查」的方法与前提判据。**本仓的实际
引用关系**只有这里知道：

| 包 | 引用的子仓 | 引用方式 | 子仓构建体系 | 可链式 |
|---|---|---|---|---|
| `dsh-api-balance` | `Kihara777/dsh-api-balance` | `fetchFromGitHub` 固定 `rev`（**不是** flake input） | 纯 JS npm 包（`package.json`，无 build script） | ✅ |
| `dsh-preset-news-three-elements` | 无（源码在本仓 `packages/dsh-preset-news-three-elements/`） | 自建包 | — | — |
| `dsh-nixos-shell` | 无（源码在本仓 `packages/dsh-nixos-shell/`） | 自建包 | — | — |

**判据**：`grep -rn 'owner = "Kihara777"' packages/*.nix` 是本仓的完整答案——
目前只有 `dsh-api-balance.nix` 一处。

### 为什么本仓的子仓链必然是单层

`dsh-api-balance` 是 **DSH 插件**，它的上游发布就是它自己（无更上游的同账户
子仓）。故本仓的链式检查实际为「1 层、1 个节点」，回环与深度上限都不会触发
——但**前提校验仍要跑**（见通用技能第 9 步），因为「目前只有一层」是现状而非
结构保证，将来新增子仓时判据必须自动成立。

### 子仓特有的注意点

- **子仓不是 nix flake**：`dsh-api-balance` 无 `flake.nix`，**不要**对它跑
  `nix flake check` 或 flake.lock 处置；按 npm 包处理（改 `package.json`
  的 `version`、必要时 `npm install` 刷新 `package-lock.json`）。
- **子仓有自己的四语文档体系**：与该子仓的 README 一样遵循 zh → en → ja → pcn。
  子仓条目写在其 `MAINTENANCE.md` + `docs/MAINTENANCE.{en,ja,pcn}.md`。
- **两个 hash 都要重算**：薄封装钉住 `src` hash 与 `npmDepsHash`，改 `rev` 后
  **两者都变**——按通用技能 npm 包流程走两次 `nix build`。
- **子仓发布渠道无 npm**：该子仓**不发布到 npm**（维护者视障、无法完成
  npm 的 2FA 流程），故不存在「子仓新版本是否已上 npm」这一步。安装走
  `dsh plugin add github:Kihara777/dsh-api-balance` 或本仓薄封装。
- **该子仓的依赖是 peer 性质**：它声明 `@deepseek-ai/dsh-credentials`
  这类 `@deepseek-ai/dsh-*` 依赖，**版本低于宿主 dsh 提供的版本是正常状态**
  （运行时从宿主树解析）。判据是「子仓要求是否**高于**宿主提供」，
  不是「两侧是否相等」——详见通用技能「依赖冲突检测」的 ⚠️ 说明。
  本仓薄封装为此使用 `npmFlags = [ "--legacy-peer-deps" ]`。

### 本仓薄封装的历史坐标（写条目时对照）

| 时间 | 薄封装 `rev` | 子仓 `version` |
|---|---|---|
| 迁出时 | `c47f857ccbd7ccefcce4d88c2e1c9a7d67c4b810` | `0.1.0` |

> 该子仓迁出后已有**仅文档**的提交（`6e05c2b` 说明暂不提供 npm 打包并移除
> npm 配置、`5d95480` 移除主 README 的「文档」章节），**版本号未变**。
> 按通用技能「子仓何时需要在主仓侧跟进」的判据，这类变更**不触发薄封装重钉**。

## 泛化义务

按 AGENTS.md「泛化与技能更新」要求：修复后总结业务逻辑、评估是否存在硬编码
内容可泛化，**若发现通用性改进，更新回 `nix-flake-update-check`**，
并保持本适配层只承载 NixKits 特有内容。
