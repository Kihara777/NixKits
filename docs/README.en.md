# NixKits

[中文](../README.md) | English | [日本語](README.ja.md)  | [偽中国語](README.pcn.md)

NixKits — a collection of software, patches, NixOS modules, and AI coding assistant skills.

## Quick Start

```nix
# Remote
inputs.nixkits.url = "github:Kihara777/NixKits";

# Local
inputs.nixkits.url = "~/NixKits";
```

## Software

All packages follow nixpkgs platform support by default (`lib.platforms.linux`). Some packages have architecture restrictions due to upstream — see build badges in each package's documentation.

| Software | Description | Docs |
|---|------|------|
| blender-mcp | MCP server for Blender (natural language control of Blender) | [docs/en/blender-mcp.md](en/blender-mcp.md) |
| codewhale | DeepSeek V4 terminal coding agent | [docs/en/codewhale.md](en/codewhale.md) |
| dsh | DeepSeek Harness (DSH) — Everything is a Plugin | [docs/en/dsh.md](en/dsh.md) |
| godot-ai | MCP server and AI tools for the Godot engine | [docs/en/godot-ai.md](en/godot-ai.md) |
| kitsfmt | Nix formatter (AST sorting + best-practice auto-fixes) | [docs/en/kitsfmt.md](en/kitsfmt.md) |
| mcp-searxng | MCP server for SearXNG | [docs/en/mcp-searxng.md](en/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili streaming plugin | [docs/en/obs-bilibili-stream.md](en/obs-bilibili-stream.md) |
| opencode-telegram | Telegram Bot client for OpenCode | [docs/en/opencode-telegram.md](en/opencode-telegram.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK Package Manager (RISC-V dev tools)<br>stable 0.51.0 · beta 0.51.0-beta.20260714 · alpha 0.52.0-alpha.20260714 | [docs/en/ruyi.md](docs/en/ruyi.md) |


## Plugins

DeepSeek Harness (DSH) components are listed separately from software (mounting instructions in [docs/en/dsh.md](en/dsh.md)):

| Plugin | Description | Docs |
|--------|-------------|------|
| dsh-nixos-shell | Consolidated NixOS operations (shell execution, tool bootstrap, sudo daemon routing, NixOS diagnostics) | [docs/en/dsh-nixos-shell.md](en/dsh-nixos-shell.md) |

**Agent presets** (shipped with dsh-nixos-shell, seeded once into DSH via `nixkits.dsh.presets`):

| Preset | Description |
|--------|-------------|
| NixOS模式 (id `nixos`) | Verifies a NixOS host at init (refuses everything otherwise); loads `nixos_shell`/`nixos_cli` plus the NixOS development guidance |
| 维护模式 (id `maintenance`) | Based on NixOS模式; injects `write-project-docs`/`write-maintenance-log`/`translate-*` skills plus the repo-maintenance workflow |

## Development

`nix develop` ready-to-use environments. First, add the registry:

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| Environment | Command | Doc |
|---------|---------------|-----|
| opencode | `nix develop nixkits#opencode` | [en/opencode-devshell.md](en/opencode-devshell.md) |
| ruyi | `nix develop nixkits#ruyi` | [en/ruyi-devshell.md](en/ruyi-devshell.md) |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |  |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` |  |

## Patches

Standalone overlays, not included in `default`:

| Patch | Description | Docs |
|------|------|------|
| llama-cpp-rocm | ROCm-accelerated builds tracking latest upstream release | [docs/en/llama-cpp-rocm.md](en/llama-cpp-rocm.md) |
| rcc-fix | Fixes 2-in-1 device experience for asusctl | [docs/en/rcc-fix.md](en/rcc-fix.md) |
| comfyui-rocm | ComfyUI ROCm functional patch | [docs/en/comfyui-rocm.md](en/comfyui-rocm.md) |
| efl-cross-fix | Fixes efl cross-compilation code-gen tooling | [docs/en/efl-cross-fix.md](en/efl-cross-fix.md) |
| breeze-black | Plasma 6 high-contrast Breeze Black accessibility theme | [docs/en/breeze-black.md](en/breeze-black.md) |
| codewhale-sudo | overlay — restore sudo under codewhale v0.9.8 (ptrace interceptor) | [docs/en/codewhale-sudo.md](en/codewhale-sudo.md) |

> ⚠️ Patches are overlays that modify upstream nixpkgs packages rather than independent builds, and are not in the binary cache. Dynamically versioned projects (e.g. llama-cpp-rocm) have hashes that change with upstream releases and cannot be cached.

> ⚠️ Patches are overlays that modify upstream nixpkgs packages rather than independent builds, and are not in the binary cache. Dynamically versioned projects (e.g. llama-cpp-rocm) have hashes that change with upstream releases and cannot be cached.

## Skills

For AI coding assistants:

> Skills in this project are primarily aimed at Chinese-speaking users and Chinese open-source models. All SKILL.md files are written in Chinese.

| Skill | Description | Docs |
|------|------|------|
> ⚠️ **Claude Code** has been removed from nixkits-skills install targets. The software implements nationality inference based on user data, crossing a security boundary. See [nixkits-skills docs](en/skills/nixkits-skills.md).
| nixkits-check-updates | Check for upstream updates and auto-upgrade | [docs/en/skills/nixkits-check-updates.md](en/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits skill installer (local/online) | [docs/en/skills/nixkits-skills.md](en/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern CLI guide (for AI models) | [docs/en/skills/nixos-modern-cli.md](en/skills/nixos-modern-cli.md) |
| recover-nixos-config | Recover deleted /etc/nixos config from Nix store | [docs/en/skills/recover-nixos-config.md](en/skills/recover-nixos-config.md) |
| translate-pseudocn | Pseudo-Chinese translation (kana stripping + word order conversion from Japanese) | [docs/en/skills/translate-pseudocn.md](en/skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md entries per NixKits spec (software updates + bug fixes) | [docs/en/skills/write-maintenance-log.md](en/skills/write-maintenance-log.md) |
| write-project-docs | Write multilingual documentation for any project in NixKits style | [docs/en/skills/write-project-docs.md](en/skills/write-project-docs.md) |

## Credits

- **狐莉 (キツのり)** — creator and maintainer
- **小爪 (キツのめ)** — design, development feat. DeepSeek V4 Pro (Max) · DeepSeek Harness (DSH) ecosystem (dsh-nixos-shell plugin and NixOS-mode/maintenance-mode agent presets)
- **小小爪 (キツのめ)** — hardware inference infrastructure feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## License

[MIT](../LICENSE)