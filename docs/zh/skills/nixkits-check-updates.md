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
- 自动发现 `flake.nix` 中所有外部软件包的最新 GitHub Release
- 自动更新版本号、hash、npmDepsHash
- 同步更新文档（3 语言）
- 报告本地已安装版本
- 自动排除自有软件、动态版本和 nixpkgs 补丁

## 检查范围

动态读取 `flake.nix` 中的 packages 定义，排除以下类别：
- 自有软件（源码在本地仓库内）
- 动态版本（构建时获取最新 Release）
- 跟随 nixpkgs 的补丁

其余所有外部软件包均自动纳入检查。
