---
name: write-project-docs
description: 按 NixKits 风格为任意项目编写或重新生成完整的多语言文档 — 简洁、表驱动、含语言切换器标题和模块分类 README。覆盖 README、各模块文档及技能文档。
---

# 项目文档编写（NixKits 风格）

为任意项目生成完整的多语言文档体系。

## 何时使用

- 用户要求"编写文档"或"生成文档"
- 用户希望采用 NixKits 风格（简洁、多语言、表驱动）
- 用户有含模块/包/服务的现有项目需要文档化

## 自动发现契约

1. **扫描** — `skills/translate-*/` 下查找所有翻译技能
2. **读取** — 解析 frontmatter 中的 `language_code`、`display_name`、`base_language`
3. **注册** — 将发现的语言扩展纳入目录结构、语言切换器、列名映射等生成逻辑

## 编写规则

- **零废话** — 没有引导性修辞，没有"欢迎来到"
- **表格优先于段落** — 用 `基本信息` 表格展示元数据
- **代码块完整可运行** — 可直接复制粘贴
- **技术术语保持英文** — 即使在中文/日文文档中
- **语言切换器标签** — 统一用各语言 `display_name`（语言自称），自身不加链接
- **中文标题 2 或 4 字词** — 优先简洁对称词汇（如 `组件`、`基本信息`）
- **不生成目录** — 文档足够短，直接扫读
- **目标行数 ~40-60 行** — 补丁/模块文档以 `rcc-fix.md`（39 行）为标杆
- **标准节结构** — `基本信息` → `修正内容`/`功能` → `安装` → `注意`
- **禁止反模式**：

| 反模式 | 正确做法 |
|--------|----------|
| 硬编码语言列表 | 自动发现 `translate-*/` |
| 硬编码文档路径（如 `docs/zh/`） | 根据语言代码动态生成 |
| 链接修复只改路径不改显示文本 | 路径和显示文本同步修正 |
| README 只更新主语言 | 同步所有已发现的本地化版本 |
| 源文件修改后不跟新文档 | 每次源变更后立即校对相关文档 |
| 在已有节之前插入内容时未检查是否已存在 | 逐行 `grep` 确认目标文本不重复后再写入 |

## 工作流程

### 第 1 步：评估项目

读取所有可用的模块/包/服务元数据，对每个模块提取名称、描述、类型、依赖、安装命令、使用示例。

### 第 2 步：模块分类

按功能类别分组。对于 Nix flake 项目：

| 分类 | 发现方式 |
|------|---------|
| 软件 | `packages/*.nix` 中的 `callPackage` |
| 模块 | `modules/*.nix` 中的 NixOS 模块定义 |
| 覆盖层 | `overlays/*.nix` 中的 overlay 函数 |
| 技能 | `skills/*/SKILL.md` 中的 frontmatter |
| 开发 | `devShells` 在 `flake.nix` 中 |

### 第 3 步：生成 README

主语言 README 放根目录（无后缀），本地化版本放 `docs/README.<code>.md`。

### 第 4 步：生成模块文档

`docs/<lang>/<module>.md`，遵循四段式结构，每组自动包含对应分类标题。

### 第 5 步：生成技能文档

`docs/<lang>/skills/<skill>.md`，每技能包含基本信息 + 功能 + 使用。

### 第 6 步：语言切换器

按 `zh → en → ja → 扩展语言（自动发现顺序）` 生成。从源文件提取路径，用脚本逐个精确构造（**禁止 sed 模式匹配**）。

### 第 7 步：最终检查

- 无死链接
- 各模板满员（无缺失语言版本）
- 中文 2/4 字标题一致
- 引用块格式统一

### 第 8 步：语言切换器双向同步（⚠️ 易遗漏）

新增语言变体后，**必须双向更新**所有语言切换器：

| 方向 | 操作 |
|------|------|
| 新文件 → 自身 | 创建时已含完整切换器 |
| 现有文件 → 新语言 | ⚠️ **易遗漏！** 需追加新语言链接到所有现有文件的切换器行 |

