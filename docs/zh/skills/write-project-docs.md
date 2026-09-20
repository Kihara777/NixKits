# write-project-docs (Skill)

中文 | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md)  | [偽中国語](../../pcn/skills/write-project-docs.md)

> 按 NixKits 风格为任意项目编写完整的多语言文档系统 — 中英日及各语言扩展（自动发现）、简洁、表驱动；含主仓薄封装与子仓引用关系的文档分工。

## 自动发现契约

语言扩展技能通过 `translate-*` 命名约定被本技能发现：扫描 `skills/translate-*/` 目录，读取各 SKILL.md frontmatter 中的 `language_code` / `display_name` / `base_language` 字段，注册为文档生成流程中的可用语言。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-project-docs/`（`SKILL.md` + `templates.md`）|
| 配套文件 | `templates.md` —— 完整模板集（目录结构 / 模块文档 / README / 维护日志），首次搭建某类文档时查阅 |

## 功能

- 评估项目元数据并提取模块信息
- 按功能分类模块（基础设施/服务/代理/技能等）
- 生成 `docs/{zh,en,ja}/` 多语目录结构
- 语言扩展自动发现 — 扫描 `skills/translate-*/` 按 `translate-*` 命名约定加载语言后端
- 编写分类 README（含语言切换器）
- 编写模块文档（基本信息表 + 安装 + 引用）
- 编写技能文档（统一模板：基本信息 → 功能 → 使用）
- **迁出组件文档分工**：组件迁出为独立仓库时，子仓承载完整文档、主仓改短页（说明迁出 + 链接 + 只保留主仓独有节），避免同一份文档维护两遍
- **子仓引用关系显式记录**：主仓引用了同账户子仓（薄封装 / flake input / submodule）时，主仓短页「基本信息」须写明**源码仓库 + 主仓侧角色 + 钉住的坐标 + 同步方式**——否则维护者会在主仓找不到源码，或重复实现子仓已有的东西
- 支持子代理并行化：按模块类别分派

## 技能文档同步规则

当 `SKILL.md` 变更时，对应多语文档必须同步更新。
用 staleness check 定位过时文件：

```bash
for lang in zh en ja; do
  for skill in skills/*/SKILL.md; do
    name=$(basename $(dirname $skill))
    doc="docs/$lang/skills/$name.md"
    [ "$skill" -nt "$doc" ] && echo "STALE: $lang/$name"
  done
done
```

更新顺序：中文基准 → 各语言翻译（按 `translate-*` 技能自动发现）。
各语言翻译技能的 SKILL.md 中定义专有列名映射。
各 `translate-*` 技能的 SKILL.md 中定义具体翻译规则。

## 编写规则

- 零废话、表格优先、代码块完整可运行
- 技术术语保持英文，警告使用引用块
- 中文标题使用 2 或 4 字词以保证视觉节奏
- 目标行数 ~40-60 行，补丁/模块文档以四段式为标准（基本信息 → 修正内容 → 安装 → 注意）
- 禁止独立的技术细节、问题排查、参考章节 — 压缩为 `## 注意` bullet
- 三个 README 必须同步更新表行
- 除「基准语言」（由仓库自定，本技能不假定具体语言）外，本地化版本（`*.en.md`、`*.ja.md`、`*.pcn.md`）移入 `docs/`，文件名保持不变
- 所有语言必须包含基本信息表格（中文 `## 基本信息`、英文 `## Info`、日文 `## 基本情報`、各语言按 `translate-*` 技能定义的列名）
- 补丁/模块源码变更后，「修正内容」/「功能」列表必须同步更新，每条 bullet 对应实际修改

## 双向自动发现

本技能与 `translate-*` 翻译技能之间通过命名约定实现双向发现：

| 方向 | 机制 |
|------|------|
| 文档生成 → 翻译技能 | 扫描 `skills/translate-*/` 目录，读取各 SKILL.md 的 `language_code`/`display_name`/`base_language` |
| 翻译技能 → 本项目 | 各技能在 SKILL.md 中声明「与其他技能的关系」表，明确调用链 |
| 语言代码 → 路径 | `language_code` → 目录命名、文件扩展名；`display_name` → 语言切换器标签 |

翻译技能文档自身也遵循本模板，形成闭环：文档生成 → 翻译调用 → 翻译技能文档生成。

## 使用

由 AI 助手在用户要求「编写文档」或「按 NixKits 风格生成文档」时激活。
