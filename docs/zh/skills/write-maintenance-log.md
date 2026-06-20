# write-maintenance-log (Skill)

[中文](write-maintenance-log.md) | [English](../../en/skills/write-maintenance-log.md) | [日本語](../../ja/skills/write-maintenance-log.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/write-maintenance-log.md) | [偽中国語](../../pcn/skills/write-maintenance-log.md)

> 按 NixKits 规范撰写或更新 MAINTENANCE.md 维护日志，支持软件更新和错误修复两种记录类型，自动发现语言扩展。

## 自动发现契约

语言扩展技能通过 `translate-*` 命名约定被本技能发现：扫描 `skills/translate-*/` 目录，读取 frontmatter 中的 `language_code` / `display_name` / `base_language`，注册为多语同步流程中的可用语言。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/write-maintenance-log/SKILL.md` |

## 功能

- 撰写软件版本更新记录（摘要 + 关联 commit ID 表 + 软件版本表）
- 撰写错误修复记录（摘要 + 关联 commit ID 表）
- 自动发现语言扩展（通过 translate-* 技能），全语言同步维护日志
- 自动从前置技能（nixkits-check-updates）或 git commit message 提取摘要
- 统一的格式规范：ISO 8601 精确时间、LIFO 顺序、hash 省略无变更项

## 入口

- **记入维护记录**：软件更新后自动调用，或用户说「记入维护记录」「记录本次修复」
- **更新维护记录**：用户说「更新维护记录」「补全维护记录」时，基于 git 提交历史扫描缺失记录并补全

## 使用

由 AI 助手在软件更新完成或用户要求记录修复时激活。