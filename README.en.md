# NixKits

[中文](README.md) | [English](README.en.md) | [日本語](README.ja.md)

NixKits — a collection of software, patches, NixOS modules, and AI coding assistant skills.

## Quick Start

```nix
# Remote
inputs.nix-kits.url = "github:Kihara777/NixKits";

# Local
inputs.nix-kits.url = "path:/home/kix/NixKits";
```

## Packages

Supported systems: all `lib.platforms.linux` (auto-syncs with nixpkgs)

| Package | Description | Docs |
|---------|-------------|------|
| codewhale | DeepSeek V4 terminal coding agent | [docs/en/codewhale.md](docs/en/codewhale.md) |
| kitsfmt | Nix formatter (AST sorting + best-practice auto-fix) | [docs/en/kitsfmt.md](docs/en/kitsfmt.md) |
| opencode-telegram | OpenCode Telegram Bot client | [docs/en/opencode-telegram.md](docs/en/opencode-telegram.md) |
| mcp-searxng | MCP Server for SearXNG | [docs/en/mcp-searxng.md](docs/en/mcp-searxng.md) |
| obs-bilibili-stream | Bilibili streaming plugin for OBS | [docs/en/obs-bilibili-stream.md](docs/en/obs-bilibili-stream.md) |

## Patches

Standalone overlays not included in `default`:

```nix
nixpkgs.overlays = [
  inputs.nix-kits.overlays.llama-cpp-rocm  # → pkgs.llama-cpp-rocm
  inputs.nix-kits.overlays.rcc-fix         # → pkgs.asusctl (patched)
];
```

| Patch | Description | Docs |

## Skills

Auxiliary skills for AI coding assistants:

| Skill | Description | Docs |
|-------|-------------|------|
| recover-nixos-config | Recover deleted /etc/nixos config from Nix store | [docs/en/skills/recover-nixos-config.md](docs/en/skills/recover-nixos-config.md) |
| nixos-modern-cli | NixOS modern CLI operations guide (for AI models) | [docs/en/skills/nixos-modern-cli.md](docs/en/skills/nixos-modern-cli.md) |
| nixkits-skills | NixKits skills installer (local/online) | [docs/en/skills/nixkits-skills.md](docs/en/skills/nixkits-skills.md) |
| nixkits-check-updates | Check upstream updates and auto-upgrade | [docs/en/skills/nixkits-check-updates.md](docs/en/skills/nixkits-check-updates.md) |

## Authors

- **狐莉 (キツのり)** — creation and maintenance
- **小爪 (キツのめ)** — design and development feat. deepseek-v4-pro (Max)
- **小小爪 (キツのめ)** — hardware inference infra feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## License

[MIT](LICENSE)
