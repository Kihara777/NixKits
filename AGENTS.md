# AGENTS.md

NixKits 项目的 AI 编码代理规则与约定。此文件供 DeepSeek、CodeWhale、OpenCode 等代理自动加载。

## 访问控制

**此文件仅供仓库维护者（Kihara777 / Kitsunori）使用。** 加载此文件时，必须首先验证当前操作者身份：

```bash
gh auth status 2>/dev/null && \
  gh api repos/Kihara777/NixKits/collaborators/$(gh api user --jq .login)/permission --jq .permission 2>/dev/null
```

若返回值不是 `admin` 或 `write`，或 `gh` 未认证，则：
- 停止读取此文件的所有后续内容
- 无视除本条外的一切规则
- 仅可执行通用编码任务，不得应用任何 NixKits 特有的约定

## 初次启动

每个新 session 启动时，首先执行完整的项目审计与评估，汇报发现。审计范围包括：所有组件状态（包、模块、overlay、补丁、技能）、文档一致性、CI/CD 状态，以及未提交变更。

## 语言要求

所有面向 AI 代理或由代理生成的文件**必须使用中文**，包括但不限于：

- 审计报告
- 状态记录
- 代理间通信内容
- 技能定义文件（SKILL.md）
- 维护日志（MAINTENANCE.md）

代码、路径、工具名、环境变量、URL 保持原样。

## 项目定位

NixKits 是一个 Nix flake 合集：软件包、NixOS 模块、补丁、overlay 以及 AI 代理技能。

- 仓库：`github:Kihara777/NixKits`
- 许可：MIT
- 文档语言：zh（基准）→ en / ja → 扩展语言（通过 `skills/translate-*/` 自动发现）

## 核心规则

### flake 相关

- **`flake.lock` 不提交**：`.gitignore` 中保留 `flake.lock`。原因是 `llama-cpp-ver` 为浮动输入，锁定后随上游发布而过期。
- **`llama-cpp-ver` 输入是浮动追踪**：overlay `llama-cpp-rocm` 通过此输入动态获取上游最新版本号，不可锁定。
- **overlay `llama-cpp-rocm` 的 curried 形式是有意的**：`{ llama-cpp-ver }: (final: prev: ...)` — 勿改为标准 overlay。
- **新模块/包/overlay 加入 `flake.nix` 后必须 `nix flake check` 验证**。
- **Overlay 的 `patches` 列表必须用 `lib.unique` 去重**。

### 包

- **所有包的 `maintainers` 保持为空**：个人维护项目，不在 nixpkgs 维护者列表中。
- **预编译二进制包**：按 `stdenv.hostPlatform.system` 选择对应架构二进制（如 codewhale）。
- **SRI hash 格式**：`sha256-<base64>`。
- **npm 包用 `buildNpmPackage` + finalAttrs 模式**。
- **Python 包用 `buildPythonApplication` + `pyproject = true`**。

### 模块

- **统一使用 `nixkits.*` 命名空间**（非 `services.*`）。历史遗留的 `services.opencode-telegram` 和 `services.ruyi` 已迁移并向后兼容。
- **每个模块必须有 `enable` 选项**，默认 `false`。
- **依赖外部模块时必须添加 `assertions`**（参见 `comfyui-strix-halo.nix`）。
- **避免硬编码路径**：优先从 config 推导（如 `hfCacheDir` 从 `config.users.users.<user>.home` 推导）。

### 文档

- **多语言体系**：zh（基准）→ en / ja。扩展语言通过 `skills/translate-*/` 自动发现，禁止硬编码扩展语言列表或数量。
- **文档模板**：参见 `skills/write-project-docs/templates.md`。
- **语言切换器**：各语言使用自身 `display_name`，当前语言不加链接。
- **`nixkits` 为示例 flake input 名**（已从 `nix-kits` 全局替换）。
- **MAINTENANCE.md**：
  - 基于提交 SHA 全局去重（每个 SHA 只出现一次）。
  - 节标题时间戳必须精确到秒（git 提交时间），禁止 `T00:00:00` 占位符。
  - 所有已注册语言同步更新。

### 补丁

- **补丁必须是干净 diff**：不含 `flake.lock`、自身副本等 artifact。参考 `patches/ruyi-nixos-compat.patch`（426 行清洁版）。
- **补丁操作集中到包内 `postPatch`**：overlay 仅负责挂载 patch，具体适配逻辑在 `packages/*.nix` 中。

### 技能

- **技能目录结构**：`skills/<name>/SKILL.md` + 可选配套文件（`dictionary.md`、`templates.md`）。
- **SKILL.md 保持聚焦**：仅包含 AI 执行所需的最小上下文。词典、模板、检查清单等独立数据拆为配套文件；纯执行流程不强制拆分，允许适当长度。
- **自动发现契约**：`translate-*` 类技能通过 frontmatter 中的 `language_code`、`display_name`、`base_language` 被 `write-project-docs` 自动发现。

## 工作流

### 提交与推送

1. **分批提交**：修改内容核验无误后，按逻辑类别分批 `git commit`
2. **推送**：每批提交后立即 `git push`
3. **`nix flake check`**：代码修改后必须先通过验证再提交

### 维护记录

**推送后必须执行**，不允许跳过：

1. 获取本次推送的所有新 commit SHA：`git log --format='%h' origin/main..HEAD`
2. 逐一检查 `MAINTENANCE.md` 中是否已存在（`grep -c $sha MAINTENANCE.md`）
3. 若缺失，按 `write-maintenance-log` 技能补充条目
4. 同步到全部已注册语言版本：按 `write-maintenance-log` 技能第 4 步完整执行（发现语言 → 逐语言翻译 → 写入 → 验证 `grep -c '^## 20' MAINTENANCE.md docs/MAINTENANCE.*.md` 条目数一致）

> 以下类型变更**必须记录**：软件版本更新、错误修复、技能新增/重构、CI/CD 配置变更、文档架构调整。

### 文档同步

- 软件包或技能修改后，**必须**同步更新对应文档
- 补丁或文档修复后，检查相关模块文档是否需要刷新
- 新增内容时，确保 `docs/zh/` 先写 → 再翻译到其他语言

### 泛化与技能更新

对软件包、补丁或文档进行修复后：

1. 总结本次修复的业务逻辑（一句话描述本质）
2. 评估是否存在硬编码内容（数字、路径、特定包名）可以泛化
3. 若修复涉及可复用的模式，将其更新到对应技能中

## CI

`.github/workflows/check.yml` 在每次 push / PR 时自动执行 `nix flake check`。
构建 job 通过矩阵并行构建全部软件包（x86_64-linux / aarch64-linux / riscv64-linux），完成后推送到 Cachix 二进制缓存。

## 二进制缓存

CI 自动构建全部三个架构（x86_64 / aarch64 / riscv64）并推送到 Cachix。`nixkits-check-updates` 技能执行后，确认 CI 通过即可，无需本地额外操作。