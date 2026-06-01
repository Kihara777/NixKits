# nixkits-skills (Skill)

[中文](nixkits-skills.md) | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md)

> 将 NixKits 技能安装到各 coding agent 目录的安装器。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | OpenCode / CodeWhale Skill |
| 路径 | `skills/nixkits-skills/SKILL.md` |

## 功能

- **本地安装**：从 NixKits 源码目录复制技能
- **在线安装**：从 GitHub 克隆后安装
- **更新检查**：对比已安装技能与源版本，提示用户更新

## 支持的 Agent

`~/.opencode/skills/` `~/.codewhale/skills/` `~/.claude/skills/` `~/.openclaw/skills/` `~/.agents/skills/`

## 管理工作流

1. 检测存在的 agent 目录
2. 检查已安装的 NixKits 技能版本
3. 发现差异时询问用户是否更新
4. 自动选择安装模式（本地/在线）
5. 执行安装并验证
