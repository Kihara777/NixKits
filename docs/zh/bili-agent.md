# bili-agent

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-x86_64.yml?branch=main&label=x86_64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-bili-agent-aarch64.yml?branch=main&label=aarch64%20v1.3.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/bili-agent.md) | [日本語](../ja/bili-agent.md)  | [偽中国語](../pcn/bili-agent.md)

为 AI 代理设计的 B 站命令行工具：每条命令只在 stdout 输出**一个 JSON**、零交互，
账号操作自带限流、审计日志与私信白名单。命令名是 `bili`。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 1.3.0 |
| 上游 | [kukemc/bili-cli](https://github.com/kukemc/bili-cli) |
| 类型 | Python 应用（hatchling） |
| 许可 | MIT |
| 平台 | x86_64 / aarch64 |
| 命令 | `bili` |

## 为什么本仓还自带一个库

上游钉死 `bilibili-api-python==17.4.2`，而 **nixpkgs 没有那个库**（2026-11-04 点名查过）。
所以本仓同时打 `packages/bilibili-api-python.nix`：12 个运行期依赖全部来自 nixpkgs，
构建期额外需要 `setuptools-scm`——放错层的症状是构建期 `Unmet dependencies … setuptools-scm`。

用 nixpkgs 里的新版本替代是**不可行的选项**：`==` 是硬约束，跳过检查后撞的是运行期行为差异
（同一族的 `blender-mcp` 就吃过 `mcp<2` 的亏）。

## 用法

```bash
bili auth status          # 先看登录态
bili feed inbox           # 这一轮有什么新消息
bili video watch <BV>     # 信息 + AI 总结 + 全文 + 热评 + 弹幕高发 + 画面总览
bili schema               # 全部命令的机器可读描述
```

写操作都支持 `--dry-run`。完整的命令表见技能 `bili-cli`（掌灯模式内）或上游 `skills/bili-cli/SKILL.md`。

## 登录

扫码，一次性：`bili auth login` 给出 `qr_image`（本机 PNG 路径）与 180 秒有效的 `qr_url`，
用哔哩哔哩 App 扫；之后 `bili auth status --wait 120`。凭据落在 `~/.config/bili-cli/`，
**不进 nix store、不进仓库**。

## 已知边界

- 只打了 x86_64 与 aarch64。riscv64 没有 workflow——`curl-cffi` 在 riscv64 上的支持没验过，
  **不写就不承诺**。
- 上游是 MIT，但闭包里那个 `bilibili-api-python` 是 GPL-3.0-or-later；两者的分发义务分别适用。
