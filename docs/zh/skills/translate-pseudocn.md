# translate-pseudocn (技能)

[中文](translate-pseudocn.md) | [English](../../en/skills/translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/translate-pseudocn.md) | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> 为文档撰写技能提供伪中国语（pcn）语言支持。可被 write-project-docs 自动发现调用。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | 编码助手技能（语言后端） |
| 路径 | `skills/translate-pseudocn/SKILL.md` |
| 语言代码 | pcn |
| 调用者 | write-project-docs（自动发现） |

## 功能

- 伪中国语（pcn）翻译 — 日语文本假名剥离 + 语序转换
- SOV→SVO 语序调整、助词替换、标点转换
- 内置 ~13 条技术术语日→中映射词典
- 保留代码块、数字、符号

## 使用

由 write-project-docs 按 `translate-*` 约定自动发现并调用：

- "生成伪中国语文档"
- "追加 pcn 语言版本"
