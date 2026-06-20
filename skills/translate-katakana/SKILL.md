---
name: translate-katakana
description: 为文档撰写技能提供额外的自然语言支持。新增 ｶﾀﾘｯｼｭ（片假名英语）语言——半角片假名逐词机械替换英文文本，可与现有三语（zh/en/ja）文档体系并行使用。
---

# 片假名英语翻译

为 NixKits 文档体系提供 ｶﾀﾘｯｼｭ（片假名英语语言，通过半角片假名逐词机械替换英文实现。设计目的为模块化扩展文档撰写技能（write-project-docs）的语言支持能力。

## 触发场景

- 由 write-project-docs 技能自动调用（作为文档编写流程的语言后端）
- 用户要求"生成片假名英语版本文档"时独立调用
- 用户要求"新增一种文档语言"时作为参考实现

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

2. **保留非英文内容**
   - 数字、URL、代码块、Markdown 语法（`#`、`|`、`[]` 等）原样保留
   - 中文/日文汉字不替换

3. **专有名词处理**
   - `NixOS` → `ﾆｯｸｽOS`（混合：专名音译 + 保留 `OS`）
   - `GitHub` → `ｷﾞｯﾄﾊﾌﾞ`（整个词音译）
   - 包名/模块名保持原样（如 `mcp-searxng` 不替换）

### 内置替换词典（节选）

常用技术文档词汇的片假名映射：

| 英文 | 半角片假名 | 说明 |
|------|---------|------|
| software | ｿﾌﾄｳｪｱ |  |
| package | ﾊﾟｯｹｰｼﾞ |  |
| module | ﾓｼﾞｭｰﾙ |  |
| system | ｼｽﾃﾑ |  |
| install | ｲﾝｽﾄｰﾙ |  |
| configure | ｺﾝﾌｨｷﾞｭｱ |  |
| build | ﾋﾞﾙﾄﾞ |  |
| overlay | ｵｰﾊﾞｰﾚｲ |  |
| patch | ﾊﾟｯﾁ |  |
| skill | ｽｷﾙ |  |
| agent | ｴｰｼﾞｪﾝﾄ |  |
| service | ｻｰﾋﾞｽ |  |
| dependency | ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰ |  |
| version | ﾊﾞｰｼﾞｮﾝ |  |
| license | ﾗｲｾﾝｽ |  |
| repository | ﾘﾎﾟｼﾞﾄﾘ |  |
| description | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ |  |
| template | ﾃﾝﾌﾟﾚｰﾄ |  |
| maintenance | ﾒﾝﾃﾅﾝｽ |  |
| documentation | ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ |  |
| compatibility | ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ |  |

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

### 使用方式

```python
# 由 write-project-docs 调用
from katakana_english import replace_to_katakana

en_text = "Install the package with nix build"
kata_text = replace_to_katakana(en_text)
# → "ｲﾝｽﾄｰﾙ ｻﾞ ﾊﾟｯｹｰｼﾞ ｳｨｽﾞ ﾆｯｸｽ ﾋﾞﾙﾄﾞ"
```

### 文件命名约定

ｶﾀﾘｯｼｭ 文档：
- `docs/katalish/<module>.md` — 片假名英语版模块文档
- `docs/README.katalish.md` — 片假名英语 README
- `docs/MAINTENANCE.katalish.md` — 片假名英语维护记录

语言切换器中新增：`[ｶﾀﾘｯｼｭ](docs/README.katalish.md)`

## 与其他技能的关系

| 技能 | 关系 |
|------|------|
| write-project-docs | 主调用者 — 文档编写流程的第 5 步"编写各模块文档"中调用本技能生成 ｶﾀﾘｯｼｭ 版本 |
| nixkits-check-updates | 间接调用 — 更新文档时同步生成 ｶﾀﾘｯｼｭ 版本 |

## 注意事项

- 片假名英语不是人类可读的语言——它是视觉装饰/伪本地化
- 不以替换质量为目标——机械替换即可接受
- 代码块内容不替换
- Nix 表达式保持原样
