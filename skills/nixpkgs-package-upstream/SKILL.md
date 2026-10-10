---
name: nixpkgs-package-upstream
description: 把一个自建软件包提交到上游 nixpkgs——先评估可行性（是否已在 master、是否有人开着在途 PR、许可依据能不能在**那个 tag 里**指认、有没有维护意愿、依赖会不会与 nixpkgs 共用包集冲突），再审计当前要求（by-name 结构 + nixpkgs-vet 的 12 条检查与 3 条棘轮、meta 必填项、nixfmt、commit 前缀驱动 CI），然后对着**一棵真的 nixpkgs 树**做 dry-run（构建成功不算数，要跑产物），最后才 fork 提 PR。含 AI 贡献政策（Assisted-by trailer）、许可缺口、文档漂移、以及对符号链接树用递归 chmod 会打到 nix store 的陷阱。仓库特有的文档与日志环节经「仓库适配层」注入。
---

# 把软件包提交到上游 nixpkgs（通用）

把仓库里自己打的包变成 nixpkgs 的一部分。

本技能只包含**与仓库无关**的通用方法。仓库特有的环节（多语文档同步、维护日志、
自检登记等）由**仓库适配层**提供——见文末。

**顺序不能换**：评估 → 审计 → dry-run → 实操。跳步的代价在最后一节。

---

## 第 0 步：先同步，再采信

**任何「现在的 nixpkgs 是什么样」的结论，都要现取。**

```bash
gh api repos/NixOS/nixpkgs/commits --jq '.[0].sha'   # 取 HEAD，写进你的报告
```

> 走过的坑：本地那份 nixpkgs 快照的 `CONTRIBUTING.md` 里**没有** AI 政策一节，
> 而 upstream master 里**有**。凭快照下结论就会漏掉整条最关键的硬要求。
> **文档结构会漂移**——`doc/contributing/` 目录现在已不存在，
> 只剩一个跳转存根 `doc/contributing.md`。路径必须实测，不能凭记忆。

同时把基线写进报告：**哪一刻、哪个 commit**。这决定了你的结论什么时候过期。

---

## 第 1 步：评估可行性（每个包一条，逐条给证据）

六问，任一答「否」就先别做：

**① 它已经在 nixpkgs 里了吗？**

```bash
gh api "repos/NixOS/nixpkgs/contents/pkgs/by-name/${shard}/${name}/package.nix?ref=master"
# 404 = 不在。200 = 在，那就只能提 update，不能提 init。
```

`shard` = 包名前两个字符的小写。**别只查这一条路径**——
包也可能在类别目录里（`pkgs/<类别>/<包名>/default.nix`）。
再用属性名求值一次最稳：

```bash
nix eval --raw "path:<nixpkgs>#${name}.name"   # 报 NOT-A-PACKAGE 就是没有
```

**② 曾经进过 nixpkgs、后来被删了吗？**

```bash
gh api -X GET search/commits -f q="repo:NixOS/nixpkgs ${name}" --jq .total_count
gh api -X GET search/issues  -f q="repo:NixOS/nixpkgs ${name}" --jq .total_count
```

被删过的要**先找删除理由**（通常 `包名: remove`），理由可能就是现在仍然成立的理由。
搜索全 0 也不能反过来说「绝不存在过」——
**证据为负不是证明**，要在报告里把这个区别写清楚。

> 走过的坑：一个包定义里的注释写着「nixpkgs 已不再提供它」，
> 而九条独立取证全是 0。真实来源是**我们自己仓库的 CI workflow** 记混了。
> **仓库里的自述会过期**，它不是证据。

**③ 有在途 PR 吗？** 这一条最容易白干。

```bash
gh api -X GET search/issues -f q="repo:NixOS/nixpkgs is:pr ${name}" --jq '.total_count, .items[].title'
```

**要按「上游项目名」而不是「我们的包名」搜。** 同一个软件的包名可能是别的写法——
见过的实例：我们叫 `dsh`，nixpkgs 里三个在途 PR 都叫 `deepseek-harness`。

**④ 许可能指认吗？——必须是那个 tag 里的文件**

这是最容易被跳过、也最容易被审阅者当场卡住的一条。

**要检查的是「我们实际取源的那个 tag/rev」里有没有许可文件，不是仓库的 main 分支。**

> 走过的坑：某个包的 `main` 上有 LICENSE（最近才加的），
> 而我们取源的 tag 比那次提交早十八天——**tag 里没有许可文件**。
> 唯一的依据是 add-on 清单里的一行 SPDX 和 main 上那份文件。
> 这类缺口要么先向上游要（给旧 tag 补许可文件 / 等新 tag），要么在 `package.nix`
> 里把依据写清楚。**装没看见是最坏的选项。**

