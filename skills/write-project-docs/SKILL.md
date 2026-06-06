---
name: write-project-docs
description: Use when the user wants to write or regenerate complete project documentation following the NixKits style — multi-language (zh/en/ja), concise, table-driven, with language-switcher headers and module-classification READMEs. Covers README, per-module docs, and skill docs for any project.
---

# Write Project Documentation (NixKits Style)

Generates a complete multi-language documentation system for any project, following the NixKits documentation conventions.

## When to Use

- User asks to "write documentation" or "generate docs" for a project
- User wants docs in the NixKits style (concise, multi-language, table-driven)
- User has an existing project with modules/packages/services that need documenting

## Conventions (NixKits Style)

### Directory Structure

```
<project>/
├── README.md          # Primary language README
├── README.en.md       # English README
├── README.ja.md       # Japanese README
├── docs/
│   ├── zh/            # Chinese docs
│   │   ├── <module>.md
│   │   └── skills/    # Skill docs subdirectory
│   ├── en/            # English docs
│   └── ja/            # Japanese docs
```

### Per-Module Doc Template

```markdown
# <module-name>

[中文](<module>.md) | [English](../en/<module>.md) | [日本語](../ja/<module>.md)

<one-line description>

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

- Language-switcher line uses relative paths appropriate to each language directory
- zh files: `[中文](file.md) | [English](../en/file.md) | [日本語](../ja/file.md)`
- en files: `[中文](../zh/file.md) | [English](file.md) | [日本語](../ja/file.md)`
- ja files: `[中文](../zh/file.md) | [English](../en/file.md) | [日本語](file.md)`

### Per-Skill Doc Template

```markdown
# <skill-name> (Skill)

[中文](<skill>.md) | [English](../../en/skills/<skill>.md) | [日本語](../../ja/skills/<skill>.md)

> <one-line summary>

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/<skill>.md` |

## 功能

- <feature list>

## 使用

<trigger condition or usage>
```

### README Template

```markdown
# <Project Name>

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

<one-line project description>

## <Category 1>

| 模块 | 说明 | 文档 |
|------|------|------|
| ... | ... | [docs/zh/...](docs/zh/...) |

## <Category N>

...

## 作者

<author section>

## 许可

<license>
```

### Writing Rules

- **Zero fluff** — no introductory rhetoric, no "welcome to", no "this document describes"
- **Tables over prose** — use `基本信息` tables for metadata, comparison tables for options
- **Code blocks are complete** — every code block should be copy-paste runnable
- **Technical terms stay in English** — even in zh/ja docs
- **Warnings use blockquotes** — `> **⚠️ 警告**` format
- **Chinese section titles use 2- or 4-character words** — prefer concise, symmetric-length terms for visual
  rhythm (e.g., `组件` not `软件包`, `基本信息` not `基础配置信息`). Category headings in
  Chinese READMEs should match this cadence.
- **No TOC** — documents are short enough to scan

## Workflow

### Step 1: Assess the Project

Read all available metadata about modules/packages/services:
- Module definition files (e.g., `info.json`, `package.json`, `Cargo.toml`)
- Existing `README.md` or `AGENTS.md`
- Configuration files (e.g., `flake.nix`, `compose.yaml`)
- Source directory structure

Extract for each module:
- Name (used as filename)
- Description (one sentence)
- Type (service / static / library / skill)
- Dependencies
- Installation command
- Usage examples

### Step 2: Classify Modules

Group modules into functional categories. Common patterns:
- Infrastructure / core services
- User-facing services
- Proxy / cache
- Navigation / entry points
- Static content / links
- Skills / operational guides

### Step 3: Create Directory Structure

```bash
mkdir -p docs/{zh,en,ja}/skills
```

### Step 4: Write README (Primary Language First)

- Language switcher at top
- Brief project description
- Category sections with tables (Module | Description | Docs)
- Author section
- License

Then translate to other languages. README links point to the corresponding language's doc directory.

### Step 5: Write Per-Module Docs

For each module, create 3 files (zh/en/ja). Write the primary language version first as the reference, then translate.

Key sections:
1. **基本信息** table — type, key attributes
2. **安装** — install command
3. **引用** — how to reference/use
4. Additional sections as needed (配置, provides, 使用, 常见问题)

### Step 6: Write Skill Docs

For each skill/operational guide, create 3 files in the `docs/{zh,en,ja}/skills/` subdirectory.

### Step 7: Verify

- Count files: `N modules × 3 languages + N skills × 3 languages + 3 READMEs`
- Spot-check language switcher links
- Verify all README links resolve to existing files
- Check that technical terms are preserved across languages

#### 日语特有检查

- 每个日语版文档必须包含 `## 基本情報` 表格（`項目 | 値` 格式），与其他日语文档风格一致

#### 新增条目的对称性检查

当项目中新增一个模块、补丁或服务时，确保以下全部就位：

- [ ] `docs/zh/<name>.md` — 存在且内容完整
- [ ] `docs/en/<name>.md` — 存在且内容完整（翻译）
- [ ] `docs/ja/<name>.md` — 存在且内容完整（翻译），包含 `## 基本情報`
- [ ] `README.md` — 对应分类表中已添加行
- [ ] `README.en.md` — 对应分类表中已添加行
- [ ] `README.ja.md` — 对应分类表中已添加行

常见遗漏模式：
- 添加了 zh/en 文档却忘了 ja 文档
- 只在一种语言的 README 中加了表行（通常是主语言版本），漏了另外两种
- 日语文档缺 `## 基本情報` 标准节

## Parallelization

Use sub-agents for large projects. Batch modules by category and dispatch one sub-agent per category. Each sub-agent writes all 3 language versions for its assigned modules. Skills can be handled by a separate sub-agent.

Typical sub-agent breakdown for a project with ~25 modules and ~20 skills:
- Agent A: Infrastructure modules (5 modules × 3 langs = 15 files)
- Agent B: Service modules (8 modules × 3 langs = 24 files)
- Agent C: Proxy/navigation/static modules (12 modules × 3 langs = 36 files)
- Agent D: Skills (20+ skills × 3 langs = 60+ files)

## Anti-Patterns

- Do NOT hardcode project-specific module names in the skill body
- Do NOT assume the project uses Docker / Nix / a specific toolchain
- Do NOT write documentation before reading the project's actual metadata
- Do NOT skip the verification step
- Do NOT write English docs in Chinese or vice versa — match the target language directory
- Do NOT add a README table row in only one language — all three READMEs must be updated together
- Do NOT skip the `## 基本情報` table in Japanese docs — every ja doc requires it
