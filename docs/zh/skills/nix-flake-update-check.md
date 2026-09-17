# nix-flake-update-check (Skill)

中文 | [English](../../en/skills/nix-flake-update-check.md) | [日本語](../../ja/skills/nix-flake-update-check.md)  | [偽中国語](../../pcn/skills/nix-flake-update-check.md)

> 检查**任意 nix flake 仓库**中软件包的上游版本更新并升级——按包型分流的 hash 更新流程、flake.lock 处置、补丁内版本检查与 nixpkgs 漂移陷阱。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nix-flake-update-check/SKILL.md` |
| 定位 | **通用**（不绑定任何具体仓库） |
| 配套 | 仓库特有环节由适配层技能补充（NixKits 用 `nixkits-check-updates`） |

## 功能

- 从 `flake.nix` **动态发现**外部包，排除自建包 / 动态版本 / 跟随 nixpkgs / 补丁内版本
- 按**包型**（npm / cmake / Rust `buildRustPackage` / `fetchurl` / python）分流的 hash 更新流程
- **Dependabot 自动 PR 的处置**：npm 更新 PR 因 `npmDepsHash` 无法被 bot 感知而必然 CI 失败；附取回分支补 hash 的流程与「目标版本是否落后于 next/alpha 通道」的核对
- hash 计算陷阱：SRI 格式、`fetchFromGitHub` 与 archive tarball hash 不一致、`lib.fakeHash`、npm 两次构建
- Rust 包需**同步 `Cargo.lock`**（最易遗漏）
- `flake.lock` 三路处置：已 gitignore → 跳过；有动态版本 → 必须排除；其他 → 随 hash 一并提交
- 补丁文件内硬编码版本（`.patch` 中的 version / url / hash）的识别与更新流程
- nixpkgs 漂移陷阱：`inputs.*.follows`、`doInstallCheck`、`pythonRuntimeDepsCheckHook`、无参数 `nix flake lock`

## 设计：为什么拆成两个技能

本技能原名 `nixkits-check-updates`，与 NixKits 仓库强耦合（硬编码四语文档路径、
dsh 插件清单、维护日志技能）。这使它对其他 nix flake 仓库**不可直接用**。

拆分为「通用核心 + 仓库适配层」后：

- 通用方法（本技能）可被任何 nix flake 仓库直接复用
- NixKits 的具体经验（事故教训、文档约定）留在适配层，**不必为通用性而稀释**

## 仓库适配层契约

本技能覆盖到「记录变更」为止；仓库特有环节由适配层补充。适配层应说明：

| 环节 | 适配层需说明 |
|------|-------------|
| 文档同步 | 文档路径、语言清单、需同步的特殊章节 |
| 变更记录 | 该仓库使用的记录技能或文件 |
| 动态版本输入 | 仓库是否有不可锁定的浮动 input |
| 已知事故教训 | 该仓库历史上因更新导致的故障与规避方式 |
| 额外同步项 | 内置清单、生成文件等 |

冲突时**以适配层为准**。

## 使用

由 AI 助手在用户要求「检查软件更新」或「更新包版本」时激活。
若当前仓库有适配层技能，应先加载适配层，再执行本技能。