顺带核许可类型：nixpkgs 的 `lib.licenses` 只收自由许可；
`unfree` 进不了 channel，`unfreeRedistributable` 可再分发但不能改二进制。

**⑤ 有维护意愿吗？**

新包会被问：「你愿意维护它吗，至少一个完整的 Nixpkgs 发布周期？」
（原文：one complete Nixpkgs release life-cycle）

这不是客套。**在 `maintainer-list.nix` 里写下自己的 handle，就是接受这个承诺。**

**⑥ 依赖会不会与 nixpkgs 共用包集冲突？**

这是最硬的一条技术门槛，也是最容易被忽略的：

- 如果包对某个依赖**锁死精确版本**（运行期 fail-closed 校验那种），
  而 nixpkgs 里那个依赖是**全仓共用**的一份——**冲突无法调和**。
  抬版本会牵动整个仓库，审阅者不会为了一个包动它。
- Python 包集、Node 包集、Qt 包集都是共用的。
- 依赖**已经在 nixpkgs 里**且版本满足约束的，是最好的情况：第一个 PR 不需要连带任何东西。

顺手核上游健康度（活跃度、issue 响应、有没有归档）：
「太不成熟」和「马上要被放弃」的项目，nixpkgs 的 Quick Start 明说不收。

---

## 第 2 步：审计当前要求

### 2.1 文件放哪

```
pkgs/by-name/<两字母小写前缀>/<包名>/package.nix
```

**不需要改 `all-packages.nix`**。补丁文件**直接放包目录里**，不需要 `patches/` 子目录。

`nixpkgs-vet` 在 CI 里强制 12 条检查
（出处：<https://github.com/NixOS/nixpkgs-vet/blob/master/README.md#validity-checks>）。
其中三条是**棘轮（ratchet，只禁新增）**，新包必须满足：

- 用 `pkgs.callPackage` 的新顶层包**必须**走 package directory，进去就不能搬回类别目录；
- 新顶层包必须 `strictDeps = true`，且不能回退成 `false`；
- 新顶层包必须 `__structuredAttrs = true`，且不能回退成 `false`。

其余要记住的：

- `name` 只能用 ASCII `a-z A-Z 0-9 - _`，**不能以数字或 `-` 开头**；
- `shard` 必须是 `toLower (substring 0 2 name)`；
- 每个包目录必须有 `package.nix`；
- **包目录不得引用自身目录之外的文件**（symlink 或 Nix 路径表达式都不行）——
  这条把「多版本包共享文件」挡在门外；
- 求值结果必须是**一个 derivation**（`lib.isDerivation` 为 true），不能是包的集合。

by-name 的两条限制：只收 `pkgs.callPackage` 风格的包（**排除** `python3Packages.callPackage` 那种写法）、
只收顶层包。

> 注意一个常见误解：**用 `python3Packages.buildPythonApplication` 是可以放 by-name 的**。
> nixpkgs 里有大量这样的包（例如 `pkgs/by-name/in/input-remapper/package.nix`）。
> 被排除的是「用 `python3Packages.callPackage` 去调用」，不是「用了 python 的 builder」。

不满足 by-name 时退回类别目录（`pkgs/<类别>/<包名>/default.nix` + `all-packages.nix`），
但类别目录是**部分弃用、会逐步迁走**的，优先级更低。

### 2.2 meta 必填项

| 项 | 要求 |
|---|---|
| `description` | 一句话、首字母大写、不以冠词开头、**不以包名开头**、**不以句点结尾**、陈述事实 |
| `license` | **必须**设置，且与上游一致；无上游许可时默认 `unfree` |
| `sourceProvenance` | 非从源码构建时**必须**设置（重打包 `.deb`/`.rpm`/`.whl`/AppImage → `binaryNativeCode`） |
| `mainProgram` | 主可执行文件名（**硬编码字符串**，别用 `pname`）；多个且无主次时不设 |
| `maintainers` | **新包必须设置** |

`meta` 属性集**放在 derivation 最后**，`passthru` 之类的写在它前面。

`meta.platforms` 在文档之间措辞不一致（必填清单里没有它，但评审检查表说 should set）——
**按要设来准备**，不确定就问 committer。

### 2.3 取源与 hash

- **总是**用 nixpkgs 的 fetcher，`sha256`（SRI 格式）；
- 从 GitHub 取源**必须用完整 commit hash**（短 hash 会被解析成别的）；
- 自带 forge（Gitea / Forgejo）：`fetchFromGitea` 要写 `domain`，
  字段名是 **`tag`** 而不是 `rev`；
