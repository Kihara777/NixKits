# translate-pseudocn (技能)

中文 | [English](../../en/skills/translate-pseudocn.md) | [日本語](../../ja/skills/translate-pseudocn.md)  | [偽中国語](../../pcn/skills/translate-pseudocn.md)

> 为文档撰写技能提供伪中国语（pcn）语言支持。可被 write-project-docs 自动发现调用。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | 编码助手技能（语言后端） |
| 路径 | `skills/translate-pseudocn/`（`SKILL.md` + `dictionary.md`）|
| 配套文件 | `dictionary.md` —— 内置片假名→日文漢字映射词典（实测 **75** 条），翻译与残留假名自检时查 |
| 语言代码 | pcn |
| 调用者 | write-project-docs（自动发现） |

## 功能

- 伪中国语（pcn）翻译 — 日语文本假名剥离 + 语序转换
- SOV→SVO 语序调整、助词替换、标点转换
- 内置片假名→日文漢字映射词典（`dictionary.md`，**75** 条：软件/硬件/版本/上流等常规词 + IT 术语）
- 保留代码块、数字、符号

## 使用

由 write-project-docs 按 `translate-*` 约定自动发现并调用：

- "生成伪中国语文档"
- "追加 pcn 语言版本"
