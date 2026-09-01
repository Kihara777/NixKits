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

每个新 session 启动时，首先执行完整的项目审计与评估，汇报发现。审计范围包括：所有组件状态（包、模块、overlay、补丁、技能）、文档一致性、CI/CD 状态，以及未提交变更。**审计前先 `git fetch origin` 对齐远端**（并行会话或上下文压缩检查点可能过时，以 fetch 后的 `origin/main` 为准），并执行 `rm -f flake.lock` 确保后续操作使用最新 nixpkgs。

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
- **本地操作前先移除 `flake.lock`**：执行 `nix build`、`nix develop`、`nix flake check` 等命令前，先执行 `rm -f flake.lock`。锁定的 nixpkgs snapshot 可能缺少部分包（如自建包 `godot-ai`），移除后 Nix 重新解析输入确保使用最新可用版本。CI 中无需此操作——CI 按 `check.yml` 配置独立解析。
- **`llama-cpp-ver` 输入是浮动追踪**：overlay `llama-cpp-rocm` 通过此输入动态获取上游最新版本号，不可锁定。
- **overlay `llama-cpp-rocm` 的 curried 形式是有意的**：`{ llama-cpp-ver }: (final: prev: ...)` — 勿改为标准 overlay。
- **新模块/包/overlay 加入 `flake.nix` 后必须 `nix flake check` 验证**。
- **Overlay 的 `patches` 列表必须用 `lib.unique` 去重**。

### 包

- **所有包的 `maintainers` 保持为空**：个人维护项目，不在 nixpkgs 维护者列表中。
- **预编译二进制包**：按 `stdenv.hostPlatform.system` 选择对应架构二进制（如 codewhale）。
- **SRI hash 格式**：`sha256-<base64>`。
- **npm 包用 `buildNpmPackage` + finalAttrs 模式**。
- **buildNpmPackage 的 vendored lock 必须与 `npmDepsHash` 自洽**：主构建把 src 的 `package-lock.json` 与 npm-deps 产物内 npm fixup 后的 lock 逐字节校验，不一致报 `npmDepsHash is out of date`。生成 vendored lock 必须采用 fixup 后版本（`prefetch-npm-deps --fixup-lockfile`，或从已实现的 `/nix/store/...-npm-deps/package-lock.json` 直接复制），再回填 hash。
- **npm tarball 的 devDependencies 引用未发布包时**：上游 monorepo 发布的 tarball 可能残留未发布内部包（registry 404）。postPatch 以纯 sed 删除该字段（patchPhase 无 node/npm），vendored lock 基于同样处理后的 package.json 生成——两者必须同源。
- **同源多通道（stable/alpha 等）仿 ruyi 薄包装模式**：主定义参数化（version/hash/npmDepsHash/lockFile 可覆盖），通道文件仅传覆盖参数（参见 `packages/dsh.nix` + `packages/dsh-alpha.nix`）。
- **Python 包用 `buildPythonApplication` + `pyproject = true`**。

### 模块

- **统一使用 `nixkits.*` 命名空间**（非 `services.*`）。历史遗留的 `services.opencode-telegram` 和 `services.ruyi` 已迁移并向后兼容。
- **每个模块必须有 `enable` 选项**，默认 `false`。
- **依赖外部模块时必须添加 `assertions`**（参见 `comfyui-rocm.nix`）。
- **避免硬编码路径**：优先从 config 推导（如 `hfCacheDir` 从 `config.users.users.<user>.home` 推导）。
- **dsh 模块的 alpha 语义**（`modules/dsh.nix`，dsh ≥ 0.1.2-alpha；详见 `docs/zh/dsh.md`「局域网访问 / 免认证入口 / 插件兼容」章节）：
  - web UI 入口按 Host authority 的 session cookie 认证——反代**不得重写 Host**（重写致永远 401），局域网 authority 必须列入 `trustedHosts`；LAN 认证 URL 经 `launchUrlFile` 捕获启动 token 生成，免认证入口经 `reverseProxy.autoAuth`（mod_magnet，禁用入口认证，仅可信局域网）。
  - shared RPC channel interceptor 互斥（每 channel 仅一个，`/api` 已被内置 typert-gateway 独占）——第三方 dsh 插件提供 RPC 方法必须用精确 fetch route（`ctx.connection.fetch.register`，`/api/<plugin>/<method>`）自实现 `{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` envelope；插件 peer 依赖（`@deepseek-ai/dsh-tools` 等）必须与宿主 dsh 通道对齐。

### 预设

`packages/dsh-nixos-shell/presets/` 下的两个 Agent 预设（NixOS模式 → 维护模式）是**派生关系**，不是两份独立配置：

