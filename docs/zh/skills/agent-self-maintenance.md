# agent-self-maintenance (Skill)

中文 | [English](../../en/skills/agent-self-maintenance.md) | [日本語](../../ja/skills/agent-self-maintenance.md)  | [偽中国語](../../pcn/skills/agent-self-maintenance.md)

> 用五个「会失败」的小机制让 AI 编码助手长期维护自己的记忆。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/agent-self-maintenance/SKILL.md` |
| 适用 | 任何有 `journal/` 与自检脚本的仓库 |

## 五个机制

| 机制 | 判据 | 边界 |
|---|---|---|
| 日记闸门 | 有提交且当日日记未改 → 提醒一次 | 没配置就安静 |
| 开局对账 | 读收据 / 日记 / 事实；ok / red / stale 不合并 | 「没跑过」要说出来 |
| 事实核查 | 每条带探针；`无法核验` 是第三种状态 | 数据留在仓库 |
| 自我观察 | 她说的 / 我量的 / 不确定，分开记 | 条目带日期与证据 |
| 自检收据 | 五种状态，只有 `ok` 安静 | 收据不进版本库 |

## 数据归属

机制可移植，**数据不搬**：事实条目、观察条目、阈值都属于各仓库自己。

## 参考实现

dsh 的本机私有预设（（私有预设））是这五个机制的一份完整实现。
