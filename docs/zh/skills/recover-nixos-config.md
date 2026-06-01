# recover-nixos-config (Skill)

[中文](recover-nixos-config.md) | [English](../../en/skills/recover-nixos-config.md) | [日本語](../../ja/skills/recover-nixos-config.md)

> Coding Agent 技能：从 Nix store 恢复误删的 `/etc/nixos` 配置文件。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Coding Agent Skill |
| 路径 | `skills/recover-nixos-config/SKILL.md` |

## 触发条件

当用户误删 `/etc/nixos` 下的文件（`flake.nix`、`flake.lock` 等）且系统之前成功构建过时，AI 助手自动调用此技能进行恢复。

## 恢复原理

每次 `nixos-rebuild` 成功后，Nix 会将当时的 `/etc/nixos` flake 源文件快照保存到 Nix store（`*-source` 目录）。即使本地文件被删除，仍可从 store 中完整恢复。

## 安装

将 `skills/` 目录复制到以下任意位置：

```
~/.agents/skills/
~/.codewhale/skills/
~/.opencode/skills/
```

## 使用

由 AI 助手在检测到 `/etc/nixos` 文件丢失时自动激活，无需手动调用。恢复流程：

1. 在 Nix store 中搜索主机名对应的源快照
2. 确认最新构建 generation 的源目录
3. 验证文件内容
4. 复制丢失的文件回 `/etc/nixos`
5. 运行 `nix flake check` 验证
