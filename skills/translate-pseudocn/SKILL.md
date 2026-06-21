---
name: translate-pseudocn
description: 为文档撰写技能提供伪中国语（pcn）语言支持。以日语汉字词汇为基础、剥离平假名与片假名、转换日语语序为中文语序的伪本地化。可被 write-project-docs 自动发现调用。
language_code: pcn
display_name: 偽中国語
base_language: ja
---

# 伪中国语翻译

为 NixKits 文档体系提供 pcn（伪中国语）语言。

## 自动发现契约

write-project-docs / write-maintenance-log 通过扫描 `skills/translate-*/SKILL.md` frontmatter 自动发现：

| 字段 | 值 | 用途 |
|------|-----|------|
| `language_code` | `pcn` | 目录名、文件扩展名 |
| `display_name` | `偽中国語` | 语言切换器标签 |
| `base_language` | `ja` | 源语言 |

## 替换规则

### 1. 词典优先

先查 [`dictionary.md`](dictionary.md) 中的片假名→偽中国語映射（40 条），未命中再走以下规则。

### 2. 剥离假名

去除**所有假名**（平假名 + 片假名）。平假名尾缀一并剥离（如 `食べる`→`食`）。

### 3. 语序调整

SOV → SVO（日语主-宾-动 → 中文主-动-宾）

### 4. 助词替换

| 日文 | 中文 |
|------|------|
| の | 之 |
| と | 与 |
| に | 於/向 |
| で | 以/於 |
| から | 自 |
| まで | 至 |

### 5. 标点 + 代码块

- `、` `。` → `，` `。`
- **Nix 代码块**：仅翻译 `#` 注释
- **Bash 代码块**：全部不动
- 先按 ` ``` ` 提取代码块，仅对非代码区域应用规则

## 词典

完整映射见 [`dictionary.md`](dictionary.md)。

## 注意事项

- 伪中国语是视觉伪本地化，不追求翻译准确性
- 语言切换器生成：从日文源提取路径逐个精确构造
- `日本語`→`[日本語]`（加链接），自身标签 `偽中国語`（纯文本）
