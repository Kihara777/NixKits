# NixKits

个人 NixOS flake 仓库，提供自定义包、overlay 和 NixOS 模块。

## 快速开始

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";
}
```

**推荐：使用 default overlay 一次性添加所有包**

```nix
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
# → pkgs.codewhale  pkgs.kitsfmt  pkgs.opencode-telegram  pkgs.mcp-searxng  pkgs.obs-bilibili-stream
```

**独立 overlay**（仅 overlay 存在的包）：

```nix
inputs.nix-kits.overlays.llama-cpp-rocm  # → pkgs.llama-cpp-rocm
inputs.nix-kits.overlays.rcc-fix         # → pkgs.asusctl (patched)
```

## 包

| 包 | 说明 | 文档 |
|---|------|------|
| codewhale | DeepSeek V4 终端编码代理 | [docs/zh/codewhale.md](docs/zh/codewhale.md) |
| kitsfmt | Nix 格式化器（AST 排序 + Best-Practice 自动修正） | [docs/zh/kitsfmt.md](docs/zh/kitsfmt.md) |
| opencode-telegram | OpenCode 的 Telegram Bot 客户端 | [docs/zh/opencode-telegram.md](docs/zh/opencode-telegram.md) |
| mcp-searxng | SearXNG 的 MCP Server | [docs/zh/mcp-searxng.md](docs/zh/mcp-searxng.md) |
| obs-bilibili-stream | OBS 的 Bilibili 直播插件 | [docs/zh/obs-bilibili-stream.md](docs/zh/obs-bilibili-stream.md) |
| llama-cpp-rocm | ROCm 加速的 llama.cpp | [docs/zh/llama-cpp-rocm.md](docs/zh/llama-cpp-rocm.md) |
| rcc-fix | 修补 asusctl 的二合一设备体验 | [docs/zh/rcc-fix.md](docs/zh/rcc-fix.md) |

支持系统：所有 `lib.platforms.linux`（自动跟随 nixpkgs）

## 作者

- **狐莉 (Kitsunori)** — 创建和维护
- **小爪 (Kitsunome)** — 设计、开发 feat. deepseek-v4-pro (Max) · llama-cpp-rocm: Qwen3.6-27B-MTP · Qwen3.6-35B-A3B-MTP · Qwen3.5-122B-A10B-MTP · Qwen3-Coder-Next · MiniMax-M2.7

## License

MIT
