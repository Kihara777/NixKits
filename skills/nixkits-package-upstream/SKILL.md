---
name: nixkits-package-upstream
description: NixKits 的 nixpkgs 上游贡献适配层——在通用技能 upstream-audit 之上，补充本仓特有的环节：13 个包的可行性台账（谁已进 nixpkgs、谁有在途 PR、谁不值得提）、许可缺口的处置、四语文档与语言切换器、维护日志补录、新技能登记进 README 与自检，以及本仓历史上写错过的「nixpkgs 已不再提供 X」这类过期自述的更正。依赖 upstream-audit。
---

# NixKits 上游贡献适配层

> ⚠️ **本技能名已弃用（2026-10-20）**
>
> 拆分后的归属：通用方法在 [`upstream-audit`](../upstream-audit/SKILL.md)
> （**只读，到 dry-run 为止，不给提交步骤**）；提交动作（fork / 分支 / commit / push /
> PR、review 回应）在本机私有提交层（不随本仓库分发）。
>
> 本文件作为 **NixKits 的适配层**保留：只补本仓特有的**审计**环节（可行性台账、许可缺口、
> 四语文档、维护日志、自检登记），**不再包含任何写操作**。下一次改名时删除本声明。

本技能是 [`upstream-audit`](../upstream-audit/SKILL.md) 的**仓库适配层**。
通用方法（评估六问、by-name 与 nixpkgs-vet 要求、dry-run 四层判据、AI 政策、陷阱清单）
在那边；这里只写 **NixKits 特有**的东西。

开工前先读通用技能。**顺序不能换**：评估 → 审计 → dry-run → 实操。

---

## 第 0 步：本仓的两条硬约定

**① `flake.lock` 提交，不要删它。**
（2026-10-21 起：唯一的浮动输入 `llama-cpp-ver` 已迁到 `impure` 分支，lock 现在是
**受测基线**。要更新输入就显式 `nix flake update <input>` 并同批提交新 lock——
`rm -f flake.lock` 是旧约定，会让 CI 自己生成一份再判绿。）

**② 开工前先 `git fetch origin` 对齐远端。**
并行会话可能已经动过同一批文件。

---

## 第 1 步：可行性台账（2026-10-10 取证）

**不要重新从零评估——先读这份台账与 [`UPSTREAM-AUDIT.md`](../../UPSTREAM-AUDIT.md)，
再只更新变化的部分。** 取证基线是 nixpkgs master `78f093ad1`（2026-10-10T03:06Z）。

| 包 | 在 nixpkgs 里 | 结论 |
|---|---|---|
| blender-mcp | 没有 | **推荐**，许可已查实、测试已打通 |
| obs-bilibili-stream | 没有 | **已提交 PR #574725**（2026-10-16，CI 全绿待审）。首投 #572912 因身份规则被关闭，见下 |
| opencode-telegram | 没有 | 可做，先摘掉 riscv64 那段 |
| ruyi | 没有 | 需评估，426 行补丁要先静态化 |
| kitsfmt | 没有 | 暂缓，上游仓 404 |
| codewhale | 没有 | 不推荐（主发行是预编译二进制） |
| godot-ai | 没有 | 不推荐（钉死 14 个精确运行时版本） |
| dsh | 没有 | **停止**（nixpkgs 里叫 `deepseek-harness`，已有 3 个在途 PR） |
| mcp-searxng | **已在** | 不提交新包 |

**三条最容易踩的**：

- `mcp-searxng` **已经在 nixpkgs 里**，initial PR #557725 于 2026-09-03 合并，
  且有人开着 2.5.1 的更新 PR。列进「新包清单」是错的。
