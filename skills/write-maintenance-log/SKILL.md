---
name: write-maintenance-log
description: 按 NixKits 规范撰写或更新 MAINTENANCE.md 维护日志。支持软件更新记录和错误修复记录两种类型，自动关联 git commit、生成摘要、三语同步。
---

# 维护日志撰写

按 NixKits 统一规范撰写 `MAINTENANCE.md` 维护记录，确保格式一致、信息完整、三语同步。

## 触发场景

- **软件更新完成**：`nixkits-check-updates` 技能执行后自动触发
- **错误修复完成**：用户要求「记录本次修复」「写入维护日志」时触发
- **手动调用**：用户要求「更新维护日志」或「补全维护记录」

## 记录类型

### 类型 1：软件版本更新

当上游发布新版本并完成构建时，记录以下字段：

- 日期时间（ISO 8601 精确秒，JST 时区）
- 一句话摘要（允许从上游 release note 摘录）
- 关联提交表（所有相关 commit id 及说明）
- 软件版本表（包名、旧版本、新版本）
- 有变更的 hash（省略无变更项）

### 类型 2：错误修复

当修复了影响功能的 bug（即使无版本变更）时，记录：

- 日期时间
- 一句话摘要（描述修复内容）
- 关联提交表

> **判断标准**：`git log` 中 `fix(...)` 或 `feat(...)` 类型、且涉及包/模块功能变更的提交应记录。纯文档 (`docs(...)`) 不记录。

## 格式规范

### 章节标题

ISO 8601 精确到秒的日期时间，JST 时区（+09:00）。时间来源必须为 `git log -1 --format="%ai"` 提取的实际 commit 时间，**禁止使用占位符**（如 `T00:00:00`）。

```markdown
## 2026-06-14T07:56:11+09:00
```

### 行文标准

- **语言**：中文（`MAINTENANCE.md`）、英文（`docs/MAINTENANCE.en.md`）、日文（`docs/MAINTENANCE.ja.md`）
- **标题**：zh `# 维护日志`、en `# Maintenance Log`、ja `# メンテナンスログ`
- **摘要**：以粗体 `**摘要**`（en: `**Summary**`, ja: `**概要**`）开头，一句话说明变更。格式为 `<包名> <版本号> — <一句话简述>`
  - 多个包用「；」分隔
  - 新增包：`<包名> <版本号> — 新包`
  - 无版本变更的修复：`fix(<包名>): <简述>`
- **提交表**：表头 `| 提交 | 说明 |`（en: `| Commit | Description |`, ja: `| コミット | 説明 |`）
  - 关联提交按时间升序排列
  - commit id 使用短格式（7 位）
- **软件版本表**：表头 `| 软件名 | 旧版本 | 新版本 |`（en: `| Package | Old | New |`, ja: `| パッケージ | 旧 | 新 |`）
  - 已有软件更新：`| pkg | old | new |`
  - 首次添加：新旧版本列合并为一列，`| pkg | 新增 v<version> |`
  - hash 行以 `| 　 | <hash类型> | <旧值> → <新值> |` 缩进

### 统一规则

| 规则 | 说明 |
|------|------|
| **LIFO** | 最新记录插入文件顶部（紧随 `---` 分隔线） |
| **仅记录实质变更** | 无实际软件/配置变更时不写入 |
| **省略无变更信息** | 构建验证结果不记录；未变化的 hash 不标出 |
| **新包合并列** | 首次添加时旧版本列留空或合并 |
| **纯 bug 修复无版本表** | 若本次无软件版本变更，省略软件版本表 |

## 撰写流程

### 第 1 步：确认记录内容

与用户确认摘要描述（若为自动触发则从 commit message 提取）。

```bash
# 自动生成摘要 — 从最新 commit 提取
git log -1 --format="%s"
```

### 第 2 步：查找关联提交

```bash
# 查找本次变更相关的所有提交
git log --oneline --since="<时间范围>"
```

### 第 3 步：生成维护记录

按格式规范生成新条目，插入到 `MAINTENANCE.md` 顶部（第一个 `---` 分隔线之后）。

### 第 4 步：三语同步

```bash
# 更新中文 MAINTENANCE.md 后，同步 en 和 ja 版本
# 翻译规则：仅翻译标题行、表头、摘要前缀；包名和版本号保持原文
```

使用以下翻译映射：

| zh | en | ja |
|----|----|-----|
| `# 维护日志` | `# Maintenance Log` | `# メンテナンスログ` |
| `**摘要**` | `**Summary**` | `**概要**` |
| `| 提交 | 说明 |` | `| Commit | Description |` | `| コミット | 説明 |` |
| `| 软件名 | 旧版本 | 新版本 |` | `| Package | Old | New |` | `| パッケージ | 旧 | 新 |` |
| `NixKits 软件更新维护日志。` | `NixKits package update changelog.` | `NixKits パッケージ更新履歴。` |

### 第 5 步：提交

```bash
git add MAINTENANCE.md docs/MAINTENANCE.en.md docs/MAINTENANCE.ja.md
git commit -m "docs(MAINTENANCE): record <date> — <summary>"
```

## 软件更新示例

```markdown
## 2026-06-14T07:56:11+09:00

**摘要**：codewhale 0.8.59 — 修复若干 TUI 渲染问题；mcp-searxng 1.4.0 — 新增 HTTP 传输模式

| 提交 | 说明 |
|------|------|
| `a71aae7` | chore(pkgs): bump codewhale 0.8.59 |
| `e8f0299` | chore(pkgs): bump mcp-searxng 1.4.0 |
| `ec7d5ca` | docs(MAINTENANCE): record 2026-06-14 updates |

| 软件名 | 旧版本 | 新版本 |
|--------|--------|--------|
| codewhale | 0.8.58 | 0.8.59 |
| mcp-searxng | 1.3.4 | 1.4.0 |
| 　 | cli hash | `...` → `...` |
```

## 错误修复示例

```markdown
## 2026-06-17T06:48:47+09:00

**摘要**：fix(mcp-searxng): 修复入口文件错误 — dist/index.js → dist/cli.js，MCP 服务器可正常启动

| 提交 | 说明 |
|------|------|
| `73a3b10` | fix(mcp-searxng): use dist/cli.js as entry point instead of dist/index.js |
```

## 自动触发

本技能被以下技能自动调用：

- **nixkits-check-updates**：软件更新完成后自动记录
- 用户执行**任何修复**后，可通过「记录本次修复」触发

> 自动触发时，摘要从前置技能的输出或最新 commit message 提取，无需重复确认。
