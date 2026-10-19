---
name: nixpkgs-package-upstream
description: 把一个自建软件包提交到上游 nixpkgs——**先分流**（首次贡献 vs 再次贡献 × 全新添加 vs 版本更新：维护者条目是一次性的，再次贡献不再动名单；update 跳过评估与放哪两节），再评估可行性（是否已在 master、是否有人开着在途 PR、许可依据能不能在**那个 tag 里**指认、有没有维护意愿、依赖会不会与 nixpkgs 共用包集冲突），再审计当前要求（by-name 结构 + nixpkgs-vet 的 12 条检查与 3 条棘轮、meta 必填项、nixfmt、commit 前缀驱动 CI，以及**名单 handle 必须匹配 commit 作者**这条决定用哪个账号的硬约束），然后对着**一棵真的 nixpkgs 树**做 dry-run（构建成功不算数，要跑产物），**并且逐行通读要提交的那份 diff**（判据抓不到的空 maintainers、内部注释、注释语言、冗余输入、正文错数字，全在这一步），最后才 fork 提 PR（**PR 模板不得删改、fork 的 master 要先快进**）。含收到 review 后如何按『合规/规范/更正确/他的判断』四类分辨建议性质、何时可以点 apply suggestion、以及「批准 ≠ 合并」（非 by-name 的包 merge bot 管不了）、Qt 依赖者的必填项（依赖 qtbase 不声明包装意图就在 qtPreHook 阶段失败）、`__structuredAttrs` 的实测 A/B、PR 正文要短这条实测反馈（审阅者批准时附的「验证段能再短些」）、AI 贡献政策（Assisted-by trailer，commit/PR 正文/评论三层各自披露）、包该放哪的第三种去向（具名集合靠求值确认发现机制）、nixpkgs-review 的三个坑（空报告=求值失败、绿但全缓存、pr 子命令审不了 fork PR）、跨 nixpkgs 版本比产物为何不能比字节、以及自动检查假警报的处置。仓库特有的文档与日志环节经「仓库适配层」注入。
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

## 第 0.5 步：先确定走哪条路（四条，别走错）

**这一步放在评估之前** —— 因为你走的路决定了**后面哪几节根本不用读**，
也决定**这次要不要动 `maintainer-list.nix`**。

两个正交的轴：

| | **全新添加（init）** | **版本更新（update）** |
|---|---|---|
| **首次贡献**<br>（名单里还没有你） | ① 两个 commit：<br>`maintainers: add <handle>`<br>`<包名>: init at <版本>`<br>走全部评估与审计 | ② 一个 commit：<br>`<包名>: <旧> -> <新>`<br>**除非你想顺便加入名单，否则不动它** |
| **再次贡献**<br>（名单里已有你） | ③ **一个** commit：<br>`<包名>: init at <版本>`<br>名单**不要再动** | ④ **一个** commit：<br>`<包名>: <旧> -> <新>`<br>最短路径 |

### 关键：维护者条目是**一次性**的

**名单是「你是谁」的登记，不是「这次做了什么」的记录。**
一旦 `maintainers: add <handle>` 被合并，**以后每次贡献都不再碰这个文件** ——
再往列表里插一遍是重复登记，会与已合并的那条冲突。

判断方法（别靠记）：

```bash
gh api "repos/NixOS/nixpkgs/contents/maintainers/maintainer-list.nix?ref=master" \
  -H 'Accept: application/vnd.github.raw' | grep -n '^  <你的handle> = {' \
  || echo "不在名单里 → 走首次贡献"
```

### init 与 update 的差异不止 commit 标题

| | init | update |
|---|---|---|
| 可行性六问（§1） | **必做** | 跳过——包已在树上，位置由既有文件决定 |
| 放哪（§2.1） | **必做** | 跳过——文件已存在，只改里面的字段 |
| `meta` 必填项（§2.2） | **必做** | 只在顺手修 meta 时看 |
| 取源与 hash（§2.3） | 要，且要选对 fetcher | 要，但**只换 hash 与 version** |
| 维护者条目 | 首次贡献要 | **不要** |
| commit 标题 | `<包名>: init at <版本>` | `<包名>: <旧> -> <新>` |
| commit 正文 | 为什么需要这个包、特殊选择的理由 | **必须给 release notes / changelog 链接**（`pkgs/README.md` 明写） |
| CI 自动构建 | 由包名前缀驱动 | 同左 |
| 版本语义变化时 | — | **文档要重写，不是机械替换**（见姊妹技能 `nix-flake-update-check`） |

> **最常见的一种走法**：包是我们先提交上去的，之后自己跟版本。
> 那就是 **③④ 那一行** —— **一个 commit，名单不碰**，比首次贡献少一半工序。
> 别把首次那套（评估 → 审计 → 双 commit）不假思索地重放一遍。

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

**要检查的是「我们实际取源的那个 tag/rev」里有没有许可，不是仓库的 main 分支。**

> 走过的坑：某个包的 `main` 上有 LICENSE（最近才加的），
> 而我们取源的 tag 比那次提交早十八天——**tag 里没有许可文件**。

**但「没有 LICENSE 文件」不等于「没有许可」。** 先找这三处，再决定要不要向上游要：

1. **源文件头**：`# SPDX-License-Identifier: <SPDX 表达式>`。
   直接在**构建出来的产物**里 grep（`grep -rl SPDX-License-Identifier $out`），
   比读仓库可靠——它证明的是我们真正取到的那份源码。
2. **清单文件**：Python 的 `pyproject.toml`、Blender 插件的 `blender_manifest.toml`、
   Node 的 `package.json` 等，常带 `license` / SPDX 字段。
3. **上游 issue 里有没有人问过**：搜 `license`，看维护者怎么答的。
   先例：某包有人提过「仓库没有许可文件」，维护者回
   「licence is in the individual files」并随后补了 LICENSE——**那条 issue 就是最有力的依据**，
   引它比引 main 上那份后加的文件强得多，而且**说明不需要再开一条**（有人做过的事不要重复做）。

**顺序是**：先查这三处 → 证据足就照提并在 PR 里写清依据 → 不足才向上游要。
**装没看见是最坏的选项。**

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

**`__structuredAttrs` 到底改了什么 —— 实测过的 A/B**：

