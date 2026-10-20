# nixkits-package-upstream 技能名（已弃用）

中文 | [English](../../en/deprecated/nixkits-package-upstream.md) | [日本語](../../ja/deprecated/nixkits-package-upstream.md)  | [偽中国語](../../pcn/deprecated/nixkits-package-upstream.md)

[← 废弃项目索引](../../../DEPRECATED.md)

**状态**：技能名已弃用（2026-10-20）
**原位置**：`skills/nixkits-package-upstream/`
**现状**：文件保留为**纯审计的适配层**，顶部带弃用声明；通用方法已移到 `upstream-audit`

## 为什么弃用

上游贡献技能被拆成两层：

| 层 | 做什么 | 在哪 |
|---|---|---|
| `upstream-audit` | 评估、规范审计、dry-run——**只读，到 dry-run 为止** | 本仓库 |
| 私有提交层 | fork / 分支 / commit / push / PR / review 回应 | 本机私有预设，不随本仓库分发 |

旧名字 `nixkits-package-upstream` 同时暗示「审计」与「提交」，而新的结构里它只剩适配层
的审计职责——**名字比职责宽，就是下一个误用的入口**。

## 迁移

- 通用审计：用 `upstream-audit`；
- 提交动作：见你所在环境里那层带授权的技能（本仓库不提供）；
- 旧名字不再出现在技能列表、注册与预设里；`MAINTENANCE.*` 中的历史记录保留旧名（历史不追改）。

## 一条判据

**名字弃用 ≠ 内容删除。** 这个技能的内容还在（作为适配层），但它**不再包含任何写操作**
——写操作被移到了需要授权的那一层。弃用的是「一个名字同时承诺两件事」这种形状。
