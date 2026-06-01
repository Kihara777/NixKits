# nixos-modern-cli (Skill)

[中文](nixos-modern-cli.md) | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md)

> 帮助 AI 模型正确理解 NixOS 与传统 Linux 的区别，使用现代 CLI 进行系统维护。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixos-modern-cli/SKILL.md` |

## 安装

复制到任意 coding agent 技能目录：

```
~/.opencode/skills/
~/.codewhale/skills/
~/.claude/skills/
~/.openclaw/skills/
~/.agents/skills/
```

## 解决的问题

低参数量模型常将 NixOS 误认为传统 Linux 发行版，导致：
- 尝试使用 `apt`/`yum` 安装软件
- 无法找到常用命令的路径
- 不知道如何应用配置变更

此技能提供完整的 NixOS 操作指南。

## 核心内容

- NixOS 声明式、不可变系统的关键区别
- 现代 CLI 优先（`nixos`/`nix` > `nixos-rebuild`/`nix-env`）
- shell 环境与临时工具安装
- 系统更新与维护流程
- 常见陷阱与解决方案
