# nixpkgs-package-upstream (Skill)

中文 | [English](../../en/skills/nixpkgs-package-upstream.md) | [日本語](../../ja/skills/nixpkgs-package-upstream.md)  | [偽中国語](../../pcn/skills/nixpkgs-package-upstream.md)

> 把一个自建软件包提交到上游 nixpkgs 的通用流程：评估 → 审计 → dry-run → 实操。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixpkgs-package-upstream/SKILL.md` |
| 依赖 | 无（仓库特有环节由适配层提供） |

## 功能

- **评估可行性**：六问逐条取证——是否已在 master、是否被删过、有无在途 PR、
  许可能否在**取源的那个 tag 里**指认、有无维护意愿、依赖会不会与 nixpkgs 共用包集冲突
- **审计要求**：by-name 结构与 `nixpkgs-vet` 的 12 条检查、3 条棘轮、meta 必填项、
  nixfmt 格式、commit 前缀驱动 CI、不需要 DCO、不需要先开 issue
- **包该放哪的三种去向**：by-name、类别目录，以及**具名集合**（`obs-studio-plugins`
  这类）——后者无入口可加，发现机制**只能靠求值确认**（`pkgs.<集合> ? <名字>`）；
  旧 PR 里看到的机制可能是**已被删除**的
- **身份硬约束**：名单里的 `github` **必须等于 commit 作者的 GitHub 账号**——
  这条决定「用哪个账号提交」，不是先挑账号再填名字
- **先分流**：首次贡献 vs 再次贡献 × 全新添加 vs 版本更新——维护者条目是**一次性**的，再次贡献不再动名单；update 跳过评估与「放哪」两节
- **AI 贡献政策**：`Assisted-by:` trailer 是强制披露格式，`Co-authored-by:` 不算；
  必须有「在环里负责的人」；commit / PR 正文 / 评论**三层各自披露**
- **审阅者清单**：`pkgs/README.md` 的新包审阅要点，提交前自套一遍
- **dry-run**：对着**一棵真的 nixpkgs 树**求值、构建、核验产物、**跑产物**（四层判据）；
  跨 nixpkgs 版本比对产物时**不能比字节**，要比**产物路径**
- **`nixpkgs-review` 的三个坑**：空报告 = 求值失败、绿了但全是缓存、`pr` 子命令
  审不了 fork 里的 PR（那要用 `rev` + head sha）
- **PR 正文要短**：审阅者在批准时附了一句「验证段能再短些」——细则是 commit message 与草稿目录的家，正文只回答「是什么/为什么/有没有踩规则」
- **Qt 依赖者的必填项**：`buildInputs` 里有 `qt6.qtbase` 就必须二选一——应用加 `wrapQtAppsHook`，库/插件写 `dontWrapQtApps = true`；否则在 `qtPreHook` 阶段直接失败
- **收到 review 之后（第 4.5 步）**：按「合规性要求 / 书写规范 / 更严谨正确 / 他的判断」四类分辨每条建议，**每类都要能说出出处**；说不出出处的就是判断，可以商量
- **批准 ≠ 合并**：合并要人按按钮；而 merge bot 有一道门槛——改动里只要有一个文件不在 `pkgs/by-name/` 下，`@NixOS/nixpkgs-merge-bot merge` 就无法合并
- **实操**：两个 commit 的顺序（维护者条目在前）、**fork 的 master 先快进**、
  **PR 模板不得删改**、分支与 PR、等待与加速
- **陷阱清单**：许可缺口、仓库自述过期、同名不同包、文档漂移、预编译二进制、
  以及对符号链接树递归 chmod 会打到 nix store

## 使用

由 AI 助手在用户要求「把这个包提交给 nixpkgs」「贡献到上游」时激活。

仓库特有的环节（四语文档、维护日志、自检登记）见适配层技能
[`nixkits-package-upstream`](nixkits-package-upstream.md)。

## 判据的来源

技能里的每条硬性要求都出自 nixpkgs 自己的文档或 CI 实现，并在技能里给出出处：

- `pkgs/README.md`（新包规则、命名、meta、取源）
- `pkgs/by-name/README.md`（结构、限制）
- `nixpkgs-vet` 的 `README.md`（12 条检查与 3 条棘轮）
- `CONTRIBUTING.md`（commit 约定、AI 政策、评审流程）
- `.github/workflows/lint.yml` 与 `.github/PULL_REQUEST_TEMPLATE.md`

**这些文件会漂移**，所以技能的第 0 步是「先同步，再采信」——
任何「现在的 nixpkgs 是什么样」的结论都要现取。
