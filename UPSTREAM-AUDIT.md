# 上游贡献可行性评估 — 向 nixpkgs 提交新包

_评估日期：2026-10-10 · 评估对象：NixKits 的 13 个包 · 结论分级：推荐 / 可做 / 需评估 / 不推荐_

**取证基线**：nixpkgs master 实测于 `2026-10-10T03:06:23Z`，HEAD `78f093ad1`。
本地另有一份 nixpkgs 树可用于构建（`26.11pre20260908.422d1ae`）。
凡标「未核实」的，都不许当成结论读。

---

## 一、结论（先看这段）

**可行。** nixpkgs 已明文接受 AI 辅助的贡献，但有硬性条件——
必须有一位**在环里负责的人**先审阅并理解贡献，且必须**显式披露**。

技术上最干净、该第一个上的是 `blender-mcp`：
已对着真实的 nixpkgs 树**完整构建成功并跑通 MCP 握手**（见第四节）。
但它有一个**必须先解决的许可缺口**（见第二节），我把它列为第一件事。

**不要碰的四个**：`mcp-searxng`（**已经在 nixpkgs 里**）、
`dsh`（已有 3 个在途 PR，且我们用的是 npm 制品）、
`godot-ai`（钉死 14 个精确运行时版本）、`codewhale`（主发行是预编译二进制）。

---

## 二、逐包评估

| 包 | 在 nixpkgs 里 | 结论 |
|---|---|---|
| blender-mcp | 没有 | **推荐**，先修许可缺口 |
| obs-bilibili-stream | 没有 | 可做 |
| opencode-telegram | 没有 | 可做，但要先重做 riscv64 部分 |
| ruyi | 没有 | 需评估，补丁要先修 |
| kitsfmt | 没有 | 暂缓，缺公开上游仓 |
| codewhale | 没有 | 不推荐（二进制） |
| godot-ai | 没有 | 不推荐（依赖钉死） |
| dsh | 没有 | **停止**（已有 3 个在途 PR） |
| mcp-searxng | **已在** | 不提交新包 |

### blender-mcp —— 推荐，但先修许可

上游是 Blender 官方的 `lab/blender_mcp`，v1.0.3 发布于 2026-09-11。
它需要的三个 Python 依赖 —— `mcp`、`docutils`、`pyyaml` —— nixpkgs 里全都有，
所以**第一个 PR 不需要连带任何依赖包**。

⚠️ **许可缺口（实测）**：`v1.0.3` 这个 tag 里**没有 LICENSE 文件**
（`contents/LICENSE?ref=v1.0.3` → 404），根 `readme.md` 与 `mcp/README.md` 也都不提许可。
GPL-3.0 的 LICENSE 是**后来**才加进 `main` 的（提交 `dbbf836ad`，2026-09-29，
"Include GPL3+ license"）——**晚于 v1.0.3 十八天**。

也就是说：我们能拿到的许可依据只有两处，都不在那个 tag 里——
add-on 的 `blender_manifest.toml` 写着 `SPDX:GPL-3.0-or-later`，
以及 `main` 上那份 35147 字节的 LICENSE。

nixpkgs 要求 `meta.license` **与上游一致**，审阅者看到 tag 里没有许可文件会问。
三条路：等下一个 tag（会带上 LICENSE）、**先向上游开 issue 要求给 v1.0.3 补许可文件**、
或者就用 v1.0.3 + 在 `package.nix` 注释里写清算依据。我倾向第二条——
它比提交一个包更能说明我们真的在帮上游。

### obs-bilibili-stream —— 可做

GPL-2.0，上游 563 星、2026-10-09 还有提交，构建是普通 cmake。

但 nixpkgs 里 OBS 插件有**自己的构建助手**（`buildPlugins`）。
现在的写法是手写 `cmakeFlags` + 手工 `rm -rf "$out/obs-plugins"`，
提交前要先按 nixpkgs 的既有插件形态改写，否则审阅者第一轮就会要求重做。

### opencode-telegram —— 可做，但要先重做

MIT，1240 星，2026-10-03 刚发版。

障碍在 riscv64：包里有 100 多行注释与逻辑专门处理交叉编译
（`gcc` shim、`better-sqlite3` 的 `--force_build=1`）。
nixpkgs 的 npm 包用 `fetchNpmDeps` 固定依赖、且不欢迎这种针对单一架构的构建期补丁。
可行路径：先把 riscv64 那段**摘掉**提交（只声明 x86_64 / aarch64），
`meta.platforms` 写清楚就合规。

### ruyi —— 需评估，先修补丁

Apache-2.0，上游 38 星、2026-09-25 有提交、CI 齐全。

**一处需要更正的过期自述**：`packages/ruyi/ruyi.nix` 的注释写着
「nixpkgs 已不再提供 ruyi 包」。取证结论是相反方向——
**nixpkgs 里从未有过 ruyi**：by-name 的 `ru/` 分片里没有（相邻的 `ruri`/`rura`/`rure` 都在）、
commit 搜索 0 条、issue/PR 搜索 0 条、Discourse 搜索 0 条。
最可能的记忆来源是**本仓自己**（一整套 `build-ruyi-*.yml`）或第三方 `NickCao/ruyi-ng`。