| | 不启用 | 启用 |
|---|---|---|
| `strictDeps` | `env` 里的**字符串** `"1"` | `structuredAttrs` 里的**布尔** `True` |
| `cmakeFlags` | **空格拼成的一个字符串** | **JSON 真数组** |
| `nativeBuildInputs` | env 里的字符串 | store 路径**列表** |
| `postInstall` 等 | env 变量 | 结构化字段 |

三条实测结论：

- **对产物没有任何影响** —— 同一个包在启用前后，`.so` **逐字节相同**
  （`4e308a2793ae…`），`config.json`、`en-US.ini` 也相同。store 路径变了、
  里面装的东西没变。**所以它是纯粹「更正确」，零附带改动。**
- **数组形态更抗错**：原来的空格拼接在「某个标志里带空格」时会裂开，
  结构化数组不会。**所以原本用 list 的 `cmakeFlags` 不需要改成字符串。**
- **`env` 只放要导出的**：属性搬进 JSON 后 `env.strictDeps`、`env.cmakeFlags`
  都不见了 —— 想让某个变量真的出现在环境里，得写进 `env`。`passAsFile` 同时被禁用。

`doc/stdenv/stdenv.chapter.md` 的原话：**"is the preferred default"**，以及
**"All new top level packages must enable `__structuredAttrs`"**。
**后半句限定「顶层包」** —— 住在具名集合里的包（`obs-studio-plugins.*`、
`python3Packages.*`）**不受 nixpkgs-vet 强制**，但审阅者仍会提
（原话通常是 "Might also try setting `__structuredAttrs`?"），因为那是全仓方向。

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

#### 2.1.1 第三种去向：包属于某个**具名集合**

by-name 与类别目录不是全部。有一类包住在**自己的属性集**里，由一份专门的
`*.nix` 组装 —— `obs-studio-plugins`、`vimPlugins`、`python3Packages` 都是。
这类包**不需要、也无处**往 `all-packages.nix` 加一行，但前提是你要**先确认那个
集合的发现机制是什么**。

**唯一可信的判据是对着一棵真的树求值：**

```bash
nix eval --impure --raw --expr '
let pkgs = import /path/to/nixpkgs { system = "x86_64-linux"; };
in if pkgs.obs-studio-plugins ? obs-bilibili-stream
   then "可达：${pkgs.obs-studio-plugins.obs-bilibili-stream.name}"
   else "不可达"'
```

**为什么非要用求值**：机制会变，而且变得很彻底。OBS 插件曾经要求在
`plugins/default.nix` 里手写一行；2026-06-26 的 commit `4a317fa67073`
（"obs-studio-plugins: migrate to packagesFromDirectoryRecursive"）**把那个文件整个删掉**
（120 行 → 8 行），换成：

```nix
# pkgs/applications/video/obs-studio/plugins.nix（全文）
{ lib, callPackage }:
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./plugins;
}
```

此后平铺的 `plugins/<名字>.nix` 自动变成属性（函数文档：
"If a regular file's name has the `.nix` extension, it is turned into attribute where
the attribute name is the file name without the `.nix` extension"），
**再没有任何可加的入口**。

> **踩过的坑（2026-10-16）**：狐莉翻到一条 2026-03 的旧 PR（#500675），它改的正是
> `plugins/default.nix` —— 从形状上看我们的提交「确实缺了入口」。但那条 PR 是
> **未合并就关闭**的，而它改的文件三个月后已被删除。**旧 PR 是可靠的历史，
> 不是可靠的现状。**
>
> 复核顺序：**别读旧 PR，读现在组装这个集合的那份文件**，然后求值确认。
> 三条独立证据一起用：① 求值可达；② `nixpkgs-review` 报 `1 package added`；
> ③ CI 的 `Eval Summary` 报 `Package: added 1` —— 后两条都要求属性存在，
> 属性不在的话它们会静默地报 0。

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
- ⚠️ **名单里的 `github` 必须等于 commit 作者的 GitHub 账号。**
  原文（`maintainers/README.md`）：

  > First, make sure that the listed GitHub handle matches the author of the commit.

  **这条决定了「用哪个账号提交」——它是硬约束，不是偏好。**
  不是先挑个账号、再往名单里填个名字；是**名单写谁，就得谁提交**。
  「想让自动化账号当联络人、又用人类账号提交」这种组合**不可能同时成立**。

  关联依据是 **`noreply` 邮箱里的数字前缀**，名字字符串随便写：

  ```bash
  # 作者行这么写，GitHub 就把 commit 关联到 Kihara777
  狐莉 <24633616+Kihara777@users.noreply.github.com>
  #                     ^^^^^^^^^ 这个数字 = api.github.com/users/Kihara777 的 id
  ```

  核验方式（推送后读回来，别只看本地）：

  ```bash
  gh api 'repos/<owner>/<repo>/commits?sha=<branch>&per_page=2' \
    --jq '.[] | "\(.commit.author.name) → GitHub: \(.author.login // "（未关联）")"'
  ```

  > **代价实测**：2026-10 的一次提交正是因为忽略了这条 —— 名单写 `Kihara777`、
  > commit 由另一个账号做，审阅者第二遍 `CHANGES_REQUESTED` 直接引用这条规则，
  > 并同时援引行为准则里「禁止用低质量贡献浪费他人时间」的条款，PR 被关闭。
  > **打包本身没问题**（审阅者原话 "The PR itself seems technically fine to me"）——
  > 死在的是这条身份规则上。
  >
  > 修法不是改包，是**换提交账号**：审阅者（K900）的结论就是
  > "please just use your personal account as a point of contact."。
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

**⚠️ 模型名写哪一个——有过一次教训**：

同一件事有三层名字，**披露要写给人看的那一层**：

| 层 | 例子 | 用途 |
|---|---|---|
| API / 配置里的 id | `deepseek-flash` | 写 DSH 配置、代码里的 `model = "…"` |
| **后端的显示名** | **`DeepSeek-V41-Flash`** | **写进 `Assisted-by:` 与披露正文** |
| 产品线名 | `DeepSeek V4 Flash` | 营销文案 |

踩过的坑：我先是**从仓库作者行抄了产品线名**（没核过），
后来改成**从系统提示词里读到的短 id** —— 两次都不是显示名。
最后是狐莉给的准。

