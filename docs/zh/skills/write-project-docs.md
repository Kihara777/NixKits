# write-project-docs (Skill)

[中文](write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md)

> 按 NixKits 风格为任意项目编写完整的多语言文档系统 — 中英日+伪中国语四语、简洁、表驱动。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-project-docs/SKILL.md` |

## 功能

- 评估项目元数据并提取模块信息
- 按功能分类模块（基础设施/服务/代理/技能等）
- 生成 `docs/{zh,en,ja,pcn}/` 四语目录结构
- 编写分类 README（含语言切换器）
- 编写模块文档（基本信息表 + 安装 + 引用）
- 编写技能文档（统一模板：基本信息 → 功能 → 使用）
- 支持子代理并行化：按模块类别分派

## 技能文档同步规则

当 `SKILL.md` 变更时，对应三语文档必须同步更新。
用 staleness check 定位过时文件：

```bash
for lang in zh en ja pcn; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新顺序：中文基准 → 英文翻译 → 日文翻译 → 伪中国语翻译。
四语列名映射：`基本信息` → `Info` / `基本情報` / `基本情報`、`功能` → `Features` / `機能` / `機能`。
伪中国语（pcn）规则：以日语汉字词汇为基础，剥离全部假名及送假名，将日语句法转为中文语序，使用中文标点符号。技术术语保留原形，英文缩写及符号不译。

## 编写规则

- 零废话、表格优先、代码块完整可运行
- 技术术语保持英文，警告使用引用块
- 中文标题使用 2 或 4 字词以保证视觉节奏
- 目标行数 ~40-60 行，补丁/模块文档以四段式为标准（基本信息 → 修正内容 → 安装 → 注意）
- 禁止独立的技术细节、问题排查、参考章节 — 压缩为 `## 注意` bullet
- 三个 README 必须同步更新表行
- 根目录仅保留中文无后缀 `.md`，本地化版本（`*.en.md`、`*.ja.md`、`*.pcn.md`）移入 `docs/`
- 所有语言必须包含基本信息表格（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、伪中国语 `## 基本情報`）
- 补丁/模块源码变更后，「修正内容」/「功能」列表必须同步更新，每条 bullet 对应实际修改

## 使用

由 AI 助手在用户要求「编写文档」或「按 NixKits 风格生成文档」时激活。