真正的障碍是补丁：`patches/ruyi-nixos-compat.patch` 有 426 行，
而且 `postPatch` 里**现场生成 Python 代码**（往 `nixos_compat.py` 追加函数、
用一个临时脚本改 `maker.py`）。nixpkgs 不收生成式补丁。
必须先把这些整理成静态补丁文件，最好**先提给上游 ruyisdk/ruyi**。

### kitsfmt —— 暂缓

`meta.homepage` 指向 NixKits 自己，而 `github.com/Kihara777/kitsfmt` 返回 **404**。
nixpkgs 要求包有可指认的、活跃的**上游**。
先给 kitsfmt 建独立仓库、发布版本与 tag，再谈上游。

### codewhale —— 不推荐

MIT、41075 星（两条独立路径核验一致）、2026-10-10 还有提交，
从「有没有人用」看是候选里最强的。

但它**主发行是 GitHub Release 的预编译二进制**，而 nixpkgs 明确写着
「Source-available software should be built from source where possible.
Binary blobs risk supply chain attacks and vendored outdated libraries」。
而且包里挂着一个 218 行的 ptrace 拦截器，专门改写
`prctl(PR_SET_NO_NEW_PRIVS)` / `prctl(PR_SET_SECCOMP)` —— 那是**关掉内核加固**。

补充一点准确事实：那个拦截器**只在 `allowSudo = true` 时编译进包**，
nixpkgs 形态下必然是 `false`，所以它不是「nixpkgs 会收到的代码」——
但它说明了这个包的用途方向，审阅者会问。

理论上可以只提交源码构建那份（`codewhale-src.nix`，带 `cargoLock`），
但要接受「只声明源码构建能覆盖的架构」，且要先验证它真的能建、能跑。

### godot-ai —— 不推荐

它启动时会**逐项比对 14 个运行时依赖的精确版本**，任一不符就拒绝启动。
为满足它，本仓要挂两个 overlay 去抬 fastmcp / mcp / pydantic / uvicorn / starlette 的版本。
nixpkgs 里**所有包共用一份 python 包集**——把 pydantic 抬版本会牵动整个仓库。
这条与 nixpkgs 的架构直接冲突，不是写得好不好的问题。

### dsh（含 dsh-alpha）—— 停止，不要提交

nixpkgs 里已经有 **3 个在途 PR** 在加它，而且用的是**另一个包名**：