**规矩**：披露里的名字**问一下，不要自己挑**。
三个来源（提示词、仓库文档、界面）可能给三个不同的串，而**只有一个是写给人看的**。

> 这条与第 3.5 节的逐行四问是同一族：**我写的字要经得起别人按字面读。**
> 披露的价值全在准确——写错名字的披露，比不写更难看。

**执行方式要分两层说，别合成一句「没人看」**：

- **不强制**：`ci/github-script/lint-commits.ts` 不校验 AI trailer，缺了不会让构建变红；
- **但会被认出来**：`ci/github-script/bot.ts` 里 `const assistedByPattern = /Assisted-by: (?!nix-init)/i`
  命中即打 **`llm-assisted`** 标签（实测：本仓第一个 PR 就是这样被标上的）。

**不阻断 ≠ 无人看见。** 写下「没有机器看着这条政策」是错的——机器在看，只是不拦。
提议时就把合规形态做出来：commit trailer 写全，PR 摘要里独立写一段披露。

### 2.6 自套一遍审阅者的清单（提交前）

`pkgs/README.md` 的 **New packages → Reviewed points** 是审阅者会逐条走的表。
**提交前自己先走一遍**，每条都要能指出现场证据：

| 审阅者会看 | 你要能回答 |
|---|---|
| 文件路径合不合规 | 为什么放这里（`by-name` / 类别目录 / 具名集合，见 §2.1） |
| 包名、版本合不合规 | `pname` 是否等于上游名、`version` 是否数字开头 |
| 能不能在目标架构上构建 | 建过哪个架构，**没建的不要勾** |
| **可执行文件都跑了吗** | 有 `bin/` 就跑；**没有 `bin/` 就说清没有**，并说明改用什么判据 |
| `description` / `license` / `platforms` | 与上游一致，且理由**写在注释里** |
| **`mainProgram` 该不该设** | 有主可执行文件才设；没有就不设 |
| 构建期依赖是否都在 `nativeBuildInputs` | |
| 取源是否官方、是否用了合适的 fetcher | |
| **特殊打包选择的动机有没有写下来** | 非默认构建标志、被删掉的安装步骤、被禁用的检查 |
| `phases` 有没有被覆盖 | 覆盖了的话，里面有没有 `runHook preInstall` / `postInstall` |
| 补丁是否有说明、是否该远程取 | |

**「报告拼写错误」也在清单里** —— 通读一遍拼写与措辞，不是可选项。

> 清单里最容易被当成形式主义、实际最容易翻车的是**「特殊选择的动机」**那一格：
> 它问的不是「你有没有做过特殊的事」，而是**别人将来能不能安全地把它改掉**。
> 写了「上游 CMakePresets 打开了这两个开关、而 CMakeLists 默认关」，
> 后来者才知道什么时候可以删掉这两行。


### 2.7 依赖 qtbase 就必须声明包装意图（否则构建在最早期就失败）

**任何 `buildInputs` 里有 `qt6.qtbase` 的包，必须在「应用」与「库/插件」之间表明身份**，
否则 Qt 的钩子直接拒绝构建 —— 实测报错原文：

```
Running phase: qtPreHook
Error: this derivation depends on qtbase, but no wrapping behavior was specified.
  - If this is an application, add wrapQtAppsHook to nativeBuildInputs
  - If this is a library or you need custom wrapping logic, set dontWrapQtApps = true
```

| 你打包的是 | 要写 |
|---|---|
| **应用**（自己有 `bin/`，要带上 Qt 的运行时环境） | `nativeBuildInputs` 里加 `wrapQtAppsHook` |
| **库 / 插件**（OBS 插件、KDE 的 `.so`、Qt 插件） | `dontWrapQtApps = true;` |

> **这是「必需」不是「可选」** —— 删掉 `dontWrapQtApps = true;`，构建立刻红。
>
> **⚠️ 一个我差点写错的推断**：曾想过「这个包没有 `bin/`，包装钩子无事可做，
> 所以删掉也没影响」。**错了** —— 钩子在 `qtPreHook` 阶段（早于任何安装）
> 就检查这个前提，**它不管你有没有 `bin/`**。
>
> **判据的教训**：「没量过」不等于「没影响」。要验证某个标志是否被读到，
> **把它注释掉再构建** —— 报错就是被读到了。这个实验比读源码推理快且可靠。

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
- 库：`pythonImportsCheck` / 写个最小调用方；
- **宿主会加载的插件**：让宿主真的把它装起来跑一遍，读**宿主自己写的日志**；
- **带原生模块的应用**：加载那个模块并**做一次真操作**（开库 → 建表 → 写入 → 读回）。

#### 第 4 层必须带一条**同强度**的反证臂

「日志里有它」「模块加载成功」这类断言，**不加对照臂就什么都没证明** ——
它可能只是宿主念了一遍目录名，或者那个模块本来就在别处被加载过。

做法：用 `overrideAttrs` 造一份**故意坏掉**的派生，让同一条断言**必须失败**。

```nix
# 例：把插件真正依赖的那份预编译删掉 / 把 postInstall 去掉
base.overrideAttrs (_old: { postInstall = ""; })
```

**反证臂必须与正臂同强度**，否则它给出的安心是假的：

- 正臂「构造实例 + 建表」而反证臂只写 `require()` —— **`require` 是懒的**，
  它自己成功、不碰绑定，于是反证臂报「仍然成功」。**那是反证臂太弱，不是判据坏了。**
- 正臂跑 `doctor` 而反证臂只跑 `--help` —— 强度不同，测的不是一件事。

**别手工改 store 里的副本去造假样本。** store 是只读的，`cp` 出来的副本 `rm` 会
全部 Permission denied（那个「反证」什么都没改却报 ok）；而 `chmod -R` 会顺着
符号链接打到 `/nix/store`。**用 `overrideAttrs` 让 nix 自己产出那一份。**

### 3.2.1 测试：判据是**条数**，不是退出码

如果上游带测试套件，把它接进构建是**最便宜的一层判据**。但有两个坑：

**① 退出码证明不了测试跑过。** 上游的测试配置里常见这类开关：

