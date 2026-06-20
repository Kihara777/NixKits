---
name: write-project-docs
description: 按 NixKits 风格为任意项目编写或重新生成完整的多语言文档 — 简洁、表驱动、含语言切换器标题和模块分类 README。覆盖 README、各模块文档及技能文档。
---

# 项目文档编写（NixKits 风格）

为任意项目生成完整的多语言文档体系，遵循 NixKits 文档规范。

## 何时使用

- 用户要求"编写文档"或"生成文档"
- 用户希望采用 NixKits 风格（简洁、多语言、表驱动）
- 用户有含模块/包/服务的现有项目需要文档化

## 自动发现契约

本技能通过纯自然语言约定发现语言扩展：

1. **扫描** — 在 `skills/translate-*/` 目录下查找所有翻译技能
2. **读取** — 解析各 SKILL.md frontmatter 中的 `language_code`（目录名/文件扩展名）、`display_name`（语言切换器标签）、`base_language`（翻译源语言）三个字段
3. **注册** — 自动将发现的语言扩展纳入目录结构、语言切换器、for 循环、列名映射等生成逻辑。各翻译技能的 SKILL.md 正文中定义转换规则和内容映射表。

## 规范（NixKits 风格）

### 目录结构

```
<project>/
├── README.md          # 主语言 README（中文）
├── MAINTENANCE.md     # 维护记录（中文）
├── docs/
│   ├── README.en.md   # 英文 README（本地化文件移入 docs/）
│   ├── README.ja.md   # 日文 README
│   ├── MAINTENANCE.en.md  # 英文维护记录
│   ├── MAINTENANCE.ja.md  # 日文维护记录
│   ├── zh/            # 中文文档
│   │   ├── <module>.md
│   │   └── skills/    # 技能文档子目录
│   ├── en/            # 英文文档
│   └── ja/            # 日文文档
```

> **规则**：根目录仅保留中文（无语言后缀）`.md` 文件。所有本地化版本（`*.en.md`、`*.ja.md`、`*.katalish.*`、`*.pcn.*`）
> 移入 `docs/` 目录，文件名保持不变。扩展语言（`translate-*`）通过扫描 `skills/translate-*/SKILL.md` frontmatter 中的 `language_code` 自动发现。

### 模块文档模板

```markdown
# <module-name>

[中文](<module>.md) | [English](../en/<module>.md) | [日本語](../ja/<module>.md)

<一行描述>

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | <type> |
| ... | ... |

## 安装

<install command>

## 引用

<reference / usage>
```

- 语言切换器行使用各语言目录对应的相对路径
- 根目录无后缀文件指向 `docs/` 内的本地化版本：
  `[中文](README.md) | [English](docs/README.en.md) | [日本語](docs/README.ja.md)`
- docs 内的本地化文件指向根目录：`[中文](../README.md) | ...`
- zh 子目录文件：`[中文](file.md) | [English](../../en/file.md) | [日本語](../../ja/file.md)`
- en 子目录文件：`[中文](../../zh/file.md) | [English](file.md) | [日本語](../../ja/file.md)`
- ja 子目录文件：`[中文](../../zh/file.md) | [English](../../en/file.md) | [日本語](file.md)`
- 扩展语言（`skills/translate-*/` 自动发现）子目录文件：
  语言切换器按以下规则生成，不硬编码特定语言：
  - 所有已注册语言按声明顺序排列（`zh` → `en` → `ja` → 各扩展语言按发现顺序）
  - 其他语言的标签使用**固有名称**加对应相对路径链接
  - 当前语言自身的标签使用该语言的 `display_name`（语言自称），纯文本不加链接
  - 相对路径根据目录层级自动计算（同级 `../<lang>/`、上级 `../../<lang>/` 等）

### 技能文档模板

```markdown
# <skill-name> (Skill)

[中文](<skill>.md) | [English](../../en/skills/<skill>.md) | [日本語](../../ja/skills/<skill>.md)

> <一行摘要>

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/<skill>.md` |

## 功能

- <功能列表>

## 使用

<触发条件或使用方法>
```

### README 模板

```markdown
# <Project Name>

[中文](README.md) | [English](docs/README.en.md) | [日本語](docs/README.ja.md)

<一行项目描述>

## <分类 1>

| 模块 | 说明 | 文档 |
|------|------|------|
| ... | ... | [docs/zh/...](docs/zh/...) |

## <分类 N>

...

## 开发

提供 `nix develop` 即用环境。首先添加 registry：

```bash
nix registry add <project> <remote-url>
```

| 包 | `nix develop` |
|-----|---------------|
| <pkg> | `nix develop <project>#<pkg>` |

## 作者

<作者信息>

## 许可