- **能远程取的补丁不要 vendored**（用 `fetchpatch2` / `fetchpatch`）；
- npm 包用 `fetchNpmDeps` / `importNpmLock` 一类固定依赖，**构建期不得联网**。

### 2.4 commit 与 CI

格式 `包名: init at 版本`。**冒号前缀不是风格问题——它决定 CI 会不会自动构建这个包。**

- 摘要行末尾**不加句点**；
- 每个逻辑单元一个 commit；
- 加维护者身份**必须单独一个 commit**，标题固定 `maintainers: add <handle>`，
  且**排在包那个 commit 之前**；
- 条目必填 `name` / `github` / `githubId`，`github` 与 `githubId` 要能对上
  （审阅者会访问 `https://api.github.com/user/<githubId>` 核 `login`）；
- **不需要 `--signoff`，nixpkgs 没有 DCO**；
- **不需要先开 issue**——package request 模板的原文就是
  「Package requests are no longer accepted. Please open a Pull Request with your desired package instead.」；
- 所有 Nix 文件必须过 **nixfmt**（RFC 166），CI 由 treefmt job 强制。

### 2.5 AI 贡献政策（先读这条，再决定怎么分工）

出处：nixpkgs `CONTRIBUTING.md` 的 `#automationai-policy` 一节。

要点：

- 每份贡献**必须有一位在环里、对内容负责的人**，在提交前审阅它；
- LLM 产出**不能只靠信任工具本身**——只允许「人工审阅产物」或「用另一个工具验证产物」。
  原文：**vibe coding without review is not permitted**；
- 披露**必须**写成 commit trailer：`Assisted-by: <工具名> <模型名与版本>`。
  **`Co-authored-by:` 不算披露**；
- PR 摘要与评审评论要**各自单独披露**，不能只写在 commit 里；
- 贡献者要**能自己回答关于这份贡献的问题**，不能把评审意见来回转发给工具；
- 例外：AI 用在**被打包的上游软件本身**不在范围内；
  用在研究、测试、调试、私有审阅也范围外（有实质技术影响时仍要负责）。

**执行是人工的，CI 里没有 AI trailer 校验**——没有机器看着这条，所以它靠我们守。
提议时就把合规形态做出来：commit trailer 写全，PR 摘要里独立写一段披露。

---

## 第 3 步：Dry-run（不动 GitHub）

### 3.1 怎么对着一棵真的 nixpkgs 树构建

**不要复制 nixpkgs 树**，更不要对它递归 `chmod`（见第六节）。
直接让 Nix 用 flake 语法读它：

```bash
# 先确认那棵树能当 flake 用
nix eval --raw "path:<nixpkgs-path>#hello.name"
```

然后在一个临时目录里写包文件与一个求值入口：

```nix
# /tmp/draft/build.nix
let
  pkgs = import (builtins.getFlake "path:<nixpkgs-path>") { system = "x86_64-linux"; };
in
pkgs.callPackage /tmp/draft/package.nix { }
```

```bash
nix eval  --impure --raw --expr '(import /tmp/draft/build.nix).drvPath'   # 先只求值
nix build --impure --no-link --print-build-logs --expr 'import /tmp/draft/build.nix'
```

**好处**：nixpkgs 树只读，`/tmp` 里是想改就改的草稿路径，出不来 `chmod` 事故。

### 3.2 判据（四层，缺一层都可能是假绿）

1. **求值通过** —— 依赖都能在 nixpkgs 里解析到；
2. **构建通过** —— 退出码 0；
3. **产物对** —— 核验 `$out/bin/` 里有该有的可执行文件、`$out/share/` 里有该有的数据文件；
4. **产物能跑** —— **真的敲一下它**。

第 4 层最关键。构建成功只说「编译过了」，不说「能用」——
历史上验过：某个包的 CI 长期靠缓存「成功」，日志里一行构建都没有，
而它一旦真去构建又会一构建就崩。

第 4 层怎么做取决于包的类型，思路是**喂一个最小的真请求**：

- CLI：`--version` / `--help`，最好再跑一次真实子命令；
- MCP / RPC 服务：喂一条最小的协议帧（例如 JSON-RPC `initialize`），看回包；
- 库：`pythonImportsCheck` / 写个最小调用方。

### 3.3 格式与结构

```bash
nix run <nixpkgs-path>#nixfmt -- --check /tmp/draft/package.nix   # 退出码 0 = 已符合
```

by-name 的结构检查要**人肉对照**第 2.1 节那 12 条
（本地跑 `./ci/nixpkgs-vet.sh master` 需要完整 nixpkgs 仓与 base 分支，草稿阶段不划算）。

