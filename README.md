# NixKits

[![CI](https://github.com/Kihara777/NixKits/actions/workflows/check.yml/badge.svg)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](docs/README.en.md) | [日本語](docs/README.ja.md) | [ｶﾀﾘｯｼｭ](docs/README.katalish.md) | [偽中国語](docs/README.pcn.md)

NixKits — 软件、补丁、NixOS 模块与 AI 编码助手的技能合集。

## 添加

```nix
# 远程
inputs.nixkits.url = "github:Kihara777/NixKits";

# 本地
inputs.nixkits.url = "/home/kix/NixKits";
```

> **二进制缓存**（避免本地编译）
>
> ```bash
> cachix use nixkits       # 首次使用需安装 cachix：nix profile install nixpkgs#cachix
> ```
>
> 缓存覆盖全部 6 个软件包（x86_64-linux），由 CI 自动构建推送。
>
> [![Cache](https://img.shields.io/badge/cache-cachix-blue)](https://app.cachix.org/cache/nixkits)
> [![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://nixos.org)

## 软件

支持系统：`lib.platforms.linux`（codewhale 限 x86_64 / aarch64 / riscv64，其余自动跟随 nixpkgs）

| 软件 | 说明 | 文档 |
|---|------|------|
| codewhale | DeepSeek V4 终端编码代理 | [docs/zh/codewhale.md](docs/zh/codewhale.md) |
| kitsfmt | Nix 格式化器（AST 排序 + Best-Practice 自动修正） | [docs/zh/kitsfmt.md](docs/zh/kitsfmt.md) |
| mcp-searxng | SearXNG 的 MCP Server | [docs/zh/mcp-searxng.md](docs/zh/mcp-searxng.md) |
| obs-bilibili-stream | OBS 的 Bilibili 直播插件 | [docs/zh/obs-bilibili-stream.md](docs/zh/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 的 Telegram Bot 客户端 | [docs/zh/opencode-telegram.md](docs/zh/opencode-telegram.md) |
| ruyi | RuyiSDK 包管理器（RISC-V 开发工具） | [docs/zh/ruyi.md](docs/zh/ruyi.md) |
| comfyui-strix-halo | 为 AMD Strix Halo (gfx1151/RDNA3.5) 提供 ComfyUI ROCm 支持 | [docs/zh/comfyui-strix-halo.md](docs/zh/comfyui-strix-halo.md) |

## 开发

提供 `nix develop` 即用环境。首先添加 registry：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 包 | `nix develop` |
|------|---------------|
| ruyi | `nix develop nixkits#ruyi` |

## 补丁

独立 overlay，不包含在 `default` 内：

| 补丁 | 说明 | 文档 |
|------|------|------|
| llama-cpp-rocm | 动态追踪上游最新 Release 的 ROCm 加速构建 | [docs/zh/llama-cpp-rocm.md](docs/zh/llama-cpp-rocm.md) |
| rcc-fix | 修补 asusctl 的二合一设备体验 | [docs/zh/rcc-fix.md](docs/zh/rcc-fix.md) |
| ruyi-nixos-compat | NixOS 运行时兼容（ELF interpreter 重定向 + GCC 修复） | [docs/zh/ruyi-nixos-compat.md](docs/zh/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | 为 ComfyUI 提供 ROCm 功能补丁 | [docs/zh/comfyui-rocm-patch.md](docs/zh/comfyui-rocm-patch.md) |
| rog-control-center-fix | 修复 asusd 关机时的死锁问题 | [docs/zh/rog-control-center-fix.md](docs/zh/rog-control-center-fix.md) |

## 技能

供 AI 编码助手使用的技能：

> 本项目的技能主要面向中文用户和中国开源模型，所有 SKILL.md 均使用中文编写。

| 技能 | 说明 | 文档 |
|------|------|------|
| nixkits-check-updates | 检查上游软件更新并自动升级 | [docs/zh/skills/nixkits-check-updates.md](docs/zh/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits 技能安装器（本地/在线） | [docs/zh/skills/nixkits-skills.md](docs/zh/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS 现代 CLI 操作指南（面向 AI 模型） | [docs/zh/skills/nixos-modern-cli.md](docs/zh/skills/nixos-modern-cli.md) |
| recover-nixos-config | 从 Nix store 恢复误删的 /etc/nixos 配置 | [docs/zh/skills/recover-nixos-config.md](docs/zh/skills/recover-nixos-config.md) |
| translate-katalish | ｶﾀﾘｯｼｭ 翻译（半角片假名逐词机械替换英文文档） | [docs/zh/skills/translate-katalish.md](docs/zh/skills/translate-katalish.md) |
| translate-pseudocn | 偽中国語翻译（日语假名剥离 + 语序转换） | [docs/zh/skills/translate-pseudocn.md](docs/zh/skills/translate-pseudocn.md) |
| write-maintenance-log | 按 NixKits 规范撰写维护日志（软件更新 + 错误修复） | [docs/zh/skills/write-maintenance-log.md](docs/zh/skills/write-maintenance-log.md) |
| write-project-docs | 按 NixKits 风格为任意项目编写多语言文档系统 | [docs/zh/skills/write-project-docs.md](docs/zh/skills/write-project-docs.md) |

## 作者

- **狐莉 (キツのり)** — 创建和维护
- **小爪 (キツのめ)** — 设计、开发 feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — 硬件推理基础设施 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 许可

[MIT](LICENSE)