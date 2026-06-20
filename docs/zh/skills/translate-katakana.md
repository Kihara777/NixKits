# translate-katakana (技能)

[中文](translate-katakana.md) | [English](../../en/skills/translate-katakana.md) | [日本語](../../ja/skills/translate-katakana.md)

> 为文档撰写技能提供额外的自然语言支持。新增 kata-en（片假名英语）语言。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | 编码助手技能（语言后端） |
| 路径 | `skills/translate-katakana/SKILL.md` |
| 调用者 | write-project-docs（主）、nixkits-check-updates（间接） |

## 功能

- 新增 kata-en 语言——半角片假名逐词机械替换英文
- 内置 ~20 条常用技术文档词汇替换词典
- 规则音译引擎（未命中词典时逐音节转换）
- 保留 Markdown 语法和代码块
- 文件命名约定：`docs/kata/<name>.md`

## 使用

写入 kata-en 文档时由 write-project-docs 自动触发，亦可通过用户指令独立调用：

- "生成为片假名英语版本文档"
- "追加 kata-en 语言版本"
- "translate to katakana english"

## 示例

```
NixKits — software, patches, NixOS modules and coding agent skills.
```
→
```
ﾆｯｸｽｷｯﾄ — ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ｱﾝﾄﾞ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ ｽｷﾙ.
```