- `dsh` 在 nixpkgs 里叫 **`deepseek-harness`**——按我们的包名搜是搜不到的。
- `obs-bilibili-stream` 的**打包第一遍就通过了审阅**（审阅者原话
  "The PR itself seems technically fine to me"），死在身份规则上——
  **台账记「可做」不等于「提交就能过」，还要过身份那一关**（见通用技能 §2.4）。
  三个在途 PR：#552467 / #553134 / #554081，都是 8 月开的，至今未合并。
  我们这份从 npm 制品打、还要 `sed` 改包内文件，**不是 nixpkgs 要的形态**。
- `kitsfmt` 的 `meta.homepage` 指向本仓，而 `github.com/Kihara777/kitsfmt` 返回 404。
  先给它建独立仓库与 tag。

**台账要更新时**：把新的取证基线与日期写进 `UPSTREAM-AUDIT.md`，
不要在技能里堆历史。**技能记方法，审计文档记那一时刻的事实。**

---

## 第 2 步：本仓特有的前置处置

### 2.1 过期自述：先更正，再引用

本仓的文档与注释里有过**后来被证实是错**的断言。已发现的一处：

`packages/ruyi/ruyi.nix` 的注释写着「nixpkgs 已不再提供 ruyi 包」——
取证结论相反：**nixpkgs 里从未有过 ruyi**（by-name 的 `ru/` 分片没有、
commit 搜索 0、issue/PR 搜索 0、Discourse 搜索 0）。
真实来源八成是**本仓自己的 `build-ruyi-*.yml`**。

**规矩**：任何「上游已经……」「nixpkgs 已不再……」的句子，引用前先取证。
发现是错的就**当次改掉并单独提交**，不要留着让下一个人再错一次。

### 2.2 许可依据：先找源文件与清单，再考虑向上游要

`blender-mcp` 取的是 `v1.0.3`，而那个 tag 里**没有 LICENSE 文件**；
GPL-3.0 的 LICENSE 是十八天后才加进 `main` 的。

