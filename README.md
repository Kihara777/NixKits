# NixKits

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

NixKits — 软件、补丁、NixOS 模块与 AI 编码助手的技能合集。

## 添加

```nix
# 远程
inputs.nix-kits.url = "github:Kihara777/NixKits";

# 本地
inputs.nix-kits.url = "path:/home/kix/NixKits";
```

## 软件

支持系统：所有 `lib.platforms.linux`（自动跟随 nixpkgs）

| 软件 | 说明 | 文档 |
|---|------|------|
| codewhale | DeepSeek V4 终端编码代理 | [docs/zh/codewhale.md](docs/zh/codewhale.md) |
| kitsfmt | Nix 格式化器（AST 排序 + Best-Practice 自动修正） | [docs/zh/kitsfmt.md](docs/zh/kitsfmt.md) |
| opencode-telegram | OpenCode 的 Telegram Bot 客户端 | [docs/zh/opencode-telegram.md](docs/zh/opencode-telegram.md) |
| mcp-searxng | SearXNG 的 MCP Server | [docs/zh/mcp-searxng.md](docs/zh/mcp-searxng.md) |
| obs-bilibili-stream | OBS 的 Bilibili 直播插件 | [docs/zh/obs-bilibili-stream.md](docs/zh/obs-bilibili-stream.md) |

## 补丁

独立 overlay，不包含在 `default` 内：

```nix
nixpkgs.overlays = [
  inputs.nix-kits.overlays.llama-cpp-rocm  # → pkgs.llama-cpp-rocm
  inputs.nix-kits.overlays.rcc-fix         # → pkgs.asusctl (patched)
];
```

| 补丁 | 说明 | 文档 |

## 技能

供 AI 编码助手使用的技能：

| 技能 | 说明 | 文档 |
|------|------|------|
| recover-nixos-config | 从 Nix store 恢复误删的 /etc/nixos 配置 | [docs/zh/skills/recover-nixos-config.md](docs/zh/skills/recover-nixos-config.md) |
| nixos-modern-cli | NixOS 现代 CLI 操作指南（面向 AI 模型） | [docs/zh/skills/nixos-modern-cli.md](docs/zh/skills/nixos-modern-cli.md) |
| nixkits-skills | NixKits 技能安装器（本地/在线） | [docs/zh/skills/nixkits-skills.md](docs/zh/skills/nixkits-skills.md) |
| nixkits-check-updates | 检查上游软件更新并自动升级 | [docs/zh/skills/nixkits-check-updates.md](docs/zh/skills/nixkits-check-updates.md) |

## 作者

- **狐莉 (キツのり)** — 创建和维护
- **小爪 (キツのめ)** — 设计、开发 feat. deepseek-v4-pro (Max)
- **小小爪 (キツのめ)** — 硬件推理基础设施 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 许可

[MIT](LICENSE)