<license>
```

### 编写规则

- **零废话** — 没有引导性修辞，没有"欢迎来到"，没有"本文档描述……"
- **表格优先于段落** — 用 `基本信息` 表格展示元数据，用对照表展示选项
- **代码块完整可运行** — 每个代码块应可直接复制粘贴执行
- **技术术语保持英文** — 即使在中文和日文文档中
- **语言切换器标签规则** —
  - 其他语言的入口保持固有名称不作本地化：
    `中文`、`English`、`日本語`、`Katalish`、`Pseudo-Chinese`。
    不翻译为 `ｲﾝｸﾞﾘｯｼｭ`、`Chinese`、`Japanese` 等形式。
  - 当前语言自身的标签使用该语言的 `display_name`（语言自称）：
    katalish → `ｶﾀﾘｯｼｭ`、pcn → `偽中国語`。
    自身标签不加链接（纯文本），其他语言均附相对路径链接
- **警告使用引用块** — `> **⚠️ 警告**` 格式
- **中文标题使用 2 或 4 字词** — 优先使用简洁、长度对称的词汇以保证视觉节奏
  （如 `组件` 而非 `软件包`，`基本信息` 而非 `基础配置信息`）。中文 README 中的分类标题应遵循此韵律。
- **不生成目录** — 文档足够短，可直接扫读
- **目标行数 ~40-60 行** — 补丁/模块文档以 `rcc-fix.md`（~39 行）为标杆。
  超过 80 行通常意味着存在可压缩的叙述段落或冗余的子节。
- **标准节结构** — 补丁/模块文档遵循四段式：
  `基本信息` → `修正内容`/`功能` → `安装` → `注意`（按需）。
  技术细节、故障排除、参考资料全部压缩为 `## 注意` 下的 bullet，
  不要分为独立的 `## 技术细节`、`## 问题排查`、`## 参考` 等节

## 工作流程

### 第 1 步：评估项目

读取所有可用的模块/包/服务元数据：
- 模块定义文件（如 `info.json`、`package.json`、`Cargo.toml`）
- 已有的 `README.md` 或 `AGENTS.md`
- 配置文件（如 `flake.nix`、`compose.yaml`）
- 源码目录结构

对每个模块提取：
- 名称（用作文件名）
- 描述（一句话）
- 类型（service / static / library / skill）
- 依赖
- 安装命令
- 使用示例

### 第 2 步：模块分类

按功能类别分组。**优先从项目配置自动提取分类**，而非手动判断。

对于 Nix flake 项目，通过以下入口自动发现类别：

| 分类 | 发现方式 | 示例 |
|------|---------|------|
| 软件 | `packages/*.nix` 中的 `callPackage` 调用 | `packages/ruyi.nix` |
| 模块 | `modules/*.nix` 中的 NixOS 模块定义 | `modules/ruyi.nix` |
| 覆盖层 | `overlays/*.nix` 中的 overlay 函数 | `overlays/ruyi-nixos-compat.nix` |
| 技能 | `skills/*/SKILL.md` 中的 frontmatter | `skills/write-project-docs/SKILL.md` |
| 开发 | `devShells` 在 `flake.nix` 中的定义 | `devShells.ruyi` |

对于非 Nix 项目，按目录/文件模式类推（如 `src/`、`services/`、`tools/`）。

常见模式：
- 基础设施 / 核心服务
- 用户面服务
- 代理 / 缓存
- 静态内容 / 链接
- 开发 / devShell
- 技能 / 操作指南

### 第 3 步：创建目录结构

```bash
mkdir -p docs/{zh,en,ja}/skills docs/{katalish,pcn}/skills  # ← 扩展语言
```

### 第 4 步：编写 README（先写主语言版本）

- 顶部语言切换器
- 简要项目描述
- 分类段，各含表格（模块 | 说明 | 文档）
- 作者段
- 许可

然后翻译到其他语言。README 链接指向对应语言的文档目录。

### 第 5 步：编写各模块文档

每个模块创建 3 个文件（zh/en/ja）。先写主语言版本作为基准，再翻译。

对于追加语言翻译（如 Katalish、Pseudo-Chinese），按 `translate-*` 命名约定自动发现语言扩展技能：

```
# 自动发现算法：
for dir in skills/translate-*/; do
  # 读取 SKILL.md frontmatter 中的 language_code / display_name / base_language
  # → 注册为可用语言，纳入文档生成流程
done
```

各 translate-* 技能的 SKILL.md frontmatter 中声明 `language_code`（目录名 / 文件扩展名）、`display_name`（语言自称，用于该语言文档中自身不加链接的纯文本标签）、`base_language`（翻译源语言）三个字段。文档撰写技能按命名约定扫描 `skills/translate-*/` 自动注册所有语言扩展。

自动发现后：
- 目录结构扩展 `docs/<code>/` 和 `docs/<code>/skills/`
- 语言切换器中该语言的入口使用固有名称（如 `Katalish`、`Pseudo-Chinese`），
  而非 `display_name`。`display_name` 仅用于该语言文档中自身不加链接的纯文本标签。