```
# vitest.config.ts
test: { passWithNoTests: true }
```

于是「一条都没收集到」也是**绿的**。**必须看条数，并把它写成基线。**

**② 条数要从日志的**最后一行**读。** vitest 这类跑边打进度：

```
Tests  0 passed (0)        ← 进度
Tests  252 passed (633)    ← 进度
…
Tests  2747 passed | 7 skipped (2754)   ← **只有这行是总结**
```

第一次 grep 抓到第一行，就以为一条没跑 —— **同一个日志，两个方向都能读错。**

**先例**（两个包，都是「构建全绿而测试一个没跑」）：

- 一个 python 包**没有 `nativeCheckInputs`**，pytest 从不启动；
  接上后 `102 passed, 9 skipped`。
- 一个 npm 包**没有 `doCheck`/`checkPhase`**；接上后
  `201 files / 2754 cases`，`2747 passed`。

**两处都是「构建通过」完全看不出来的。**

### 3.2.2 跨 nixpkgs 版本比对产物：**比字节会骗你**

拿「上游 CI / `nixpkgs-review` 建出来的产物」与「你自己对着另一棵 nixpkgs 树的 dry-run
产物」比 sha256，**常常不相等** —— 而这是**预期**，不是缺陷。

原因：Nix 的路径哈希包含完整依赖闭包。两棵树里 `glibc` 从 `2.42-84` 变到 `2.44-25`、
`gcc` 从 15 变到 16，同样的源码就会编出**不同的字节**（实测：44.6 万字节里 38.3 万不同，
但 `NEEDED` 集合与文件清单完全一致）。

**正确的等价判据是「产物路径相同」，而不是「字节相同」：**

```bash
# 对着与对方**同一棵** nixpkgs 重建，看产物路径是否一致
NIXPKGS_PATH=/path/to/that/same/tree nix build --impure --no-link --print-out-paths ...
# 与对方报出的 /nix/store/<hash>-<名字> 逐字比
```

产物路径相同 ⇒ 派生相同 ⇒ **内容相同**。这是同一棵树内部的比较，所以判据成立；
问题只出在「我以为两边是同一棵树」。

> **追问链（这次实际走了一遍）**：字节不同 → 是缺陷吗？→ 看 `NEEDED` 集合
> → 相同，只有 `RUNPATH` 指向不同的 glibc/gcc → 猜测是 nixpkgs 差异
> → **不猜，用同一棵树重建** → 产物路径完全相同 → **证明**差异 100% 来自 nixpkgs。
>
> **「解释得通」和「证明是它」是两件事。** 停在前者的代价是：将来真出问题时，
> 你会拿同一个解释把自己劝住。

### 3.3 格式与结构

```bash
nix run <nixpkgs-path>#nixfmt -- --check /tmp/draft/package.nix   # 退出码 0 = 已符合
```

by-name 的结构检查要**人肉对照**第 2.1 节那 12 条
（本地跑 `./ci/nixpkgs-vet.sh master` 需要完整 nixpkgs 仓与 base 分支，草稿阶段不划算）。

### 3.4 把 dry-run 产物留在仓库里

dry-run 的 `package.nix`、PR 摘要草案、披露文本要**进版本库**，
这样它们可复核、也能被自检盯住。留在 `/tmp` 里等于没有。

**单一来源，禁止副本。** 提交时要用哪份内容（commit 正文、PR 正文），
就让那个文件**就是**那一份，用 `git commit -F <文件>` 直接喂。

> 走过的坑：我在 `/tmp` 里用 `sed` 改了模型名与一个数字，
> **没写回仓库的源文件**。于是仓库那份与已发布的那份不一致，
> 而仓库那份里还留着一个错数字，下一次谁用它谁就带走那个错。

### 3.5 **逐行通读你要提交的那份 diff**（硬闸门）

**这一步不能跳过，而且它不是「再跑一遍判据」。**

判据抓不到的东西，全在这一步：

| 评审者真提过的问题 | 为什么判据不响 |
|---|---|
| `meta.maintainers` 是空的 | 构建不关心 `meta`，`nixpkgs-vet` 也不关心 |
| 注释里引用了**本 PR 里不存在**的文件 | 注释不参与任何检查 |
| 注释语言是中文，而 nixpkgs 要英文 | 没有判据管语言 |
| `nativeBuildInputs` 里留了**已无人使用**的 `makeWrapper` | 多一个输入不影响构建 |
| `doCheck = true` 其实是冗余的 | 设不设都一样跑 |
| commit 正文里的数字与实测不符 | 数字写在正文里，没人核 |

**做法**：把两份文件渲染成评审者会看到的样子，然后**逐行读**：

```bash
# 改动版与 base 的 diff
diff -u <base 那份> <改动版>
# 新增文件全文（带行号读）
awk '{printf "%3d| %s\n", NR, $0}' package.nix
```

**逐行问四个问题**（顺序即优先级）：

1. **这一行里有没有指向「本 PR 之外」的东西？** 路径、文件名、仓库名、内部术语——
   审阅者看不到它们，看到就会问。**内部决策史、给下一个自己的提示，一律不进去。**
2. **这段注释是写给谁的？** 写给 nixpkgs 审阅者的用**英文**；
   写给本仓的搬回本仓文档。**本仓惯例是中文，nixpkgs 要英文——提交时必然冲突，
   必须在提交前换掉。**
3. **这一项是必须的吗？** 每个输入、每个设置都要答得出「不写会怎样」。
   答不出就删（`buildPythonApplication` 的 wrap hook 已带 `makeWrapper`；
   python 包的 `doCheck` 被强制 `false`、`doInstallCheck` 默认 `true`）。
4. **这句话/这个数字，我现在能验证吗？** 不能就别写，或者写「未验」。

**并且把「哪两个文件、什么关系」写下来**：改的文件 vs 新增的文件、
维护者条目 vs 包里的引用——**同一 PR 内必须自洽**
（加了 `grg41` 条目，包就必须引用它；否则审阅者会指出你加了个没人用的条目）。

> 评审者的原话值得记住：
> **"Using AI assistance does not replace your responsibility to review the generated changes.
> Please ensure the entire diff is properly reviewed before requesting another review."**
>
> 「能不能构建」不是判据。**构建不关心注释、不关心 `meta`、不关心你说的是不是实话。**

