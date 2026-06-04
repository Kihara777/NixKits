# write-project-docs (Skill)

[中文](../../zh/skills/write-project-docs.md) | [English](write-project-docs.md) | [日本語](../../ja/skills/write-project-docs.md)

> Generate complete multi-language documentation for any project in the NixKits style — module docs, skill docs, classified READMEs.

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-project-docs/SKILL.md` |

## 功能

- **Project assessment**: Read module/package definitions, extract metadata
- **Module classification**: Group by function (infrastructure/services/proxy/navigation/static links)
- **Directory creation**: Auto-generate `docs/{zh,en,ja}/skills/` structure
- **README authoring**: Language switcher + category tables + doc links
- **Module docs**: Info table + install + reference + usage (NixKits template)
- **Skill docs**: Info table + feature list + trigger conditions
- **Parallelization**: Dispatch sub-agents for large projects
- **Verification**: File counts, link checking, term consistency

## 使用

Activated when the user asks to "write documentation" or "generate docs in NixKits style".

## Conventions

- Zero fluff, tables over prose, complete code blocks
- Technical terms remain in English
- Warnings use `> **⚠️**` blockquotes
- Three independent language files with relative-path language switchers
