---
name: translate-katalish
description: 为文档撰写技能提供额外的自然语言支持。新增 ｶﾀﾘｯｼｭ（片假名英语）语言——半角片假名逐词机械替换英文文本，与现有文档体系并行使用。
language_code: katalish
display_name: Katalish
base_language: en
---

# 片假名英语翻译

为 NixKits 文档体系提供 ｶﾀﾘｯｼｭ（片假名英语）语言，通过半角片假名逐词机械替换英文实现。设计目的为模块化扩展文档撰写技能（write-project-docs）的语言支持能力。

## 自动发现契约

write-project-docs 和 write-maintenance-log 通过扫描 `skills/translate-*/SKILL.md` frontmatter 自动发现本技能：

| 字段 | 值 | 用途 |
|------|-----|------|
| `language_code` | `katalish` | 目录名 `docs/katalish/`、文件扩展名 `*.katalish.md`、for 循环迭代 |
| `display_name` | `ｶﾀﾘｯｼｭ` | 语言切换器标签 |
| `base_language` | `en` | 片假名英语的源语言（英文文本） |

## 触发场景

- 由 write-project-docs 自动发现并调用（按 `translate-*` 命名约定扫描 `skills/translate-*/`）
- 由 write-maintenance-log 自动发现并调用（维护日志多语同步）
- 用户要求"生成片假名英语版本文档"时独立调用

## 与其他技能的关系

| 技能 | 关系 |
|------|------|
| write-project-docs | 主调用者 — 通过 `translate-*` 自动发现机制加载 frontmatter 字段 |
| write-maintenance-log | 间接调用 — 维护日志撰写时按 `translate-*` 发现机制生成各语言版本 |
| nixkits-check-updates | 间接调用 — 更新文档时同步生成 ｶﾀﾘｯｼｭ 版本 |

## 语言：ｶﾀﾘｯｼｭ（片假名英语/katalish）

### 原理

将英文文本的每个单词按发音映射为半角片假名序列，形成视觉上近似日文但实际是英语发音的伪本地化文本。

**示例**：
```
NixKits — software, patches, NixOS modules and coding agent skills
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ
```

### 替换规则

1. **优先级：词典匹配 > 规则替换**
   - 先查内置替换词典（覆盖常见技术术语和不规则发音）
   - 未命中时使用规则音译（分段匹配最长音节）

2. **保留不译内容**
   - 数字、URL、内联代码 `` `code` ``、Markdown 语法（`#`、`|`、`[]`、`]]` 等）原样保留
   - 中文/日文汉字不替换
   - 语言切换器中的目录名（`zh`、`en`、`ja`、`katalish`、`pcn`）和文件扩展名（`.md`）不替换

3. **代码块特殊处理**
   - Nix 代码块（````nix ... ```）：
     **仅翻译 `#` 注释**（`# 安装` → `# ｲﾝｽﾄｰﾙ`），Nix 表达式/标识符完全不动
   - Bash/其他代码块：全部内容保持原样
   - 内联代码 `` `...` ``：全部保持原样

4. **专有名词处理**
   - `NixOS` → `ﾆｯｸｽOS`（混合：专名音译 + 保留 `OS`）
   - `GitHub` → `ｷﾞｯﾄﾊﾌﾞ`（整个词音译）
   - 包名/模块名保持原样（如 `mcp-searxng` 不替换）

### 内置替换词典（节选）

常用技术文档词汇的片假名映射：

| 英文 | 半角片假名 |
|------|---------|
| software | ｿﾌﾄｳｪｱ |
| package | ﾊﾟｯｹｰｼﾞ |
| module | ﾓｼﾞｭｰﾙ |
| system | ｼｽﾃﾑ |
| install | ｲﾝｽﾄｰﾙ |
| configure | ｺﾝﾌｨｷﾞｭｱ |
| build | ﾋﾞﾙﾄﾞ |
| overlay | ｵｰﾊﾞｰﾚｲ |
| patch | ﾊﾟｯﾁ |
| skill | ｽｷﾙ |
| agent | ｴｰｼﾞｪﾝﾄ |
| service | ｻｰﾋﾞｽ |
| dependency | ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰ |
| version | ﾊﾞｰｼﾞｮﾝ |
| license | ﾗｲｾﾝｽ |
| repository | ﾘﾎﾟｼﾞﾄﾘ |
| description | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |
| template | ﾃﾝﾌﾟﾚｰﾄ |
| maintenance | ﾒﾝﾃﾅﾝｽ |
| documentation | ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ |
| compatibility | ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ |

### 规则音译

未在词典中注册的英文单词，按以下规则逐音节转换：

| 英文音节 | 半角片假名 |
|---------|---------|
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

### 文件命名约定

ｶﾀﾘｯｼｭ 文档：
- `docs/katalish/<module>.md` — 片假名英语版模块文档
- `docs/README.katalish.md` — 片假名英语 README
- `docs/MAINTENANCE.katalish.md` — 片假名英语维护记录

语言切换器中新增：`[ｶﾀﾘｯｼｭ](docs/README.katalish.md)`

## 注意事项

- 片假名英语不是人类可读的语言——视觉装饰/伪本地化；机械替换即可
- 语言切换器中的目录名（`zh`/`en`/`ja`/`katalish`/`pcn`）和文件扩展名（`.md`）不可翻译
- Nix 表达式保持原样，仅翻译 `#` 注释
- 其他代码块（bash 等）全部内容不动
- 内联代码 `` `...` `` 全部内容不动