### 3.6 用 `nixpkgs-review` 复核（它有三个会骗人的坑）

`nixpkgs-review` 是审阅者会看的那份证据，但它**有两处会给出误导性的绿**。

**坑一：报告为空 ≠ 没有问题。**

它只遍历**求值成功**的属性。包求值失败时，那个属性直接从列表里消失，
于是报告是「没有任何受影响的包」+ 退出码 0 —— **一次失败的求值，读起来像一次干净的通过**。

判据：**你明明新增了一个包，报告里却没有它 = 求值炸了**，不是「没什么可测的」。

**坑二：绿了但全是缓存 —— 那次运行没有验证力。**

产物已在 store 里时不会重建，日志是**空的**。看日志：

```bash
L=~/.cache/nixpkgs-review/<rev-…>/logs/<attr>-x86_64-linux.log
wc -l "$L"                       # 0 行 = 没重建，这次的绿是缓存
grep -c "building '/nix/store" "$L"   # 有这几行才算真建过
```

**坑三（对本仓库最要命）：`pr` 子命令审不了 fork 里的 PR。**

`nixpkgs-review pr <n>` 把 PR 号**硬查在 `NixOS/nixpkgs`** 上；
`-r` 只改 git 取源的 remote，不改查询目标。实测：

```bash
nixpkgs-review pr 1 -r Kihara777/nixpkgs
# → 取到的是 NixOS/nixpkgs#1（别人的 glibc PR），因为 -r 只是换取源
```

**fork PR 要用 `rev`，喂它 PR 的 head sha：**

```bash
cd /path/to/bare-nixpkgs.git          # 需要是**裸仓**；它会验证 nixos/release.nix
export GITHUB_TOKEN=$(gh auth token)
HEAD=$(gh pr view <n> --repo <owner>/nixpkgs --json headRefOid --jq .headRefOid)
nixpkgs-review rev "$HEAD" --no-shell
```

**等价性要说清楚**：`rev` 用的是本地那个 commit 对象，而它与远端 head **sha 相同**
（同一个 sha 即同一份内容，这是密码学保证）。所以「`rev` 绿了」= 「PR 这个 commit 绿了」。
反过来，若只想审 fork PR 而当 PR 号不可用，**这条等价性就是你的依据**。

### 3.7 写 PR 正文：**短**，而且三层披露各就各位

**⚠️ 这条来自一次批准时附带的反馈。** 审阅者 `jm5905938` 给 `APPROVED` 时写的是：

> **LGTM, thanks for your work on this !**
>
> One minor suggestion: **the verification section could be a little shorter.**
>
> Hope to see more contributions from you :)

**他批准了，然后建议你把验证那一段写短点。** 这条要当硬约束看待，不是客套：

- **审阅者是扫读的。** 他要在几十条 PR 里判断「这个能不能合」，
  **不是来读你的证据链全文**。你写得多长，成本就落在他身上。
- **PR 正文不是验证报告。** 它只需回答：**这是什么 / 为什么要 / 有没有踩到规则**。
- **细则有更好的家**：判据推理、报错原文、每一步怎么跑的 → **commit message**、
  仓库里的 draft 目录、你自己的日记。**这些地方才是它们的家。**

**该留的：**

| 留 | 为什么 |
|---|---|
| 这个包是什么、上游在哪 | 审阅者要判断有没有重复、是不是恶意包 |
| 许可依据（**一句**，指向证据） | 他会查；给他一条最短路径 |
| 特殊打包选择（**一两条**，每条一句） | 他最关心「你为什么和默认不一样」 |
| 验证结论（**几行**，不是几段） | 「建过 / 跑过 / 对照臂干净」就够；原始日志不必贴 |
| **三层 AI 披露**（见 §2.5） | 政策要求，不能省——**但可以短** |

**该删的：**

- 把每条判据逐步展开叙述（「第 1 层……第 2 层……」）；
- 重复 commit message 里已经写清楚的东西；
- 「我做了什么」的流水账。

> **和写维护日志是同一个形状**：「**摘要**是摘要，不是事态描述」。
> 判据很直白：**如果你在正文里解释「这个报错为什么是这么来的」，那一段就不该在这里。**
>
> 这次的正文里，「How the plugin was verified」+ 披露里那个三段清单 **是重复的** ——
> 同一件事说了两遍，两遍都不短。**先数一遍：同一件事实出现了几次。**

---

## 第 4 步：实操

0. **先确认身份与账号**：`gh auth status`，看当前活跃账号是不是要用的那个。
   nixpkgs 上的 author/committer 的 name 与 email 必须有效（CI 会校验）。
1. Fork + 建分支（分支名提示改动内容即可），基于 `master`：
   ```bash
   git fetch upstream
   git switch --create init-<包名> upstream/master
   ```
   ⚠️ **先看 fork 的 `master` 落后多少。** 很久没同步的 fork 可能落后几千个提交，
   而 PR 的 diff 是相对 **fork 的 base** 算的 —— base 太旧，diff 里就会混进上游那一堆提交，
   把「+75 行」变成「+几万行」。先快进：

   ```bash
   # 确认能快进（fork 的 master 是上游 master 的祖先）再推，否则要 force
   git merge-base --is-ancestor <fork-master> <upstream-master> && echo 可快进
   git push https://github.com/<你>/nixpkgs.git <upstream-master>:refs/heads/master
   ```

2. 两个 commit，**顺序不能反**：
   - `maintainers: add <handle>`（改 `maintainers/maintainer-list.nix`）
   - `<包名>: init at <版本>`（加 `pkgs/by-name/<shard>/<包名>/package.nix`）
   两个 commit 都带 `Assisted-by: <工具> <模型版本>` trailer。
   **提交账号必须是名单里的那个 `github`** —— 见 §2.4。
   ⚠️ 提交信息里**不要用 shell 双引号包反引号**：`` `foo(d)` `` 会被当命令替换吃掉，
   提交信息里那几段会**静默变成空白**。多行信息一律写文件再 `-F` / `--body-file`。
