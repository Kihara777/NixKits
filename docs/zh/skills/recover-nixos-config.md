# recover-nixos-config (Skill)

[中文](recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/recover-nixos-config.md)

> 当用户误删 `/etc/nixos` 下的文件时，从 Nix store 中恢复。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/recover-nixos-config/SKILL.md` |

## 功能

- 在 Nix store 中定位最近一次成功构建的 flake 源码快照
- 按主机名搜索 `*-source` 目录
- 确认最新 generation 对应的正确源码
- 恢复指定文件（flake.nix、flake.lock、各模块）
- 验证恢复后的配置（`nix flake check`）

## 使用

由 AI 助手在用户报告「误删了 /etc/nixos 下的文件」时激活。