- [#552467](https://github.com/NixOS/nixpkgs/pull/552467) `deepseek-harness: init at 0.1.0-rc.5`
- [#553134](https://github.com/NixOS/nixpkgs/pull/553134) `deepseek-harness: init at 0.1.0-rc.6`
- [#554081](https://github.com/NixOS/nixpkgs/pull/554081) `deepseek-harness: init at 0.1.6-alpha.1`（草稿）

三个都是 2026 年 8 月开的，至今未合并。再开第四个是重复劳动。
而且我们这份是**从 npm 制品打的**（`fetchurl` 取 registry 的 tgz），还要 `sed` 改包内文件，
两件都是 nixpkgs 不欢迎的。要做就该去参加 #552467 那条**源码 + `fetchPnpmDeps`** 路线。

### mcp-searxng —— 不提交

**它已经在 nixpkgs master 上**（`pkgs/by-name/mc/mcp-searxng/package.nix`），
initial PR [#557725](https://github.com/NixOS/nixpkgs/pull/557725) 已于 2026-09-03 合并。
而且已经有人开着 2.5.0 → 2.5.1 的更新 PR
（[#570892](https://github.com/NixOS/nixpkgs/pull/570892)）。提新包会被直接关掉。

---

## 三、nixpkgs 的入场要求（审计结果）

以下每条都出自 nixpkgs 自己的文档或 CI 实现，不是猜测。

### 文件放哪

```
pkgs/by-name/<两字母小写前缀>/<包名>/package.nix
```

前缀必须是包名前两个字符的小写。**不需要改 `all-packages.nix`**。

`nixpkgs-vet` 在 CI 里强制 12 条检查，其中三条是**棘轮（ratchet，只禁新增）**：

- 用 `pkgs.callPackage` 的新顶层包**必须**走 package directory，进去就不能搬回类别目录；
- 新顶层包必须 `strictDeps = true`，且不能回退成 `false`；
- 新顶层包必须 `__structuredAttrs = true`，且不能回退成 `false`。

还有一条约束容易踩：**包目录不得引用自身目录之外的文件**（symlink 或 Nix 路径表达式都不行）。
这条把「多版本包共享文件」挡在门外。

by-name 另外两条限制：只收 `pkgs.callPackage` 风格的包（排除 `python3Packages.callPackage` 那种写法），
只收顶层包。补丁文件可以**直接放包目录里**，不需要 `patches/` 子目录。

### commit 怎么写

格式是 `包名: init at 版本`。冒号前缀不是风格问题——**它决定 CI 会不会自动构建这个包**。

要给自己加维护者身份时，**必须单独一个 commit**，标题固定为 `maintainers: add <handle>`，
并且**排在包的那个 commit 之前**。
条目必填 `name` / `github` / `githubId` 三项，`github` 与 `githubId` 要能对上。

摘要行末尾**不加句点**。**不需要 `--signoff`，nixpkgs 没有 DCO**
（三份文档全文检索 `sign-off|DCO|Developer Certificate` 零命中，CI 的 commit 检查里也没有）。

### 不需要开 issue

`.github/ISSUE_TEMPLATE/10_package_request.yml` 的原文是
「Package requests are no longer accepted. Please open a Pull Request with your desired package instead.」
该模板带 `auto-close` 标签。**直接开 PR。**

### CI 强制什么

**所有 Nix 文件必须通过官方格式化器 nixfmt**（RFC 166，`.github/workflows/lint.yml` 的 treefmt job）。
本机可用 `nix run <nixpkgs>#nixfmt -- --check <文件>`，已验证可用。

`lint.yml` 四个 job：`treefmt`、`parse`、`nixpkgs-vet`、`commits`。
构建由 ofBorg 触发（**不在 workflow 里**，按 commit title 的包名前缀决定构建哪些包）。
PR 模板还要勾选：在哪些平台真的构建过、有没有跑 `nixpkgs-review`、
有没有真的敲过 `./result/bin/` 里的二进制。

### AI 政策（本次评估里最关键的一条）

nixpkgs 的 `CONTRIBUTING.md` 里有一节 `Automation/AI policy`
（[#514587](https://github.com/NixOS/nixpkgs/pull/514587)，2026-05-18 合并）。
**本地那份 9 月快照里还没有这一节。**

原文要点：

- 每份贡献都**必须有一位在环里、对内容负责的人**，在提交前审阅它。
- LLM 的产出**不能只靠信任工具本身**——因为 LLM 的内部逻辑目前无法被充分理解，
  只允许「人工审阅产物」或「用另一个工具去验证产物」。**vibe coding without review is not permitted.**
- 披露**必须**写成 commit trailer：`Assisted-by: <工具名> <模型名与版本>`。
  `Co-authored-by:` **不算**披露。
- PR 摘要与评审评论要**各自单独披露**，不能只写在 commit 里。
- 贡献者要**能自己回答关于这份贡献的问题**，不能把评审意见来回转发给工具。
- 例外：把 AI 用在**被打包的上游软件本身**不在范围内（我们的 `skills/` 就是这种）；
  用在**研究、测试、调试、私有审阅**也在范围外——但如果它对贡献有实质技术影响，仍要负责。

**执行方式是人工的，不是机械的**：CI 的 commit 检查实现里**没有** AI trailer 校验。
这一点值得记住——**没有机器在看着这条政策，所以它靠我们自己守。**

**对我们的含义**：这条政策不是禁止，但把分工写死了——
狐莉是那个「在环里负责的人」，我负责产出、自查与披露文本。
我**不能**替她回答审阅者的提问，也不能代她按下提交按钮。

**相邻事实**：`NixOS/nix`（Nix 程序本身）有更严的一版，多一条
「Human communication must remain human」——PR/issue 描述、评论、文档、commit message、
代码注释都必须由人撰写。**那条更严的规则不适用于 nixpkgs，但适用于 Nix 本体。**

---

## 四、Dry-run：blender-mcp

不是纸面推演。用一份**真实的 nixpkgs 树**（26.11pre）做的：

1. 按 nixpkgs 规范写了 `package.nix`（`python3Packages.buildPythonApplication` +
   `sourceRoot = "${src.name}/mcp"` + `mcp[cli]` 的 extras，
   并按棘轮要求设 `strictDeps = true` 与 `__structuredAttrs = true`）。
2. `nix build --expr 'pkgs.callPackage …'` → **退出码 0**，无编译告警。
3. `nixfmt --check` → **退出码 0**（已符合 nixpkgs 强制格式）。
4. 核验产物本身：`$out/bin/blender-mcp` 存在；add-on 的 9 个文件落在
   `$out/share/blender/scripts/addons/blender_mcp_addon/`。
5. **真的跑了它**：喂一条 JSON-RPC `initialize`，拿回完整应答——
   `serverInfo.name = "blender-mcp"`，并列出 prompts / resources / tools 三组能力。

第 5 步是关键：**构建成功不等于能跑**，而它跑了。

还没做的：把上游 `tests/` 接进 `doCheck`；
许可缺口（第二节）；维护者条目（`githubId` = 24633616）。

---

## 五、本次评估自身的教训

做 dry-run 时我用 `chmod -R u+w` 处理一棵**满是符号链接**的 nixpkgs 副本，
它顺着链接**改到了 nix store 里的真实目录**。

已核验修复：`nix-store --verify-path` 退出码 0（内容哈希未变），
存储目录权限已回到只读，临时树已清干净。

教训：**对符号链接树用递归 chmod，射程会跑到你想不到的地方。**
要改权限就先确保那棵树里没有指向别处的链接，或者根本不要改权限。