3. `git push --set-upstream origin HEAD`，按模板开 PR。

   ⚠️ **PR 正文必须保留模板的全部行。** 模板自己写着：

   > please do not remove the template, even when nothing is checked!

   模板的结构是 `## Things done` / `- Built on platform:` / `- Tested, as applicable:` /
   `- Nixpkgs Release Notes` / `- NixOS Release Notes`，外加底部一批 `[链接]: URL` 定义。
   **自己另写一套「Things done」= 删了模板**，即使内容意思相同。
   该勾的勾，不该勾的留空**并写明为什么不适用**（模板的措辞是 "as applicable"）。
   **没跑过的不许勾** —— 上游 CI 会跑它，但替你打勾是另一回事。
4. **等**。原文：「It is entirely normal for your PR to sit around without any feedback
   for days, weeks or sometimes even months.」
   加速手段：勾满模板、打全标签、先拿到非 committer 的 review、**至少一周**无活动后再去
   Discourse 的 review-requests 帖或 Matrix 频道。

**谁按提交按钮、谁答评审**：按 AI 政策，答评审的是那位「在环里负责的人」。
工具不能代答——把评审意见转发给工具再转回去，是政策明说不允许的。


## 第 4.5 步：收到 review 之后（判断建议的性质，再决定怎么动手）

**审阅者的建议不是同一类东西。** 先分类，再决定「改不改」「怎么改」——
否则会把「风格偏好」当成「硬要求」，或者把「真问题」当成「口味」。

### 三类，判断依据是「能不能指出出处」

| 类型 | 判据 | 处理 |
|---|---|---|
| **合规性要求** | 能引到 CI 会拦的规则、或文档里出现 **must** | 必须改；不改会红或会被再次 request changes |
| **书写规范** | 能引到文档里的 **should / preferred**，或全仓有压倒性的用法 | 通常该改；它决定「像不像 nixpkgs 的代码」 |
| **更严谨/更正确** | 能指出类型安全、边界条件、可维护性的实质差别 | 该改；但要能说清「改了之后哪里更不容易坏」 |

**每一条都要能说出出处。** 说不出出处的，是**他的判断**（比如「这段注释可以删」），
那是可以商量的 —— 但要先承认它是判断，别伪装成规则。

### 实例：同一轮 review 里的四条，性质完全不同

| 建议 | 类型 | 依据 |
|---|---|---|
| 「加 `__structuredAttrs`」 | **规范 + 合规** | 文档 "is the preferred default"；"All new **top level** packages must enable"（我们不是顶层包，所以未被 CI 强制） |
| 「用 `lib.cmakeBool`，并链接到上游文件」 | **规范 + 更正确** | 928 个包在用；它 `assert (lib.isBool flag)` 且生成带 `:BOOL` 的明确形态 |
| 「删掉许可证理由」 | **他的判断** | 结论已由 `license = …gpl2Only;` 本身表达 |
| 「删掉 `platforms` 那行注释」 | **他的判断** | 见下 |

### 「自解释的代码不需要注释重述」——第四条建议的理由

被删的是这一行注释：

```nix
    # A plugin cannot be built where its host cannot: obs-studio has no riscv64.
    inherit (obs-studio.meta) platforms;
```

**为什么可以删**：`inherit (obs-studio.meta) platforms` **这一行本身就在说**
「平台集合跟宿主一致」。那句注释是把同一件事用散文再说一遍。

**判据**：**注释应该解释「为什么」，而不是把代码已经说的事复述一遍。**
一条注释如果删掉之后，读代码的人仍然得到同样的信息，它就是冗余的。

> 注意这与「特殊选择的动机要记录」**不冲突** —— 那条要求的是
> **代码本身表达不出来的理由**（为什么选这个 upstream、为什么打这个补丁）。
> `inherit` 已经表达了理由，就不需要散文。

### 「链接优于散文」——第二条建议的一半

审阅者把 6 行解释 CMake 开关的散文，换成一行**指向上游 `CMakePresets.json#L12-L15` 的链接**。

**为什么更好**：证据还在、字数下来了、而且**指向真实行号**。
上游改了这一行，链接会失效 —— 那比一段永远不会过期的散文**更诚实**：
散文会悄悄变成谎言，断链会立刻暴露。

### 什么时候可以点 "Apply suggestion"

**判断标准：这条改动是否「机械、无争议、不影响产物」。**

| 可以点 | 不要点 |
|---|---|
| 改拼写、改注释措辞 | **改变派生**（构建标志、依赖、`__structuredAttrs`） |
| 纯文档字句 | 需要你判断「要不要删」的评论删除 |
| 不碰任何构建输入 | 一处点了、另一处没点会让 PR 停在半截状态 |

**点按钮的两个副作用**：

1. **它生成一个 GitHub 提交**，不带你惯用的 `Assisted-by:` 披露 —— 披露链在那一个提交上断掉；
2. **它直接改远端分支，你本地一次都没建过** —— 改动若影响派生，就是在**没验证的情况下推上去**。

**多个建议要一起处理时，用 "Add suggestion to batch" 再一次性提交**，
否则会生成一串零碎提交。

### 批准之后没有动静，是正常的（合并权在别人手里）

**`APPROVED` 不是合并队列。** 合并需要一位**有合并权的人**按下按钮。

实测（六个已合并的「首次贡献 + 新包」PR）：2 个是**批准者自己合并**（几小时），
1 个是**别人批、committer 合**（约一天半），**3 个根本没有正式批准就合了**。

**而且 nixpkgs 的 merge bot 有一道我们过不去的门槛**（`ci/github-script/merge.ts`）：

```typescript
const allByName = files.every(({ filename }) =>
  filename.startsWith('pkgs/by-name/') && filename.split('/').length > 4)
```

**`allByName` 是检查表里的一项，每一项都必须为真** —— 所以
**只要改动里有任何文件不在 `pkgs/by-name/` 下**（维护者名单、类别目录里的包、
具名集合里的插件），**`@NixOS/nixpkgs-merge-bot merge` 就无法合并它**，
只能等人手动合。

**这不是卡住，是这类包的正常通道。**

### review 之后要改 commit 结构：squash 进原提交，再 force-push

**2026-10-19 维护者群里的原话**：

> obs-bilibili-stream 的那三个 commit 应该合成一个
> 保留 `maintainers: xxx` 和后面的 init，共两个，是比较推荐的
> nixpkgs 可 force push

