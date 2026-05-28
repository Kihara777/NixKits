# NixKits

个人 NixOS flake 仓库，提供自定义包、overlay 和 NixOS 模块。

## 快速开始

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";
}
```

## 包

| 包 | 说明 | 文档 |
|---|------|------|
| kitsfmt | Nix 格式化器（AST 排序 + Best-Practice 自动修正） | [docs/kitsfmt.md](docs/kitsfmt.md) |
| opencode-telegram | OpenCode 的 Telegram Bot 客户端 | [docs/opencode-telegram.md](docs/opencode-telegram.md) |
| mcp-searxng | SearXNG 的 MCP Server | [docs/mcp-searxng.md](docs/mcp-searxng.md) |
| obs-bilibili-stream | OBS 的 Bilibili 直播插件 | [docs/obs-bilibili-stream.md](docs/obs-bilibili-stream.md) |
| llama-cpp-rocm | ROCm 加速的 llama.cpp | [docs/llama-cpp-rocm.md](docs/llama-cpp-rocm.md) |
| rcc-fix | 修补 asusctl 的二合一设备体验 | [docs/rcc-fix.md](docs/rcc-fix.md) |

支持系统：`x86_64-linux` `aarch64-linux`

## 开发

```bash
nix flake check              # 检查当前系统
nix flake check --all-systems
nix build .#kitsfmt          # 构建指定包
```

## 作者

- **狐莉 (Kitsunori)** — 创建和维护
- **小爪 (Kitsunome)** — 设计、开发 feat. deepseek-v4-pro · Qwen3.6-27B-MTP · Qwen3-Coder-Next

## License

MIT
