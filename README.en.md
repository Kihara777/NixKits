# NixKits

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

Personal NixOS flake repository providing custom packages, overlays, and NixOS modules.

## Quick Start

```nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";
}
```

**Recommended: use default overlay for all packages**

```nix
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
# → pkgs.codewhale  pkgs.kitsfmt  pkgs.opencode-telegram  pkgs.mcp-searxng  pkgs.obs-bilibili-stream
```

**Standalone overlays** (overlay-only packages):

```nix
inputs.nix-kits.overlays.llama-cpp-rocm  # → pkgs.llama-cpp-rocm
inputs.nix-kits.overlays.rcc-fix         # → pkgs.asusctl (patched)
```

## Packages

| Package | Description | Docs |
|---------|-------------|------|
| codewhale | DeepSeek V4 terminal coding agent | [docs/en/codewhale.md](docs/en/codewhale.md) |
| kitsfmt | Nix formatter (AST sorting + best-practice auto-fix) | [docs/en/kitsfmt.md](docs/en/kitsfmt.md) |
| opencode-telegram | OpenCode Telegram Bot client | [docs/en/opencode-telegram.md](docs/en/opencode-telegram.md) |
| mcp-searxng | MCP Server for SearXNG | [docs/en/mcp-searxng.md](docs/en/mcp-searxng.md) |
| obs-bilibili-stream | Bilibili streaming plugin for OBS | [docs/en/obs-bilibili-stream.md](docs/en/obs-bilibili-stream.md) |
| llama-cpp-rocm | ROCm-accelerated llama.cpp | [docs/en/llama-cpp-rocm.md](docs/en/llama-cpp-rocm.md) |
| rcc-fix | Patched asusctl for 2-in-1 devices | [docs/en/rcc-fix.md](docs/en/rcc-fix.md) |

Supported systems: all `lib.platforms.linux` (auto-syncs with nixpkgs)

## Authors

- **狐莉 (Kitsunori)** — creation and maintenance
- **小爪 (Kitsunome)** — design and development feat. deepseek-v4-pro (Max) · llama-cpp-rocm: Qwen3.6-27B-MTP · Qwen3.6-35B-A3B-MTP · Qwen3.5-122B-A10B-MTP · Qwen3-Coder-Next · MiniMax-M2.7

## License

MIT