**实施方法**：用 `sed` 匹配切换器行（以 `[中文]`/`[English]`/`[日本語]` 开头），追加新链接。**禁止用行号定位**（`sed '2s'` 可能命中空行而非切换器）。

```bash
# 正确：模式匹配切换器行
sed -i "/^\[中文\]\|^\[English\]\|^\[日本語\]/s|$| \| [新标签](path/file.md)|" docs/*/xxx.md

# 错误：硬编码行号（切换器不一定在第 2 行）
sed -i "2s|$| ...|" docs/*/xxx.md
```

**子代理陷阱**：子代理生成新语言文件时，容易只输出 **3 条目切换器**（仅含源语言），缺少其他已安装的扩展语言。父代理接收子代理输出后，必须用以下脚本验证补全：

```bash
# 验证所有语言目录下切换器完整性
for d in docs/zh docs/en docs/ja docs/katalish docs/pcn; do
  for f in $d/*.md; do
    l=$(grep '^\[中文\]' "$f"); s=0
    echo "$l"|grep -q '中文' && s=$((s+1))
    echo "$l"|grep -q 'English' && s=$((s+1))
    echo "$l"|grep -q '日本語' && s=$((s+1))
    echo "$l"|grep -q 'ｶﾀﾘｯｼｭ' && s=$((s+1))
    echo "$l"|grep -q '偽中国語' && s=$((s+1))
    [ $s -lt 5 ] && echo "INCOMPLETE ($s/5): $f"
  done
done
```

### 第 8.1 步：根目录与跨层级文件检查（⚠️ 三阶遗漏）

语言切换器更新的常见遗漏呈**三阶递进**模式，每轮修复只覆盖到更深一层：

| 阶 | 遗漏范围 | 原因 |
|----|---------|------|
| 1 | 子代理生成的新文件自身 | 只生成 3 条目，未含扩展语言 |
| 2 | 现有 `docs/{zh,en,ja}/*.md` | sed 已覆盖，但 katalish/pcn 自身需额外补全 |
| 3 | **根目录 + `docs/*.xx.md` 模式** | sed glob `docs/zh/*.md` 不匹配根级文件 |

**第三阶遗漏文件清单**（极易漏检）：

```
README.md                          # 项目根
MAINTENANCE.md                     # 项目根
NOTICE.md                          # 项目根
kits/README.md                     # 子目录根
docs/README.en.md                  # docs/ 根级（非 docs/en/ 内）
docs/README.ja.md
docs/MAINTENANCE.en.md
docs/MAINTENANCE.ja.md
docs/NOTICE.en.md
docs/NOTICE.ja.md
```

**验证命令（覆盖全部层级）**：

```bash
# 全项目切换器完整性检查（不遗漏根目录）
for f in README.md MAINTENANCE.md NOTICE.md kits/README.md \
         $(find docs -maxdepth 2 -name '*.md'); do
  l=$(grep '\[中文\]\|\[English\]\|\[日本語\]' "$f" 2>/dev/null | head -1)
  [ -z "$l" ] && continue
  echo "$l" | grep -q 'ｶﾀﾘｯｼｭ' || echo "MISSING katalish: $f"
  echo "$l" | grep -q '偽中国語' || echo "MISSING pcn: $f"
done
```

**⚠️ 先建文件再加链接**：向现有文件的切换器追加新语言链接前，必须确保目标文件已存在。否则产生死链（HTTP 404）。新增语言的顶层文档（README / MAINTENANCE / NOTICE）极易在此环节遗漏。

### 第 9 步：README 展示表同步

新增磁贴/模块后，**所有语言版本**的 README 展示表都需要更新。检查清单：
- [ ] zh/README.md 展示区
- [ ] en/README.md (docs/README.en.md) 展示区
- [ ] ja/README.md (docs/README.ja.md) 展示区
- [ ] 每个新磁贴有对应的三语文档

### 第 10 步：MAINTENANCE.md 去重

维护记录的日期节之间若出现摘要区块（表格式），应合并至时间线列表，避免信息重复。