- 根文件和多语言 README 中：`[<固有名称>](docs/README.<code>.md)`
- 自身子目录文件中：自身标签 = `<display_name>`（纯文本），其他语言 = 固有名称
- 语言 for 循环扩展为多语言遍历
- 基本信息表格列名由各 translate-* 技能的规则定义

核心段：
1. **基本信息** 表格 — 类型、关键属性
2. **安装** — 安装命令
3. **引用** — 如何引用/使用
4. 按需追加段（配置、provides、使用、常见问题）

### 第 6 步：编写技能文档

对每个技能/操作指南，在 `docs/{zh,en,ja}/skills/` 子目录下各创建 3 个文件。

技能文档遵循统一模板：

```markdown
# <skill-name> (Skill)

[语言切换器]

> 一句话摘要

## 基本信息（ja: 基本情報 / en: Info）

表格：类型、路径

## 功能（ja: 機能 / en: Features）

bullet list — 技能的关键能力

## 使用（ja/en: Usage）

触发条件 — 什么情况下 AI 助手应激活此技能
```

#### 技能文档同步规则

当 `SKILL.md` 发生变更时，对应的多语文档 **必须同步更新**。
用时间戳快速定位过时文档：

```bash
# 对比 SKILL.md 与多语文档的修改时间
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ -f "$doc" ] || continue
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

过时文档更新时，保持多语结构一致：中文为基准翻译，各语言沿用各自列名
（`基本信息` → `Info` / `基本情報`、`功能` → `Features` / `機能` 等）。

### 第 7 步：验证

- 统计文件数：`N 个模块 × 3 种语言 + N 个技能 × 3 种语言 + 3 个 README`
- 抽查语言切换器链接
- 验证所有 README 中的链接指向存在的文件
- 检查各语言版本间技术术语是否一致

#### 技能文档时效性检查

- 运行 staleness check 确保所有 `docs/{zh,en,ja}/skills/*.md` 未被对应的 `SKILL.md` 超过
- 过时文档按技能文档模板更新：中文基准 → 英文翻译 → 日文翻译
- 各语言列名映射：`基本信息` → `Info` / `基本情報`、`功能` → `Features` / `機能`

#### 基本信息节完整性检查

- 所有语言版本的文档都必须包含基本信息表格，列名因语言而异：
  - 中文：`## 基本信息`（`项目 | 值`）
  - 英文：`## Info`（`Item | Value`）
  - 日文：`## 基本情報`（`項目 | 値`）

#### 新增条目的对称性检查

当项目中新增一个模块、补丁或服务时，确保以下全部就位：

- [ ] `docs/zh/<name>.md` — 存在且内容完整
- [ ] `docs/en/<name>.md` — 存在且内容完整（翻译）
- [ ] `docs/ja/<name>.md` — 存在且内容完整（翻译），包含 `## 基本情報`（`項目 | 値`）
- [ ] `README.md` — 对应分类表中已添加行
- [ ] `docs/README.en.md` — 对应分类表中已添加行
- [ ] `docs/README.ja.md` — 对应分类表中已添加行

常见遗漏模式：
- 添加了 zh/en 文档却忘了 ja 文档
- 只在一种语言的 README 中加了表行（通常是主语言版本），漏了另外两种
- 文档缺基本信息表格（任一种语言）

## 并行化

大型项目使用子代理。按类别分批模块，每个子代理负责一个类别。
每个子代理为其分配的模块编写全部 3 个语言版本。技能可由单独的子代理处理。

约 25 个模块和 20 个技能的典型子代理拆分：
- 代理 A：基础设施模块（5 个模块 × 3 语言 = 15 个文件）
- 代理 B：服务模块（8 个模块 × 3 语言 = 24 个文件）
- 代理 C：代理/导航/静态模块（12 个模块 × 3 语言 = 36 个文件）
- 代理 D：技能（20+ 个技能 × 3 语言 = 60+ 个文件）

## 反模式

- 不要把项目特定的模块名硬编码到技能正文中
- 不要假设项目使用 Docker / Nix / 特定工具链
- 不要在读取项目实际元数据之前就编写文档
- 不要跳过验证步骤
- 不要用英语写中文文档，反之亦然 — 必须匹配目标语言目录
- 不要只在一种语言的 README 中添加表行 — 三个 README 必须同步更新
- 不要在任何语言中省略基本信息节 — 中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報` 缺一不可
- 不要写技术文章式的长文档 — 避免独立的技术细节、故障排除、参考章节。
  所有补充信息压缩为 `## 注意` bullet。目标行数 ~40-60 行
- 不要使用 `## 背景`、`## 技术细节`、`## 问题排查`、`## 参考` 等独立深章节 —
  这些是 NixKits 文档的反模式（参考 `comfyui-strix-halo` 修复案例）
- 补丁/模块源码变更后，文档的「修正内容」/「功能」列表 **必须同步更新**，
  每条 bullet 应直接对应源码中的一处实际修改
- 不要让文档与源码实际变更不同步 — 过时的 bullet 或重复条目会误导用户
