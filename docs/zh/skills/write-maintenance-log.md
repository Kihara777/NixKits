# write-maintenance-log (Skill)

[中文](write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md)

> 按 NixKits 统一规范撰写或更新 MAINTENANCE.md 维护日志，支持软件更新和错误修复两种记录类型。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-maintenance-log/SKILL.md` |

## 功能

- 撰写软件版本更新记录（摘要 + 关联 commit ID 表 + 软件版本表）
- 撰写错误修复记录（摘要 + 关联 commit ID 表）
- 三语同步（zh/en/ja）维护日志
- 自动从前置技能（nixkits-check-updates）或 git commit message 提取摘要
- 统一的格式规范：ISO 8601 精确时间、LIFO 顺序、hash 省略无变更项

## 触发

- **自动触发**：nixkits-check-updates 技能执行完成后
- **用户触发**：「记录本次修复」「写入维护日志」「更新 MAINTENANCE」

## 使用

由 AI 助手在软件更新完成或用户要求记录修复时激活。