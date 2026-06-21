---
name: translate-katalish
description: 为文档撰写技能提供额外的自然语言支持。新增 ｶﾀﾘｯｼｭ（片假名英语）语言——半角片假名逐词机械替换英文文本，与现有文档体系并行使用。
language_code: katalish
display_name: ｶﾀﾘｯｼｭ
base_language: en
---

# 片假名英语翻译

为 NixKits 文档体系提供 ｶﾀﾘｯｼｭ（片假名英语）语言。

## 自动发现契约

write-project-docs / write-maintenance-log 通过扫描 `skills/translate-*/SKILL.md` frontmatter 自动发现：

| 字段 | 值 | 用途 |
|------|-----|------|
| `language_code` | `katalish` | 目录名、文件扩展名、for 循环迭代 |
| `display_name` | `ｶﾀﾘｯｼｭ` | 语言切换器标签 |
| `base_language` | `en` | 源语言 |

## 触发场景

- 由 write-project-docs / write-maintenance-log 自动发现调用
- 用户要求"生成片假名英语版本"时独立调用

## 替换规则

### 1. 优先级

**词典匹配（`dictionary.md`） > 规则音译**

### 2. 保留不译

- 数字、URL、内联代码 `` `code` ``、Markdown 语法原样保留
- 中文/日文汉字不替换
- 语言切换器中的目录名（`zh`、`en`等）和文件扩展名（`.md`）不替换
- 语言名称不作本地化（`English` 保持 `English`）

### 3. 代码块保护（⚠️ 关键）

- **Nix 代码块**：仅翻译 `#` 注释，标识符/属性路径/关键字不动
- **Bash 代码块**：全部不动
- 执行层面：先按 ` ``` ` 边界提取代码块，仅对非代码块区域替换

### 4. 专有名词

| 原文 | 音译 |
|------|------|
| NixOS | ﾆｯｸｽOS |
| GitHub | ｷﾞｯﾄﾊﾌﾞ |
| DeepSeek | ﾄﾞｴｴﾌﾟｽｴｴｸ |
| Nix | ﾆｯｸｽ |

### 5. 规则音译（词典未命中时）

| 英文音节 | 片假名 |
|---------|--------|
| a (短) | ｱ |
| a (长) | ｴｲ |
| i (短) | ｲ |
| i (长) | ｱｲ |
| u (短) | ｱ |
| u (长) | ﾕｰ |
| e (短) | ｴ |
| e (长) | ｲｰ |
| o (短) | ｵ |
| o (长) | ｵｰ |

## 词典

完整替换词典见 [`dictionary.md`](dictionary.md)（66 条映射）。

## 注意事项

- 片假名英语不是人类可读的语言——视觉伪本地化，机械替换即可
- 语言切换器生成规则：从英文源提取路径，逐个精确构造（禁止 sed 模式匹配）
- 包名/模块名保持原样（如 `mcp-searxng`）