### 3.4 把 dry-run 产物留在仓库里

dry-run 的 `package.nix`、PR 摘要草案、披露文本要**进版本库**，
这样它们可复核、也能被自检盯住。留在 `/tmp` 里等于没有。

---

## 第 4 步：实操

0. **先确认身份与账号**：`gh auth status`，看当前活跃账号是不是要用的那个。
   nixpkgs 上的 author/committer 的 name 与 email 必须有效（CI 会校验）。
1. Fork + 建分支（分支名提示改动内容即可），基于 `master`：
   ```bash
   git fetch upstream
   git switch --create init-<包名> upstream/master
   ```
2. 两个 commit，**顺序不能反**：
   - `maintainers: add <handle>`（改 `maintainers/maintainer-list.nix`）
   - `<包名>: init at <版本>`（加 `pkgs/by-name/<shard>/<包名>/package.nix`）
   两个 commit 都带 `Assisted-by: <工具> <模型版本>` trailer。
3. `git push --set-upstream origin HEAD`，按模板开 PR。
4. **等**。原文：「It is entirely normal for your PR to sit around without any feedback
   for days, weeks or sometimes even months.」
   加速手段：勾满模板、打全标签、先拿到非 committer 的 review、**至少一周**无活动后再去
   Discourse 的 review-requests 帖或 Matrix 频道。

**谁按提交按钮、谁答评审**：按 AI 政策，答评审的是那位「在环里负责的人」。
工具不能代答——把评审意见转发给工具再转回去，是政策明说不允许的。

---

## 第五步之后：跟踪与维护

- `passthru.updateScript = nix-update-script { };` **不是硬性要求**，
  但设了能让 `r-ryantm` 更可靠地跟新。近期合并的同类包（`mcp-searxng`、`godot-mcp`）
  都没写它，照样被自动跟新（一个月四次）。
- **不存在 `meta.dontUpdate` 这个标记**——想让 r-ryantm 跳过，靠的是不设 updateScript。
- 合并后，你就是维护者：上游发版要跟。

---

## 第六节：陷阱清单

**① 对符号链接树用递归 chmod，会打到 nix store。**

为了「让副本可写」而 `chmod -R u+w <副本>`——如果副本里是**指向别处的符号链接**，
`-R` 会顺着链接一路 chmod 到 `/nix/store` 里的**真实目录**。

实测后果与出口：内容哈希未变（`nix-store --verify-path` 退出码 0），
存储目录权限能回到只读，临时树能清干净——**但这是运气，不是设计**。
入口做法：**根本不要改权限**（用第 3.1 节的 `builtins.getFlake "path:…"`）；
真要复制，先确认树里没有外指链接。

**② 许可要看「我们取源的那个 tag」，不是仓库的 main。**
main 上新加的 LICENSE 可能比 tag 晚。**证据必须在被取的那份源码里。**

**③ 仓库里关于 nixpkgs 的自述会过期。**
「nixpkgs 已经不再提供 X」「上游删掉了 Y」这类句子，**先取证再采信**。
本仓自己写过的错误结论就有先例。

**④ 同一个软件在不同仓库可能叫不同名字。**
按**上游项目名**搜在途 PR，不要只按我们自己的包名搜。

**⑤ 文档漂移是常态。**
`CONTRIBUTING.md` 里描述的 PR 模板勾选项与 `.github/PULL_REQUEST_TEMPLATE.md`
实际内容已经不一致；`doc/contributing/` 目录已不存在。
**以源文件实测为准**，不要以记忆或二手描述为准。

**⑥ 构建成功不等于产物能跑**，也不等于「nixpkgs 会收」。
四层判据见 3.2。

**⑦ 预编译二进制不是绝对禁止，但位置不利。**
nixpkgs 的立场是「Source-available software should be built from source where possible」。
二进制包要走 `autoPatchelfHook` + `sourceProvenance = [ binaryNativeCode ]` 这条路，
而且**任何关掉内核加固的东西**（例如改写 `prctl(PR_SET_NO_NEW_PRIVS)` 的拦截器）
不可能过安全评审。

**⑧ 「依赖钉死精确版本」的包不要往 nixpkgs 提。**
nixpkgs 里所有包共用一份语言包集，抬一个版本会牵动全仓。

---

## 仓库适配层

本技能只含通用方法。仓库特有的环节由适配层提供：

- 多语文档同步（新增内容先写基准语言，再翻译；各语言条目数要相等）、
- 维护日志（推送后必须补录，且多语同步）、
- 把新技能登记进仓库自检与文档索引、
- 各类 `check-*.py` 自检的射程。

NixKits 的适配层见 `skills/nixkits-package-upstream/`。