- **维护模式必须完整派生自 NixOS模式**：`maintenance-mode/agent.cordis.yml` = `nixos-mode/agent.cordis.yml` 末尾追加固定的 `maintenance-skills` 行块（含注释），除此之外不得有任何差异；两预设的 `skills/` 目录必须逐文件一致。
- **修改 nixos 模式后必须同步维护模式**：更新 `nixos-mode/` 的任意文件（组合、元数据、技能）后，立即把相同改动镜像到 `maintenance-mode/`。
- **漂移检查**：`develop/check-preset-derivation.py` 校验上述派生关系，已挂入 `nix flake check`（CI 每次 push 执行）；漂移时检查失败，修复后才能提交。刻意变更追加块本身时，同步更新脚本内 `MAINTENANCE_DELTA` 常量。
- **回车键行为**：会话内的「回车换行 + Shift+回车发送」交换行为由 dsh-api-balance 客户端插件的「⚙ 设置 → 界面」开关实现（全局生效、浏览器 localStorage 持久化，默认开启；DSH 原生为回车发送）；预设组合文件本身不含该逻辑，无需在预设间同步。

### 文档

- **多语言体系**：zh（基准）→ en / ja。扩展语言通过 `skills/translate-*/` 自动发现，禁止硬编码扩展语言列表或数量。
- **文档模板**：参见 `skills/write-project-docs/templates.md`。
- **语言切换器**：各语言使用自身 `display_name`，当前语言不加链接。
- **`nixkits` 为示例 flake input 名**（已从 `nix-kits` 全局替换）。
- **MAINTENANCE.md**：
  - 基于提交 SHA 全局去重（每个 SHA 只出现一次）。
  - 节标题时间戳必须精确到秒（git 提交时间），禁止 `T00:00:00` 占位符。
  - 所有已注册语言同步更新。
- **插件独立展示**：`dsh-*` 组件（插件与 Agent 预设）在 README 的「插件」章节单独列出（四语同步），不混入「软件」表；DSH 自身的包（`dsh`）仍归「软件」。

### 补丁

- **补丁必须是干净 diff**：不含 `flake.lock`、自身副本等 artifact。参考 `patches/ruyi-nixos-compat.patch`（426 行清洁版）。
- **补丁操作集中到包内 `postPatch`**：overlay 仅负责挂载 patch，具体适配逻辑在 `packages/*.nix` 中。

### 技能

- **技能目录结构**：`skills/<name>/SKILL.md` + 可选配套文件（`dictionary.md`、`templates.md`）。
- **SKILL.md 保持聚焦**：仅包含 AI 执行所需的最小上下文。词典、模板、检查清单等独立数据拆为配套文件；纯执行流程不强制拆分，允许适当长度。
- **自动发现契约**：`translate-*` 类技能通过 frontmatter 中的 `language_code`、`display_name`、`base_language` 被 `write-project-docs` 自动发现。
- **dsh 不是技能安装目标**：`nixkits-skills` 仅安装到 opencode/codewhale/codex/openclaw/agents；dsh 的 NixOS 场景能力由 `dsh-nixos-shell` 插件提供（`nixos_shell` 执行器 + `nixos_cli` 诊断）。技能内容保留在 `skills/` 作为其他助手的安装源。

## 本机部署

维护者本机以 path-input 方式引用本仓库（`/etc/nixos`）：

- **仓库变更后必须重锁**：`nix flake lock /etc/nixos --update-input nixkits` 并清 eval 缓存，否则 `nixos apply` 静默 no-op（path-input 锁定后不自动拾取仓库新状态）。
- **部署命令**：`nixos apply -y /etc/nixos`（nixos 0.16.1 无 `rebuild` 子命令）。
- **`nix build --no-link` 产物可能被 GC 立即回收**：需要产物时同调用内复制出 store，或改用带链接的构建。

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
构建由独立的 `build-<包>-<架构>.yml` workflow 完成：每个 workflow 调用共享的可复用 workflow `build-package.yml`，构建后经 `cachix-action` 推送到 Cachix 二进制缓存。覆盖情况以实际 workflow 文件为准（部分包受上游限制无 riscv64 构建，如 blender-mcp、obs-bilibili-stream；godot-ai 与 dsh 当前无独立构建 workflow）。CI 状态徽章由 `ci-summary.yml` 生成（`gh-pages/ci-status.json`，每小时刷新）。

## 二进制缓存

CI 自动构建支持的架构组合并推送到 Cachix。`nixkits-check-updates` 技能执行后，确认 CI 通过即可，无需本地额外操作。