# nixkits-package-upstream (Skill)

中文 | [English](../../en/skills/nixkits-package-upstream.md) | [日本語](../../ja/skills/nixkits-package-upstream.md)  | [偽中国語](../../pcn/skills/nixkits-package-upstream.md)

> NixKits 的 nixpkgs 上游贡献适配层：13 个包的可行性台账、许可缺口处置、四语同步与自检登记。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-package-upstream/SKILL.md` |
| 依赖 | [`nixpkgs-package-upstream`](nixpkgs-package-upstream.md)（通用方法） |

## 功能

- **可行性台账**：13 个包各自「能不能提、为什么」的现状（取证基线 nixpkgs master `78f093ad1`）
- **三条最容易踩的**：`mcp-searxng` 已在 nixpkgs 里、`dsh` 在 nixpkgs 里叫
  `deepseek-harness` 且已有 3 个在途 PR、`kitsfmt` 的上游仓 404
- **过期自述的更正**：本仓写过「nixpkgs 已不再提供 ruyi 包」，实际是从未有过
- **许可缺口**：许可依据必须在**取源的那个 tag 里**，main 上新加的不算
- **dry-run 落点**：`upstream/<包名>/`，不落 `/tmp`
- **登记与同步**：四语 README 索引 + 四语技能文档页（含语言切换器）+ 维护日志 + 自检项数

## 使用

由 AI 助手在 NixKits 仓库里执行上游贡献时激活，**在通用技能之后读**。

其余仓库特有的环节（`flake.lock` 不提交、`git fetch origin` 对齐远端、
跨语言文件整组提交、pcn 不得出现非日文字形）沿用 `AGENTS.md` 与既有技能。
