# nixkits-skills (Skill)

中文 | [English](../../en/skills/nixkits-skills.md) | [日本語](../../ja/skills/nixkits-skills.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixkits-skills.md) | [偽中国語](../../pcn/skills/nixkits-skills.md)

> 将 NixKits 技能安装或更新到编码助手目录（opencode、codewhale、codex、openclaw、agents）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixkits-skills/SKILL.md` |

## 功能

- 自动发现本地源码目录和 git remote URL
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
| Codex | `~/.codex/skills/` |
| OpenClaw | `~/.openclaw/skills/` |
| 通用 | `~/.agents/skills/` |

## 使用

由 AI 助手在用户要求「安装 skills」或「更新 NixKits 技能」时激活。

## 已知移除

**Claude Code** 已于 2026-07 移除支持，原因如下：

> Claude Code 作为一家公司享有 KYC 以及选择服务用户和国家地区的权利，但在其软件内添加「基于用户数据挖掘对用户国籍进行判断的业务逻辑」这一行为，不论出于何种目的或说辞，都已严重跨越安全模型边界，打破了最基础的用户信任。
>
> 基于以上原因，本仓库强烈建议任何使用该软件的用户重新评估必要性并在可能的情况下考虑迁移工作流，本仓库充分理解用户需求的多样性与个人选择，但本仓库有义务告知用户这一风险，且由于使用本仓库内容导致您的 Anthropic 账户产生任何异常或损失时，您承认该事件与本仓库无关。