**但许可并不缺** —— 它写在**每个源文件里**：
我们构建出来的产物带 `# SPDX-License-Identifier: GPL-3.0-or-later`，
add-on 的 `blender_manifest.toml` 也声明了。
而且上游 issue
[`#59`](https://projects.blender.org/lab/blender_mcp/issues/59)
就是问这件事的，维护者的答复原话是「licence is in the individual files」。

**处置顺序（这次学到的）**：

1. 在**被取的产物**里找证据（`grep -rl SPDX-License-Identifier $out`）——
   产物比仓库可靠，它证明的是我们真正取到的那份源码；
2. 查上游有没有人问过许可（搜 issue），有就把那条引上——**最有力的依据**；
3. 前两步都空，才向**上游**要（补许可文件 / 等下一个 tag）。

**「没有 LICENSE 文件」不等于「没有许可」**；也**别重复别人做过的事**——
先搜索，再开 issue。

### 2.3 dry-run 落在仓库里

草稿与 PR 草案放 `upstream/<包名>/`，至少三件：

- `package.nix` —— 按 nixpkgs 规范写的草稿；
- `build.nix` —— 求值入口（用 `builtins.getFlake "path:<nixpkgs>"`，见通用技能 3.1）；
- `pr-body.md` —— PR 摘要草案，**含独立的 AI 披露段落**。

**不要复制 nixpkgs 树，也不要对它 chmod。** 用 `builtins.getFlake "path:…"` 直接读。
（本仓踩过：`chmod -R u+w` 顺着符号链接打到了 nix store 里的真实目录。）

### 2.4 排练：先在我们自己的 fork 里开一条 PR

**正式提交上游之前，先在 `Kihara777/nixpkgs` 里把整条流程走一遍。**
好处是它**完全不动上游**，却能把「PR 模板合不合规、diff 干不干净、CI 会不会红、
机器人打什么标签」全部量出来。

```bash
# 1) 切到你的账号（推 Kihara777/nixpkgs 必须用 Kihara777；GrG41 只有 pull 权）
gh auth switch --user Kihara777

# 2) fork 的 master 先快进到上游 master —— 否则 PR 的 diff 会混进几千个上游提交
git -C /path/to/bare-nixpkgs.git push https://github.com/Kihara777/nixpkgs.git \
  <upstream-master-sha>:refs/heads/master

# 3) 推分支 + 开 fork 内 PR（base 也选 master）
gh pr create --repo Kihara777/nixpkgs --base master --head <分支> \
  --title "<包名>: init at <版本>" --body-file upstream/<包名>/pr-body.md

# 4) 做完立刻切回 GrG41 —— 我的账号只用于 PR 之外的测试操作
gh auth switch --user GrG41
```

**注意 `nixpkgs-review` 审不了 fork 里的 PR**（它把 PR 号硬查在 `NixOS/nixpkgs`）。
fork PR 用 `rev` + head sha，见通用技能 §3.6。

**这条 PR 之后不必关闭**：它是排练的记录，留着比删掉有信息量。

---

## 第 3 步：登记与同步（本仓特有）

一次技能新增要同步的地方：

1. **README 的技能表**（四语）：`README.md`、`docs/README.en.md`、
   `docs/README.ja.md`、`docs/README.pcn.md` —— 各加一行，按字母序插入。
2. **技能文档页**（四语）：`docs/zh/skills/<名>.md` 起头写，再译到
   `docs/en/skills/`、`docs/ja/skills/`、`docs/pcn/skills/`。
   **`docs/` 下的文件必须带四语语言切换器，且在全文范围内被检查**
   （`develop/check-doc-links.py`），所以切换器要写对、写全。
3. **维护日志**（四语）：推送后按 `write-maintenance-log` 技能补 `MAINTENANCE.md`
   与 `docs/MAINTENANCE.*.md`，**推送后立即做**。
4. **自检**：若加了新的 `develop/check-*.py`，要在 `flake.nix` 的 `checks` 登记，
   并同步 `AGENTS.md` 里声明的自检项数（`develop/check-doc-counts.py` 会核对这个数字）。

**判据是可核验的数字，不是「我同步过了」**：

```bash
grep -c '^## 20' MAINTENANCE.md docs/MAINTENANCE.*.md   # 条目数必须相等
```

### pcn 的两条硬约束

- **正文不得出现非日文字形**（判据是 `shift_jis` 编码探针，即 JIS X 0208 范围）；
- **不得出现假名**（伪中国语是日语剥离假名后的结果）。

写完 pcn 先自问：这段字在 Shift_JIS 里存在吗？拿不准就查 `skills/translate-pseudocn/dictionary.md`。

---

## 第 4 步：提交前跑本仓自检

改动涉及文档或技能时，**对着「被提交的那棵树」**验一遍（不是对着工作树）：

```bash
for c in check-doc-links.py check-doc-counts.py check-doc-versions.py \
         check-maintenance-log.py check-session-sources.py check-workflows.py \
         check-preset-bundle.py check-preset-derivation.py; do
  python3 develop/$c || echo "FAIL: $c"
done
```

工作树一致而**提交的那一部分**不一致，是踩过的坑：
跨语言文件必须**整组提交**，不能按文件分批。

---

## 第五步：与通用技能的接口

| 通用技能里的步骤 | 本适配层补什么 |
|---|---|
| 第 1 步 评估 | 先读台账，只更新变化的部分；按**上游项目名**搜在途 PR |
| 第 2 步 审计 | 无（通用侧的规则就是全部规则） |
| 第 3 步 dry-run | 产物落 `upstream/<包名>/`，不落 `/tmp` |
| 提交（**不在本层**） | 见本机私有提交层（不随本仓库分发）；本仓账号用 `Kihara777`（owner），不是默认那个 |
| 收尾 | 四语文档 + 索引 + 维护日志 + 自检登记 |

**账号**：`gh auth status` 后确认活跃账号。本机同时登录了 `GrG41` 与 `Kihara777`，
**推 `.github/workflows/` 下的改动必须用 `Kihara777`**（另一个令牌缺 `workflow` scope）。
