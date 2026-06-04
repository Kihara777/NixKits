# write-project-docs (Skill)

[中文](write-project-docs.md) | [English](../../en/skills/write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md)

> 按 NixKits 风格为任意项目编写完整的多语言文档系统 — 模块文档、技能文档、分类 README。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-project-docs/SKILL.md` |

## 功能

- **项目评估**：读取模块/包定义文件，提取元数据
- **模块分类**：按功能将模块分组（基础设施/服务/代理/导航/静态链接）
- **目录创建**：自动生成 `docs/{zh,en,ja}/skills/` 结构
- **README 编写**：语言切换行 + 分类表格 + 文档链接
- **模块文档**：基本信息表 + 安装 + 引用 + 使用（遵循 NixKits 模板）
- **技能文档**：基本信息表 + 功能列表 + 触发条件
- **并行化**：大型项目分派子代理并行编写
- **验证**：文件计数、链接检查、术语一致性

## 使用

由 AI 助手在用户要求「编写文档」或「按 NixKits 风格生成文档」时激活。

## 约定

- 零修辞，表格优先，代码块完整可用
- 技术术语保留英文
- 警告使用 `> **⚠️**` 引用块
- 三语言各自独立文件，语言切换行使用相对路径
