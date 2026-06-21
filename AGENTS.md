# AGENTS.md

NixKits 项目的 AI 编码代理规则与约定。此文件供 DeepSeek、CodeWhale、OpenCode 等代理自动加载。

## 项目定位

NixKits 是一个 Nix flake 合集：软件包、NixOS 模块、补丁、overlay 以及 AI 代理技能。

- 仓库：`github:Kihara777/NixKits`
- 许可：MIT
- 文档语言：zh（基准）→ en / ja / katalish / pcn

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

- **5 语言体系**：zh（根目录无后缀）→ en / ja → katalish / pcn。本地化文件均在 `docs/` 下。
- **文档模板**：参见 `skills/write-project-docs/templates.md`。
- **语言切换器**：各语言使用自身 `display_name`，当前语言不加链接。
- **`nixkits` 为示例 flake input 名**（已从 `nix-kits` 全局替换）。
- **MAINTENANCE.md**：
  - 基于提交 SHA 全局去重（每个 SHA 只出现一次）。
  - 节标题时间戳必须精确到秒（git 提交时间），禁止 `T00:00:00` 占位符。
  - 5 语言同步更新。

### 补丁

- **补丁必须是干净 diff**：不含 `flake.lock`、自身副本等 artifact。参考 `patches/ruyi-nixos-compat.patch`（426 行清洁版）。
- **补丁操作集中到包内 `postPatch`**：overlay 仅负责挂载 patch，具体适配逻辑在 `packages/*.nix` 中。

### 技能

- **技能目录结构**：`skills/<name>/SKILL.md` + 可选配套文件（`dictionary.md`、`templates.md`）。
- **SKILL.md 目标行数**：~60-80 行。大型数据（词典、模板）拆分为独立文件。
- **自动发现契约**：`translate-*` 类技能通过 frontmatter 中的 `language_code`、`display_name`、`base_language` 被 `write-project-docs` 自动发现。

## 审计备忘

以下为历史审计中确认的**非缺陷**：

| 项目 | 说明 |
|------|------|
| `flake.lock` 不在版本控制 | 浮动输入 `llama-cpp-ver` 决定 |
| `maintainers` 全部为空 | 维护者有意保持 |
| `llama-cpp-rocm` overlay 非标准形式 | curried 形式是有意的，配合 flake 使用 |

## 工作流

```
1. 修改代码
2. nix flake check --no-build
3. 如涉及文档，同步 5 语言
4. 如涉及新版本/新功能，更新 MAINTENANCE.md（精确时间戳）
5. 如涉及 SKILL.md 变更，同步 docs/<lang>/skills/
```

## CI

`.github/workflows/check.yml` 在每次 push / PR 时自动执行 `nix flake check`。
构建 job 通过矩阵并行构建 6 个软件包（x86_64-linux / aarch64-linux），完成后推送到 Cachix 二进制缓存。

## 缓存

`cachix use nixkits`。flake 通过 `nixConfig` 自动声明缓存端点，消费者无需手动配置。

## 多架构缓存

当 `nixkits-check-updates` 技能检测到操作者在仓库目录内、且对仓库有推送权限时，
应在版本更新后执行多架构构建与推送：

1. 检测 `gh auth status` 验证身份
2. 检测推送权限：`gh api repos/Kihara777/NixKits/collaborators/$USER/permission | jq -r .permission` 为 `admin` 或 `write`
3. 尝试本地多架构构建：
   ```
   nix build ".#<pkg>" --system aarch64-linux  # 需 binfmt 或 ARM runner
   cachix push nixkits <result>
   ```
4. CI 已通过 `ubuntu-24.04-arm` runner 自动覆盖 aarch64-linux