并引用 CONTRIBUTING「If you have commits `pkg-name: oh, forgot to insert whitespace`:
squash commits in this case. Use `git rebase -i`.」，然后明确「**是要求**」。

**三条硬性要求：**

1. **review 产生的修补提交不能留在最终历史里。** 「修 review」不是新的逻辑单元，
   是同一个 init 的碎片（CONTRIBUTING §Commit conventions：Create one commit for
   each logical unit）。判据：`git log` 里出现 `init` 后面跟着
   `enable __structuredAttrs`、`drop comments` 这类续篇 → 该 squash。
2. **`maintainers: add <handle>` 是独立逻辑单元，squash 时保留。** 首次贡献的
   最终历史 = **两个 commit**（名单在前、包在后），不是三个、也不是一个。
3. **改写历史必须 force-push，而 nixpkgs 允许。** CONTRIBUTING 第 7 条把两件事分开写：
   - 加新提交 → `git push`
   - 改已有提交 / rebase → `git push --force-with-lease`

   **所以「不碰 force」这条纪律只适用于「加提交」。** 需要 squash 时不带 force
   根本推不上去——正确动作是 `--force-with-lease`，且**显式给期望值**
   （本仓 `origin` 指向上游，本地没有 fork 的 tracking ref，无参 lease 不可靠）：

   ```bash
   git push \
     --force-with-lease=refs/heads/<分支>:<远端当前 SHA> \
     <fork URL> \
     <新 SHA>:refs/heads/<分支>
   ```

**squash 的验证链（本地 SHA 拉不到，`nixpkgs-review` 跑不了）：**

| 判据 | 怎么量 |
|---|---|
| 树未变 | `git diff --stat <旧头> <新头>` 为空 |
| 派生未变 | 从新树求 `outPath`，与旧头相同 |
| 产物未变 | 同一 output path 下 `.so` / `config.json` / `en-US.ini` 的 sha256 |

树同 ⇒ 派生同 ⇒ 产物同。这条链比再构建一次更强。

**两个实测事实（别再凭印象说）：**

- **PR 标题与正文不受 force-push 影响**——它们在 PR 记录里，不在 commit 里。
  推前推后各取 `title` / `body` 的 sha256 即可证明。
- **行内评审评论不一定变 outdated**：squash 后 diff 形状不变（同样是「新增 N 行
  文件」）时，锚点依然有效；实测四条评论全部 `outdated=false`。

---

## 第五步之后：跟踪与维护

- `passthru.updateScript = nix-update-script { };` **不是必需**。r-ryantm 对 GitHub
  上的包有默认跟新行为：实测（2026-10-19）`obs-studio-plugins` 目录 54 个包定义里
  只有 4 个带 updateScript，而被 r-ryantm 跟新过的成员（`obs-vertical-canvas`、
  `obs-backgroundremoval`、`droidcam-obs`、`obs-plugin-countdown`）**都没有它**。
- **所以首次贡献时不必为它单独开一个 PR**：等上游第一次发版、开版本更新 PR 时
  顺手带上（同类模板 `obs-browser-transition.nix`）即可；若那时 r-ryantm 已经在跟，
  就完全不必要加。
- **不存在 `meta.dontUpdate` 这个标记**——想让 r-ryantm 跳过，靠的是不设 updateScript。
- 合并后，你就是维护者：上游发版要跟。
- 合并后删掉自己的分支（PR 的 head 分支），保持 fork 干净。

### 附：一次完整首次贡献的轨迹（2026-10-10 → 10-19，`obs-bilibili-stream`）

| 阶段 | 动作 | 判据 / 结果 |
|---|---|---|
| 选包与审计 | 可行性、许可、上游 issue | 先搜上游有没有人做过；不要先问「要许可」 |
| 写包 | 定义 + 本地 `nixpkgs-review` | 1 package added / built |
| 开 PR | `maintainers` commit + init commit | 正文含 AI 披露段（与 commit 分开） |
| 评审 | 四条建议 | 三分类；全部应用 |
| 修补 | 两个 follow-up commit | 追加式 `git push` |
| squash | 维护者要求 | 两个 commit；`--force-with-lease` |
| 复核 | 评审者 dismiss + 触发 `nixpkgs-review-gha` | 两平台各 1 package built |
| 合并 | committer 手动合并 | merge commit 进 master |

**三个「下一次会更快」的点：**

1. **规范依据有两个来源：文档 + 社区。** 文档给 must / should；社区（维护者群、PR 评论）
   给「这一次到底要不要」。问一句「这是建议还是要求」，通常能拿到明确答复——
   这次就拿到了「nixpkgs 可 force push」与「是要求」。
2. **`nixpkgs-review` 不必自己跑所有平台。** 评审者可在 PR 上触发
   `nixpkgs-review-gha`，结果以评论形式贴出（每个平台 `1 package built` 或
   `No rebuilds`）。本地拉不到的 SHA，可以请他们跑。
3. **「没有动静」不等于卡住。** 实测：推 squash 到评审者处理隔 **2 小时**；
   从开 PR 到合并共 **2 天 22 小时**。期间不需要催。

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
main 上新加的 LICENSE 可能比 tag 晚。**但先找源文件头的 SPDX、清单文件的 license 字段、
以及上游 issue 里有没有人问过**——见第 1 步第 ④ 问。
**证据必须在被取的那份源码里**，而「没有 LICENSE 文件」不等于「没有许可」。

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

**⑨ 打开 `doCheck` 前先想清楚「测试在什么环境里跑过」——上游只在 venv 里试过。**

先例：某包的测试把服务端起成子进程，构造子进程环境时写了

```python
env = os.environ.copy()
env["PYTHONPATH"] = some_dir        # 覆盖
```

**在 venv 里这无害**（依赖在解释器自己的 site-packages 里），
**在没有 venv 的构建环境里等于把依赖整个丢掉**——症状是一片
`McpError('Connection closed')` 加 `ModuleNotFoundError`，
看起来像打包坏了，其实是上游测试对环境的假设。

处置：用 `substituteInPlace … --replace-fail` 把覆盖改成追加
（`os.pathsep.join([原值, env.get("PYTHONPATH", "")])`）。
用 `--replace-fail` 而不是静默 patch：上游改了那一行，构建立即失败，
不会变成「测试少跑了一半还没人知道」。

