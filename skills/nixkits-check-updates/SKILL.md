---
name: nixkits-check-updates
description: NixKits 仓库的软件包更新适配层——在通用技能 nix-flake-update-check 之上，补充本仓库特有的四语文档同步、dsh 内置插件清单同步、同账户子仓（dsh-api-balance）的链式检查坐标、维护日志记录、历史事故教训（comfyui 漂移、codewhale-riscv64 CI 失败），以及收尾的流程复盘与规范校验（AGENTS.md / SECURITY.md 等）。
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

**实测复现（0.9.12 → 0.9.13）**：本地 lock 7073 行、上游 7347 行，上游新增
`wl-clipboard-rs` / `jobserver` 等依赖。**从上游 tag 直接取 lock 覆盖**即可：

```bash
gh api "repos/Hmbown/CodeWhale/contents/Cargo.lock?ref=v<version>" \
  --jq '.content' | base64 -d > packages/codewhale-src-Cargo.lock
```

> ⚠️ `codewhale-src` **不是 flake 输出**（`flake.nix` 只在 riscv64 条件下经
> `codewhale` 引用它），故 `nix build .#codewhale-src` 会报
> `does not provide attribute`。取 hash 时用：

```bash
nix build --impure --no-link --expr '
let f = builtins.getFlake (toString ./.);
    pkgs = f.inputs.nixpkgs.legacyPackages.x86_64-linux;
in pkgs.callPackage ./packages/codewhale-src.nix { }'
```

#### ⚠️ codewhale 有**两个变体同名同输出**，升级必须两个都改

这是本仓最容易漏的一处——`flake.nix` 按架构分流，**两个文件都产出
`codewhale`**：

| 变体 | 适用架构 | 源 | 需改的字段 |
|---|---|---|---|
| `packages/codewhale.nix` | x86_64 / aarch64 | GitHub Releases 预编译二进制 | `version` + **4 个 hash**（cli/tui × x64/arm64） |
| `packages/codewhale-src.nix` | riscv64 | `fetchFromGitHub` + `Cargo.lock` | `version` + `hash` + **同步 Cargo.lock** |

```nix
codewhale = if pkgs.stdenv.hostPlatform.isRiscV
  then pkgs.callPackage ./packages/codewhale-src.nix { }   # ← riscv64
  else pkgs.callPackage ./packages/codewhale.nix { };      # ← x86_64/aarch64
```

**只改一个的症状**：本地 `nix build .#codewhale` 可能成功（取决于构建机架构），
但**部署后另一个架构上版本没变**。实测踩到：只改了 `-src` 变体，
系统上 `codewhale --version` 仍是 0.9.12。

> **核对方法**：部署后**逐个变体所在架构核对实际版本**，不要只看构建通过。
> 本机（x86_64）应验证 `codewhale.nix`；riscv64 的 CI 会验证 `-src`。
>
> 取预编译 hash：`nix store prefetch-file <url> --json`（0.9.13 实测 cli 与
> tui 资产 hash 相同，四值可两两相同，但**仍要分别填入**）。

### godot-ai v4 的 fail-closed 运行时校验（2026-09-17 实测）

godot-ai 4.x 启动时校验 9 个运行时包的精确版本，不匹配即拒绝启动。本仓用
**两个链式 overlay** 满足它（通用方法见通用技能陷阱第 5 条）：

| overlay | 作用 |
|---|---|
| `overlays/fastmcp.nix` | fastmcp 3.3.1 → 3.4.7（3.3.x 有 circular-import bug） |
| `overlays/godot-ai-v4-deps.nix` | mcp / pydantic(+core) / starlette / uvicorn / websockets 抬到上游要求 |

> ⚠️ **两处必须同步**：`flake.nix` 的 `godotPkgs` 与 `overlays/default.nix` 的
> `godot-ai` 各自链了这两个 overlay。**只改一处会导致 `nix build .#godot-ai`
> 与经 overlay 消费的结果不一致**——本次就踩到：flake.nix 只链了 fastmcp，
> 构建产物仍用旧依赖，`--version` 直接 RuntimeError。
>
> 另：`pythonRuntimeDepsCheckHook` 相关的 `dontCheckRuntimeDeps = true` 只解决
> **构建期**；**运行期**校验必须靠 overlay 真正抬版本，不能靠它绕过。


### blender-mcp 的 Gitea 取源（2026-09-17 实测）

`blender-mcp` 是**本仓唯一使用自托管 Gitea**（`projects.blender.org`）的包。
2026-09-17 升级 1.0.0 → 1.0.3 时发现：`fetchFromGitea` 生成的
`/archive/<rev>.tar.gz` 路径**对全部 tag 返回 403**，而
`/api/v1/repos/lab/blender_mcp/archive/<rev>.tar.gz` 返回 200。

