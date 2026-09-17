# nixkits-check-updates (Skill)

中文 | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)  | [偽中国語](../../pcn/skills/nixkits-check-updates.md)

> NixKits 仓库的**软件包更新适配层**——在通用技能 `nix-flake-update-check` 之上，补充本仓库特有的四语文档同步、dsh 内置插件清单同步、同账户子仓链式检查的坐标、维护日志记录与历史事故教训。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-check-updates/SKILL.md` |
| 依赖 | `nix-flake-update-check`（通用流程，须先加载） |

## 结构：通用核心 + 仓库适配层

更新检查能力拆为两个技能，职责分离：

| 技能 | 职责 | 可移植性 |
|------|------|---------|
| `nix-flake-update-check` | 通用方法：包发现、包型分流的 hash 流程、同账户子项目链式并行检查、flake.lock 处置、补丁内版本检查、nixpkgs 漂移陷阱 | 任意 nix flake 仓库 |
| `nixkits-check-updates` | 本仓库适配：四语文档、插件清单、子仓坐标、维护日志、历史事故教训 | 仅 NixKits |

这样拆分后，通用方法可被其他 nix flake 仓库直接复用，而 NixKits 的具体经验
（事故教训、文档约定）不必为迁就通用性而稀释。两者冲突时**以适配层为准**。

## 本仓库特有环节

- **四语文档同步**：`docs/<lang>/<pkg>.md`（zh 基准 + en/ja/pcn），zh 先写再翻译
- **dsh 插件清单同步**：升级 `dsh` 时同步内置 `cordis.patch.yml` 的 entry id 清单
- **同账户子仓链式检查**：`dsh-api-balance` 薄封装引用子仓 `Kihara777/dsh-api-balance`，其自身版本变更须一并检查（坐标见下）
- **维护日志**：调用 `write-maintenance-log` 技能，四语同步
- **`llama-cpp-ver` 浮动输入**：不可锁定，`flake.lock` 不提交
- **泛化义务**：发现通用性改进时更新回 `nix-flake-update-check`

## 子仓引用：dsh-api-balance

链式检查的通用方法（回环、深度上限、依赖冲突判据）在
`nix-flake-update-check` 第 9 步；本仓的具体坐标只有适配层知道：

| 项 | 值 |
|---|---|
| 子仓 | `Kihara777/dsh-api-balance` |
| 引用方式 | `fetchFromGitHub` 固定 `rev`（**不是** flake input） |
| 子仓构建体系 | 纯 JS npm 包（`package.json`，无 build script） |
| 链长 | 1 层（该子仓无更上游的同账户子仓） |
| 发布渠道 | **不发布 npm**（维护者视障，无法完成 2FA 流程） |

要点：

- 子仓**不是 nix flake**——不要对它跑 `nix flake check` 或 flake.lock 处置
- 改 `rev` 后 **`src` hash 与 `npmDepsHash` 两者都变**，需两次 `nix build`
- 子仓的 `@deepseek-ai/dsh-*` 依赖是 **peer 性质**：版本低于宿主是正常状态，
  判据是「子仓要求是否**高于**宿主提供」而非「两侧是否相等」
- 该子仓迁出后已有**仅文档**的提交且版本号未变，按判据**不触发**薄封装重钉

## 检查范围

动态读取 `flake.nix`，排除以下类别：

- 自建软件包（源码在仓库内）
- 动态版本追踪（构建时获取最新版）
- 跟随 nixpkgs 版本（补丁覆盖）
- 补丁内硬编码版本（需手动检查）

其余外部包均自动纳入更新检查。

## hash 计算注意事项

完整规则见 `nix-flake-update-check`，要点：

- SRI hash 必须用标准 base64（`+` `/` `=`），不能使用 URL-safe 变体（`-` `_`）
- `fetchFromGitHub` 的 source hash **不能**从 GitHub archive tarball 预计算，必须通过 `nix build` 的 hash mismatch 错误获取
- `npmDepsHash` 清空时使用 `lib.fakeHash` 而非空字符串 `""`
- npm 包需两次 `nix build`：第一次获取 source hash，第二次获取 npmDepsHash

## 使用

由 AI 助手在用户要求「检查软件更新」或「更新包版本」时激活。
维护模式（`maintenance`）已注入本技能与 `nix-flake-update-check`。
