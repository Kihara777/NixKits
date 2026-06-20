# nixos-modern-cli (Skill)

中文 | [English](../../en/skills/nixos-modern-cli.md) | [日本語](../../ja/skills/nixos-modern-cli.md) | [ｶﾀﾘｯｼｭ](../../katalish/skills/nixos-modern-cli.md) | [偽中国語](../../pcn/skills/nixos-modern-cli.md)

> 在 NixOS 系统上工作时激活。确保使用现代 Nix CLI、完整 shell 能力和正确的系统维护流程。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/nixos-modern-cli/SKILL.md` |

## 功能

- 纠正 AI 模型将 NixOS 当作传统 Linux 发行版的常见错误
- 提供现代 vs 传统 CLI 命令对照表
- 指导使用 `nix shell --command` 运行需要 POSIX 工具的脚本
- 包含常用 POSIX 工具的 nixpkgs 包名对照表
- 提供系统维护、日志查看、垃圾回收的完整命令参考
- 列出 NixOS 特有陷阱（PATH、nix-env 持久性等）
- 诊断 Nix Store 路径陷阱：识别并修复因 GC 回收导致失效的硬编码 `/nix/store/` 路径（如 `gh auth setup-git` 凭据助手）

## 使用

由 AI 助手在检测到 NixOS 环境时自动激活，或用户显式要求「使用现代 nix 命令」时激活。