**「1.0.0 还能构建」是假象**——它的 source 早在 Cachix / Nix store 里，
`nix build` 命中的是缓存，**根本没发请求**。用 `--rebuild` 才会暴露。

**本仓的处置**：改用 `fetchzip` 指向 API 端点 + `stripRoot = true`
（复现 fetchFromGitea 剥掉顶层目录的语义，使 `preConfigure = "cd mcp"` 仍成立）。
通用判据与验证方法见通用技能「非 GitHub 源」一节。

> ⚠️ 该包**有独立 workflow**（`build-blender-mcp-{x86_64,aarch64}.yml`，不在
> `check-workflows.py` 的 `EXEMPT` 登记中），故 CI 会构建它。但 **CI 同样可能
> 命中二进制缓存**——`--rebuild` 只是清本地缓存，不可靠。改完取源方式后
> **必须确认 CI 真的重新构建了**（看 workflow 日志是否有 fetch 阶段，
> 而非全部 `copying path ... from cache`）。
### dsh-alpha 的 vendored lock（2026-09-17 实测）
dsh tarball **不含** lock，需自行生成。踩到的坑：用
`npm install --package-lock-only --legacy-peer-deps` 生成的 lock **不含
`"peer": true` 条目**，构建报 `ENOTCACHED`。**去掉该 flag** 后 npm 才写入
peer 条目（与仓库既有可工作的 `dsh-package-lock.json` 结构一致，均为 24 条）。
详见通用技能 npm 节的「vendored lock 必须包含 peer 依赖条目」。

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

> 该子仓迁出后新增两个提交（`6e05c2b` 说明暂不提供 npm 打包并移除 npm 配置、
> `5d95480` 移除主 README 的「文档」章节），**版本号未变（均为 `0.1.0`）**。
> **实测变更清单**：`publish.yml` 删除、5 个 README/文档文件、`package.json`
> 仅移除 `publishConfig.access`——依赖段、`files` 白名单、`version` 均未动。
> 按通用技能「子仓何时需要在主仓侧跟进」的**字段级判据**（发布元数据不属
> 语义输入），**不触发薄封装重钉**。
>
> ⚠️ 注意不要说成「仅文档变更」——`package.json` **确实变了字节**。判据必须
> 落到**字段**而非文件：只看文件清单会把它误判为「清单文件变了 → 跟进」，
> 只看版本号则漏掉「依赖变更」这类同版本号的语义变更。

## 第 10 步（收尾）：流程复盘与规范校验

**每次更新流程全部完成后**（含文档同步与维护日志推送）执行。这一步不看软件，
看的是**决定软件被如何更新的那套规范本身**——技能、`AGENTS.md`、`SECURITY.md`
以及相关的 develop 脚本。可以理解为**对更新流程自身做一次「检查更新」**。

```
→ 第 1~9 步：更新软件
→ 第 10 步：更新「决定软件如何被更新」的规范
```

### 10.1 复盘本次流程的经验教训

回看整个流程，逐条问：**这次哪里卡住了、哪里猜错了、哪里返工了？**

| 问题 | 追问 |
|---|---|
| 哪一步**第一次做就失败**？ | 失败信息是什么？下次如何**一次做对**？ |
| 哪一步**需要问用户**才继续？ | 是信息不足（可自动化消除）还是真需决策（应固化为提问点）？ |
| 哪一步**返工**了？ | 返工的根因是流程缺失还是判断错误？ |
| 有什么**原本不知道、现在知道了**的事实？ | 它属于通用方法还是本仓特有？ |

**产出必须落到具体位置**（按 10.3 的归属判据），**不允许「知道了但没写」**
——没写下来的教训在下一次流程中等于不存在。

### 10.2 校验规范文件的内容是否仍然成立

更新流程会**改变它自己所依赖的前提**。本步校验这些描述是否已过时：

| 文件 | 校验什么 |
|---|---|
| `AGENTS.md` | 包/模块/技能的清单与数量、部署命令、构建顺序、边界规则是否仍与仓库现状一致 |
| `SECURITY.md` | 支持版本段、已知设计边界、`supported versions` 是否随版本升级而过期 |
| 本技能与 `nix-flake-update-check` | 其中的路径、命令、包名、hash 形态是否仍可用 |
| `develop/check-*.py` | 检查脚本的断言是否仍反映真实约定（如 `MAINTENANCE_DELTA`、`EXEMPT` 登记） |
| `README.md` / `docs/*/` | 版本表、插件清单、组件列表是否与升级后的实际状态一致 |
| **文档中的外部链接** | 上游是否改名/迁移/归档——**方法见通用技能「审计文档中的外部链接」**。本仓实测：`SECURITY.md` 指向子仓的 `SECURITY.md` 死链（子仓根本没建该文件）、12 处 `Asus-linux/asusctl` 失效（项目已迁至 `OpenGamingCollective/asusctl`） |

