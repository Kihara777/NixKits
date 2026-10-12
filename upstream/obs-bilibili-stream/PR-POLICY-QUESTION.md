# PR #572912 上的政策质询 —— 材料与事实

**状态（2026-10-12 06:36Z 快照）：`CHANGES_REQUESTED`（K900）—— 但方向已经明确。**

## ✅ 最新进展：K900 给出了解法（2026-10-12 06:32:48Z）

> In that case please just use your personal account as a point of contact.

**「那就用你的个人账号作为联络点。」**

翻译成可执行的动作：

| 改什么 | 怎么改 |
|---|---|
| `maintainers/maintainer-list.nix` | 加 **`kihara777`** 而不是 `grg41`（插入点：第 15239 行，`kidsan` 与 `kiike` 之间） |
| `pkgs/by-name/ob/obs-bilibili-stream/package.nix` | `maintainers = [ lib.maintainers.kihara777 ]` |
| 分支的第一个 commit | 重做为 `maintainers: add kihara777` |

**PR 作者仍是 `GrG41`** —— 他要的是「**联络点**」是个人账号，不是把作者换掉。
（他的原话是 point of contact，不是 author。）

**待狐莉定**：`name` 那一格写什么；要不要 `email`（`maintainer-list.nix` 里
488 条没有 email，所以不填也合规）。GitHub 上 `Kihara777` 的显示名是空的，
所以这两个字段只能她自己给。

**狐莉 2026-10-12 决定：先放着。**

## ⏳ 悬着的事（先放着 ≠ 忘了）

| # | 待办 | 谁做 | 状态 |
|---|---|---|---|
| 1 | **那条回复缺它自己的披露** | 狐莉（编辑评论） | 仍未做。政策要求评论单独披露，而整场讨论的主题就是政策 |
| 2 | **维护者那一格换成 `kihara777`** | 狐莉给字段 → 我重建分支 → 她回复 | **K900 已明确要求走这条**，方向不再是猜的 |

**没有期限**，但门已经开了 —— 而且是他自己推开的。

---

## 一、发生了什么

| 时间（UTC） | 谁 | 什么 |
|---|---|---|
| 2026-10-12 00:58 | `knightfemale`（机器人） | `nixpkgs-review pr 572912` 的结果：**x86_64-linux 建出 1 个包** ✅ |
| 2026-10-12 01:08 | `jm5905938` | 说 PR **技术上 fine**，但不确定 AI 政策怎么适用于「**要成为维护者的账户是自动化的**」，并 @ 了 K900 / roberth |
| 2026-10-12 01:54 | `K900` | 评论：「A computer can never be held accountable, etc. **It's fine to use automation to update your packages, but the human needs to be responsible at the end of the day.**」 |
| 2026-10-12 01:55 | `K900` | **正式评审：`CHANGES_REQUESTED`，正文「Please don't.」** |
| 2026-10-12 03:26 | `GrG41`（狐莉发） | 说明账号归她、无无人值守自动化、AI 操作受明确许可约束、必要时可关掉重提 |
| 2026-10-12 06:32 | `K900` | **「In that case please just use your personal account as a point of contact.」** —— 方向明确了 |

**没有人质疑包的实现。** 两位的话都指向同一个点：**担责的位置**；而最后他给出了走法。

---

## 二、政策原文（`CONTRIBUTING.md` → Automation/AI policy）

逐字，不是转述：

> Every contribution to Nixpkgs and related development venues ... must have a
> **responsible person in the loop** who is accountable for that contribution and
> reviews it before submission, and must **transparently disclose** any non-trivial
> use of automation to produce it...

> Everyone who submits a contribution to Nixpkgs is responsible for it,
> **regardless of the use of automated tooling.**

> Before submission, they must establish a reasonable level of understanding of the
> contribution and expectation of its correctness.

> Contributors are expected to be able to answer questions about their contribution
> and respond to feedback appropriately, **without simply forwarding messages back
> and forth to automated tools.**

> It is not permitted to submit automated contributions without any manual review or
> intervention, outside of standard community automation.

> **Pull request summaries and review comments must be disclosed separately to commits.**

---

## 三、维护者角色是什么（`maintainers/README.md`）

> The main responsibility of a maintainer is to keep the packages they maintain in a
> functioning state, and keep up with updates.

> **Anybody (both bots and humans) can send PRs** to bump or tweak the package.

> ### How to become a maintainer
> We encourage people who care about a package to assign themselves as a maintainer.
> Commit access to the Nixpkgs repository is not required for that.

> Once the PR is merged you will automatically get invited to join the
> **NixOS/nixpkgs-maintainers** GitHub team. By joining, we will be able to ping you
> for review, and you will get some **triaging rights** in the nixpkgs repository,
> like the ability to **close and reopen issues made by others and managing labels**,
> as well as **invoke the merge bot** on eligible PRs.

**「bot 也能发 PR」是明文**；但**维护者身份**带来的是团队身份与 triage 权限 ——
那几项是**对别人的内容动手**的权力。这是 K900 那条分界线所在的位置。

---

## 四、涉及的具体字段（若改变维护者归属会需要）

| | |
|---|---|
| `kihara777` 现在在名单里吗 | **不在**（#572360 从未合入） |
| `grg41` 现在在名单里吗 | 不在；本 PR 加的就是它 |
| Kihara777 的 GitHub | login `Kihara777`、id **`24633616`**、注册 **2016-12-18**、`name` 字段在 GitHub 上是**空** |
| `kihara777` 的插入点 | 第 15239 行，`kidsan` 与 `kiike` 之间 |
| `grg41` 的插入点 | 第 10907 行，`greydot` 与 `grgi` 之间 |
| 本 PR 里的 `meta.maintainers` | `[ lib.maintainers.grg41 ]` |
| `pkgs/README.md:516` | 新包 **must** 设 `meta.maintainers`（所以「摘掉」会留下另一个洞） |

---

## 五、三条路

| | 做法 | 代价 |
|---|---|---|
| **甲** | 维持现状，回复他 | 他说的是「Please don't.」，而他的理由政策原文支持。顶回去＝开一场政策争论 |
| **乙** | 摘掉维护者条目 | `meta.maintainers` 会空，撞 `pkgs/README.md:516`（换个人来审同样会拦） |
| **丙** | 维护者换成 `kihara777`（人） | 正落在他的话上：**自动化照旧干活，担责的是人**。需要定 `name` 与是否 `email` |

**当前选择：甲（先回复，不动代码）。**

---

## 六、回复本身也要披露

政策原文明写：**「Pull request summaries and review comments must be disclosed
separately to commits.」**

所以 PR 上那条回复**自己也带披露** —— 与 commit 里的 `Assisted-by:` 是两回事，
要各自满足。

---

## 七、几条我作为工具能提供的、以及做不到的

**能提供**：政策原文、字段事实、插入点、历史（#572360 那轮的往来与结论）、
以及任何你需要的取证。

**做不到**：替你写那条回复。政策明文要求贡献者能自己答问，
**不把消息来回转发给工具**。材料摆在这里，话得你说。
