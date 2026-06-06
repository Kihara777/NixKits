# nixkits-skills (Skill)

[中文](nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md)

> 将 NixKits 技能安装或更新到编码助手目录（opencode、codewhale、claude、openclaw、agents）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-skills/SKILL.md` |

## 功能

- 检测已安装编码助手的技能目录
- 对比本地技能版本与 NixKits 源码差异
- 支持本地安装（从源码目录）和在线安装（从 GitHub 克隆）
- 安装前展示差异并请求用户确认
- 安装后验证副本一致性

## 支持的助手

| 助手 | 目录 |
|------|------|
| OpenCode | `~/.opencode/skills/` |
| CodeWhale | `~/.codewhale/skills/` |
| Claude Code | `~/.claude/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 通用 | `~/.agents/skills/` |

## 使用

由 AI 助手在用户要求「安装 skills」或「更新 NixKits 技能」时激活。
