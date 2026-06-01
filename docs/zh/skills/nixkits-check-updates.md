# nixkits-check-updates (Skill)

[中文](nixkits-check-updates.md) | [English](../../en/skills/nixkits-check-updates.md) | [日本語](../../ja/skills/nixkits-check-updates.md)

> 检查 NixKits 中所有外部软件包的上游更新，自动更新构建配置和文档。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-check-updates/SKILL.md` |

## 功能

- 确认用户位于本地 NixKits 仓库
- 检查 4 个外部软件包的最新 GitHub Release
- 自动更新版本号、hash、npmDepsHash
- 同步更新文档（3 语言）
- 报告本地已安装版本

## 检查范围

`opencode-telegram` `mcp-searxng` `obs-bilibili-stream` `codewhale`

> 跳过自有软件（kitsfmt）、动态版本（llama-cpp-rocm）、跟随 nixpkgs（rcc-fix）