**并且给它撞一次反证**：把 patch 摘掉，测试必须当场翻脸。
说不清「摘掉会坏成什么样」的 patch，不该留在包里。

**永远跑不了的测试要显式排除，并在 PR 里说明范围**：
需要真实 GUI 程序、真实设备、网络的测试在构建沙箱里跑不了，
用 `disabledTestPaths` / `disabledTests` 点名，别用 `doCheck = false` 把整层判据扔掉。

**⑩ Nix 对「声明了没用的参数」不报警——而查它的量具很容易骗你。**

`package.nix` 的参数表里留一个用不上的参数（比如为未来准备的可选依赖），
构建照样通过、求值照样成功，**没有任何东西会说话**。
审阅者可能会问，但机器不会。

所以要自己查。**但注意查的方式**——实测连撞两次假警报：

- 用文本正则找「参数表结束」的位置，切错行 → 报出「五个参数全死」（其实都在用）；
- 用 `\bblender\b` 数引用 → 命中了 **`blender-mcp`** 里的 `blender`
  （连字符算词边界）→ 报出「引用 12 次」（其实只有 `postFixup` 那几处）。

**可靠做法：参数名从求值结果读，不要从源码文本读。**

```bash
nix-instantiate --eval --json --strict --expr '
  let pkgs = import <nixpkgs-path> {}; f = import <package.nix>;
  in builtins.mapAttrs (n: _: n) (builtins.functionArgs f)'
```

拿到参数名之后，再数它们在正文里的**独立**出现
（正则前后都要排除字母数字、下划线**与连字符**）。

> 这属于「仪器类的错」：我要判的是包，结果两次都在判我自己的正则。
> **判据的灵敏度要拿对照臂试**——比如故意把参数名换成它自己加个后缀，看它会不会漏。

**⑪ 参数签名里的默认值挡不住 `callPackage` 的自动绑定——想「可选」就得删掉参数。**

先例：为了让包里某个可执行文件能找到可选的上游程序，写了

```nix
{ blender ? null, ... }:
...
postFixup = lib.optionalString (blender != null) ''
  wrapProgram "$out/bin/x" --set-default X_PATH "${blender}/bin/x"
'';
```

**意图**是「默认 null ⇒ 不把那个程序拉进闭包」。**实测推翻**：

| 调用方式 | 参数是否被绑 | 闭包里有它 |
|---|---|---|
| `callPackage { }` | **是** | **有** |
| `callPackage { blender = null; }` | 否 | 无 |

**`callPackage` 只看「这个名字在它自己的作用域里存不存在」**——
存在就填，参数签名里写没写默认值它不管（`builtins.functionArgs` 也照样把它列成可绑定）。

所以「可选依赖」在 nixpkgs 里的正确形态是**根本不要那个参数**：
不写它，需要的人自己设环境变量（或自己 `.override` 一份）。
写一个 `? null` 只会**掩盖**实际发生的事，还会让审阅者以为它真是可选的。

**判据**：`nix-store -q --references <drv> | grep -c <那个程序>`，删前删后各跑一次。

**⑫ 自动检查的假警报比漏报更花时间——先怀疑检查器，再怀疑文件。**

先例：在一次提交里，我用来核对文件的脚本连出**四次假警报**：

- 找「参数表结束」的位置，正则**切错行** → 报出「五个参数全死了」（其实都在用）；
- 用 `\bblender\b` 数引用 → 命中了 **`blender-mcp`** 里的 `blender`（连字符算词边界）
  → 报出「引用 12 次」；
- 比对披露文本时正则**写得比内容窄** → 报出「PR 正文缺模型名」（其实有）；
- 比对反证数字时没考虑**反引号** → 报出「数字不一致」（其实一致）。

**四次里没有一次是文件的问题。**

规则：

- **假警报要当场定性**，不要「重跑一次看看」——重跑不会让错的正则变对；
- 判据**先拿反例试**（故意喂一个已知的坏样本，看它响不响），
  和**拿真样本试**（看它误不误报）；
- 报告里分开写「检查器说不行」与「我看了，确实不行」——**前者不是结论**。

**⑬ 本地那棵 nixpkgs 能用来「构建」，不能用来「判断上游长什么样」。**

nixpkgs 的结构一直在动，而本地树通常是某个时点的快照。**凡属于结构的问题，
必须现取 master 核实。** 属于结构的是：

- 这个包该放哪个目录（`pkgs/by-name/…`？类别目录？还是某个 scope 下的文件？）
- 要不要另改一个「接线文件」把包登记进去
- 用哪个 `callPackage`（`pkgs.callPackage` / `qt6Packages.callPackage` / …）
  —— **它决定参数名怎么写**（`qtbase` 还是 `qt6.qtbase`）
- 有没有自动发现机制

先例：按本地九月快照，我断定 OBS 插件要在 `plugins/default.nix` 里手工加一行、
Qt 写 `qtbase`。取当前 master 一看，两处都变了 ——
接线改成了 `lib.packagesFromDirectoryRecursive` 的**自动发现**（不用加行），
`callPackage` 也换回普通的 `pkgs.callPackage`（于是要写 `qt6.qtbase`）。
**差一点带着过时的接线方式去提交。**

做法：

```bash
# 结构问题一律现取
gh api "repos/NixOS/nixpkgs/contents/<路径>?ref=master" -H 'Accept: application/vnd.github.raw'
gh api 'repos/NixOS/nixpkgs/contents/<目录>?ref=master' --jq '.[].name'   # 看目录现状
```

判据：**引用的每一个上游文件路径，都要有一次带 `ref=master` 的取回记录**；
只凭本地 `ls` 得出的结论，写下来时要标「基于快照，未核 master」。

---

---

## 仓库适配层

本技能只含通用方法。仓库特有的环节由适配层提供：

- 多语文档同步（新增内容先写基准语言，再翻译；各语言条目数要相等）、
- 维护日志（推送后必须补录，且多语同步）、
- 把新技能登记进仓库自检与文档索引、
- 各类 `check-*.py` 自检的射程。

NixKits 的适配层见 `skills/nixkits-package-upstream/`。
