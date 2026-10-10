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
- **AI 贡献政策**：`Assisted-by:` trailer 是强制披露格式，`Co-authored-by:` 不算；
  必须有「在环里负责的人」
- **dry-run**：对着**一棵真的 nixpkgs 树**求值、构建、核验产物、**跑产物**（四层判据）
- **实操**：两个 commit 的顺序（维护者条目在前）、分支与 PR、等待与加速
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
