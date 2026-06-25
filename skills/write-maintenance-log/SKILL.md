---
name: write-maintenance-log
description: 按 NixKits 规范撰写或更新 MAINTENANCE.md 维护日志。支持软件更新记录和错误修复记录两种类型，自动关联 git commit、生成摘要、五语同步。
---

# 维护日志撰写

按 NixKits 统一规范撰写 `MAINTENANCE.md` 维护记录，确保格式一致、信息完整、多语同步。

## 自动发现契约

本技能通过纯自然语言约定发现语言扩展：

1. **扫描** — 在 `skills/translate-*/` 目录下查找所有翻译技能
2. **读取** — 解析各 SKILL.md frontmatter 中的 `language_code` / `display_name` / `base_language` 字段
3. **注册** — 自动将发现的语言扩展纳入多语同步流程。各翻译技能的 SKILL.md 正文中定义翻译规则（词典、语序调整、假名剥离）和列名映射表（TITLE / SUBTITLE / SUMMARY 等多语对照）。

## 入口
本技能由 AGENTS.md 规则强制触发：每次 `git push` 后必须执行入口 1 的 SHA 查重流程。

本技能提供两个独立入口，根据用户意图自动匹配。

### 入口 1：记入维护记录

**触发词**：「记入维护记录」「记录本次修复」「写入维护日志」

基于当前对话中完成的软件更新或错误修复，撰写单条维护记录并插入 `MAINTENANCE.md`。

> 此入口被 `nixkits-check-updates` 技能在软件更新完成后**自动调用**。

### 入口 2：更新维护记录

**触发词**：「更新维护记录」「补全维护记录」「同步维护日志」

基于 `git log` 扫描全部提交历史，找出以下未记录的内容并补全：

- 未被记录的 `fix(...)` / `feat(...)` 提交
- 缺失关联 commit id 的旧记录（回填 `| 提交 | 说明 |` 表）
- 格式不统一、行文不规范的历史条目（统一为新格式）

**执行流程**：

```bash
# 1. 提取所有 fix / feat 提交（排除 docs 和 chore(pkgs) 类型）
git log --oneline --all | grep -E 'fix\(|feat\(' | while read hash msg; do
  # 检查是否已在 MAINTENANCE.md 中
  grep -q "$hash" MAINTENANCE.md || echo "MISSING: $hash $msg"
done

# 2. 对每个缺失的提交：
#    a. 按日期分组
#    b. 生成摘要（从 commit message 提取）
#    c. 按格式规范生成条目
#    d. LIFO 插入 MAINTENANCE.md

# 3. 补全已有记录缺失的 commit id
#    a. 解析所有现有记录日期
#    b. 按 ±2h 窗口匹配未关联的提交
#    c. 补充到对应记录的提交表中

# 4. 多语同步并提交
```

> 此入口**不修改软件版本表**中已记录的版本号与 hash 值，仅补充元数据。

## 记录范围

维护日志覆盖以下类别的变更：

| 类别 | 记录条件 | 示例 |
|------|---------|------|
| **软件** | 版本更新或 bug 修复 | `chore(pkgs): bump codewhale` `fix(mcp-searxng): ...` |
| **技能** | 新增技能、重大章节添加、bug 修复、重大重构 | `feat(skill): extract write-maintenance-log` `fix(skill): generalize 基本情報 rule` `refactor(skills): generalize hardcoded content` |
| **文档** | 模块/包文档的实质性更新（新增章节、配置指南、故障排查、迁移指南） | `docs(mcp-searxng): add CodeWhale config` `docs(llama-cpp-rocm): add multilingual migration guide` |
| **模块** | 新增模块或重大功能添加 | `feat(rcc-fix): add NixOS module` `feat(llama-cpp-rocm): restore modelsPreset` |

**不记录**：纯机械性多语 sync（`docs(skills): sync ... to multilingual docs`）、仅涉及维护日志本身的提交（`docs(MAINTENANCE): ...`）。

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

### 类型 3：技能与文档变更

当技能有重大更新（新增技能、新增章节、重大重构）或模块/包文档有实质性内容添加时，记录：

- 日期时间
- 一句话摘要
- 关联提交表

> **判断标准**：`feat(skill):` `refactor(skill):` `docs(skill):`（新增章节）`fix(skill):` 应记录。`docs(skills): sync` 机械性同步不记录。

### 类型 4：CI/CD 与二进制缓存变更

当项目的 CI/CD 工作流或二进制缓存配置发生变更时，记录：