**典型失配**：升级后某包不再是「最新」、某插件的库路径变了、某条边界描述的
前提消失了。发现即修，并在维护日志中说明。

> **优先用仓库自己的检查脚本**：`develop/check-doc-links.py`、
> `develop/check-preset-derivation.py`、`develop/check-workflows.py` 等已把部分
> 约定固化为断言，跑 `nix flake check` 比人工核对更可靠。
> **但它们的覆盖面有限**——外部链接可达性、跨仓文件是否存在、`SECURITY.md`
> 描述是否属实，脚本都查不了，仍需按上表手动核。

### 10.3 归属判据：教训该写到哪一层

按**可移植性**三分，与仓库适配层的既有分工一致：

| 教训的性质 | 归属 |
|---|---|
| 任何 nix flake 仓库都会遇到（如 `npmDepsHash` 机制、上游 fail-closed 校验） | **通用技能** `nix-flake-update-check` |
| 只有本仓成立（如 codewhale 双变体、godot-ai 的双 overlay 落点） | **本适配层** |
| 是**规则/边界**而非操作步骤（如「不引入外部自动化」） | `AGENTS.md` |
| 是**安全边界**的描述 | `SECURITY.md` |

> **判据**：把这条教训搬到另一个 nix flake 仓库，还成立吗？成立就上移，
> 不成立就留在适配层。**宁可留在适配层**——过早泛化会污染通用技能。

### 10.4 用户体验：基于上下文优化流程

复盘时同时问：**这套流程让用户等了几轮？** 目标是一次流程跑完。

- **能自己查证的不要问**：先查 release notes / 上游源码 / 构建报错，把问题
  收敛到真正需要人决策的少数几项（详见通用技能「交互式澄清」）
- **能合并的步骤合并**：同类构建（如多个 npm 包）可并行推进
- **把决策点前置**：开工前一次问全，而不是边做边问
- **减少重复验证**：同一 hash 不要反复取两次
- 若某轮**确实多花了一轮往返**，在 10.1 中记录**为什么**，而不是只记结果

### 10.5 ⚠️ 实践是检验真理的唯一标准

**任何对规范的修改都必须有实事求是的正当理由和确切证据**，并满足：

| 要求 | 含义 |
|---|---|
| **可复现** | 给出能重跑出相同结论的命令或步骤，不接受「我记得」「按理说」 |
| **可追溯** | 指明证据来源（构建报错原文、上游 release notes、实测输出、具体提交） |
| **允许质疑** | 结论要能被未来的自己或他人**用证据推翻**；只写结论不写判据即不合格 |

**硬性禁止**：

- ❌ **凭印象改规范**——「感觉这样更好」「一般应该……」不是理由
- ❌ **把一次偶发当成规律**——单次失败可能是限流/网络/缓存问题，须复现或
  说明为何认定是结构性的（参见通用技能对 `403` 限流与真实失败的区分）
- ❌ **为已经写对的内容「再优化」**——规范改动也应有成本意识
- ❌ **删掉看起来没用但仍有约束力的条目**——除非能证明其前提已消失

**验证方式**：若某条判断可用命令验证，就**跑一遍并附上输出**；无法验证的
（如「用户更希望 X」）应标明这是**判断**而非事实，并说明依据。

### 10.6 产出

复盘结束后：

1. 把教训写入 10.3 判定的归属位置
2. 规范文件（含 `AGENTS.md` / `SECURITY.md`）的修正一并提交
3. 在维护日志中记录**本轮流程改进**（属「技能与文档变更」或「CI/CD 变更」类型）
4. **不要**为了记录而记录——无实质发现的流程可以只记一行「本轮无新增教训」

## 泛化义务

按 AGENTS.md「泛化与技能更新」要求：修复后总结业务逻辑、评估是否存在硬编码
内容可泛化，**若发现通用性改进，更新回 `nix-flake-update-check`**，
并保持本适配层只承载 NixKits 特有内容。

> 本节是第 10 步的一个侧面（10.3 的归属判据）——第 10 步是完整的收尾流程，
> 本节只强调「不要忘记上移通用改进」。