- 日期时间
- 一句话摘要（如「添加 CI/CD 工作流与 Cachix 二进制缓存」）
- 关联提交表
- CI 配置表（可选，记录工作流变更概要）

记录示例：

```markdown
## <timestamp>

**摘要**：CI/CD 与二进制缓存 — 添加 GitHub Actions 构建矩阵 + Cachix 推送，README 加入缓存徽章与 NixOS 配置方案

| 提交 | 说明 |
|------|------|
| `<sha7>` | feat: add CI/CD workflow, binary cache, and AGENTS.md |
| `<sha7>` | docs: add cache badge and NixOS config instructions |
```

> **判断标准**：`feat:` `fix(ci):` 或新增 `.github/workflows/`、缓存配置变更时应记录。

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

### 第 4 步：多语同步

**必须执行，不可跳过。** MAINTENANCE.md（zh 基准）写入后，立即同步到全部已注册语言版本。

#### 4a. 发现已注册语言

```bash
# 基准语言 + 基础扩展
BASE_LANGS="zh en ja"

# 自动发现 translate-* 扩展语言（katalish、pcn 等）
for skill in skills/translate-*/SKILL.md; do
  lang=$(sed -n '/^language_code:/s/.*: *//p' "$skill")
  EXTRA_LANGS="$EXTRA_LANGS $lang"
done
```

#### 4b. 逐语言翻译并写入

对每个非 zh 语言，以 zh 基准 MAINTENANCE.md 为蓝本：

1. **复制结构**：保留所有 `## <timestamp>` 条目、提交表、软件版本表的骨架
2. **替换固定标记**：按映射表替换标题（`# 维护日志`）、摘要前缀（`**摘要**`）、表头
3. **翻译摘要正文**：`**摘要**` / `**Summary**` 后的自然语言正文必须翻译为目标语言
   - en → AI 直译
   - ja → AI 直译
   - katalish → 按 `skills/translate-katalish/SKILL.md` 规则机械替换
   - pcn → 按 `skills/translate-pseudocn/SKILL.md` 规则假名剥离 + 语序保持
4. **保持原文**：commit SHA、包名、版本号、hash 值、命令、路径**不翻译**
5. **写入**对应 `docs/MAINTENANCE.<lang>.md`

#### 4c. 验证同步完整性

```bash
# 各语言版本条目数必须一致
zh_count=$(grep -c '^## 20' MAINTENANCE.md)
for f in docs/MAINTENANCE.*.md; do
  count=$(grep -c '^## 20' "$f")
  if [ "$count" -ne "$zh_count" ]; then
    echo "MISMATCH: $f has $count entries, expected $zh_count"
  fi
done
```

条目数不一致时**必须修复后再进入第 5 步提交**。

#### 多语映射表

| 代码 | zh | en | ja | katalish | pcn |
|------|----|----|-----|---------|-----|
| `TITLE` | `# 维护日志` | `# Maintenance Log` | `# メンテナンスログ` | `# ﾒﾝﾃﾅﾝｽ ﾛｸﾞ` | `# 維護記録` |
| `SUBTITLE` | `NixKits 软件更新维护日志。` | `NixKits package update changelog.` | `NixKits パッケージ更新履歴。` | `ﾆｯｸｽｷｯﾄ ﾊﾟｯｹｰｼﾞ ｱｯﾌﾟﾃﾞｰﾄ ﾁｪﾝｼﾞﾛｸﾞ。` | `NixKits 軟件更新維護記録。` |
| `SUMMARY` | `**摘要**` | `**Summary**` | `**概要**` | `**ｻﾏﾘｰ**` | `**摘要**` |
| `COMMIT_HDR` | `\| 提交 \| 说明 \|` | `\| Commit \| Description \|` | `\| コミット \| 説明 \|` | `\| ｺﾐｯﾄ \| ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ \|` | `\| 提交 \| 説明 \|` |
| `SW_TABLE_HDR` | `\| 软件名 \| 旧版本 \| 新版本 \|` | `\| Package \| Old \| New \|` | `\| パッケージ \| 旧 \| 新 \|` | `\| ﾊﾟｯｹｰｼﾞ \| ｵｰﾙﾄﾞ \| ﾆｭｰ \|` | `\| 軟件名 \| 舊版本 \| 新版本 \|` |

### 第 5 步：提交

```bash
git add MAINTENANCE.md docs/MAINTENANCE.en.md docs/MAINTENANCE.ja.md docs/MAINTENANCE.katalish.md docs/MAINTENANCE.pcn.md
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