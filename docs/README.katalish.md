# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | ｶﾀﾘｯｼｭ | [偽中国語](README.pcn.md)

NixKits — ｱ ｺﾚｸｼｮﾝ of ｿﾌﾄｳｪｱ, patches, NixOS ﾓｼﾞｭｰﾙs, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ ｱｼｽﾀﾝﾄ skills.

## Quick Start

```nix
# Remote
inputs.nixkits.url = "github:Kihara777/NixKits";

# Local
inputs.nixkits.url = "/home/kix/NixKits";
```

## Software

All packages follow nixpkgs platform ｻﾎﾟｰﾄ by default (`lib.platforms.linux`). Some packages have architecture restrictions due to ｳﾌﾟｽﾄﾗｴｱﾑ — see build badges in each package's ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ.

| Software | Description | Docs |
|---|------|------|
| blender-mcp | MCP ｻｰﾊﾞｰ for Blender (natural language control of Blender) | [docs/katalish/blender-mcp.md](katalish/blender-mcp.md) |
| codewhale | DeepSeek V4 terminal ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [docs/katalish/codewhale.md](katalish/codewhale.md) |
| kitsfmt | Nix ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice auto-fixes) | [docs/katalish/kitsfmt.md](katalish/kitsfmt.md) |
| mcp-searxng | MCP ｻｰﾊﾞｰ for SearXNG | [docs/katalish/mcp-searxng.md](katalish/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili streaming ﾌﾟﾗｸﾞｲﾝ | [docs/katalish/obs-bilibili-stream.md](katalish/obs-bilibili-stream.md) |
| opencode-telegram | Telegram Bot client for OpenCode | [docs/katalish/opencode-telegram.md](katalish/opencode-telegram.md) |
| ruyi | RuyiSDK package ﾑｱﾝｱｼﾞｴﾗ (RISC-V development tools)<br>stable 0.50.0 · beta 0.50.0-beta.20260623 · alpha 0.51.0-alpha.20260616 | [docs/katalish/ruyi.md](katalish/ruyi.md) |

> ⚠️ comfyui-strix-halo is a ﾓｼﾞｭｰﾙ+patch, not a standalone package, ｱﾝﾄﾞ is not in ｻﾞ binary cache.

## Development

`nix develop` ready-to-use environments. First, add ｻﾞ registry:

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| Package | `nix develop` |
|---------|---------------|
| ruyi | `nix develop nixkits#ruyi` |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` |

## Patches

Standalone overlays, not included in `default`:

| Patch | Description | Docs |
|------|------|------|
| llama-cpp-rocm | ROCm-accelerated builds tracking latest upstream release | [docs/katalish/llama-cpp-rocm.md](katalish/llama-cpp-rocm.md) |
| rcc-fix | Fixes 2-in-1 device experience for asusctl | [docs/katalish/rcc-fix.md](katalish/rcc-fix.md) |
| comfyui-rocm-patch | ComfyUI ROCm functional patch | [docs/katalish/comfyui-rocm-patch.md](katalish/comfyui-rocm-patch.md) |
| rog-control-center-fix | Fixes asusd deadlock on shutdown | [docs/katalish/rog-control-center-fix.md](katalish/rog-control-center-fix.md) |

> ⚠️ Patches are overlays that modify upstream nixpkgs packages rather than independent builds, ｱﾝﾄﾞ are not in ｻﾞ binary cache. Dynamically versioned projects (e.g. llama-cpp-rocm) have hashes that change ｳｨｽﾞ upstream releases ｱﾝﾄﾞ cannot be cached.

## Skills

For AI ｺｰﾃﾞｨﾝｸﾞ assistants:

> Skills in this project are primarily aimed at Chinese-speaking users ｱﾝﾄﾞ Chinese open-source models. All SKILL.md files are written in Chinese.

> ⚠️ **Claude Code** has been removed from nixkits-skills install targets. The software implements nationality inference based on user data, crossing a security boundary. See [nixkits-skills docs](katalish/skills/nixkits-skills.md).

| Skill | Description | Docs |
|------|------|------|
| nixkits-check-updates | Check for upstream updates ｱﾝﾄﾞ auto-upgrade | [docs/katalish/skills/nixkits-check-updates.md](katalish/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits skill installer (local/online) | [docs/katalish/skills/nixkits-skills.md](katalish/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern CLI guide (for AI models) | [docs/katalish/skills/nixos-modern-cli.md](katalish/skills/nixos-modern-cli.md) |
| recover-nixos-config | Recover deleted /etc/nixos config from Nix store | [docs/katalish/skills/recover-nixos-config.md](katalish/skills/recover-nixos-config.md) |
| translate-katalish | Katakana English translation (mechanical word-level substitution of English docs) | [docs/katalish/skills/translate-katalish.md](katalish/skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-Chinese translation (kana stripping + word order conversion from Japanese) | [docs/katalish/skills/translate-pseudocn.md](katalish/skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md entries per NixKits spec (software updates + bug fixes) | [docs/katalish/skills/write-maintenance-log.md](katalish/skills/write-maintenance-log.md) |
| write-project-docs | Write multilingual documentation for any project in NixKits style | [docs/katalish/skills/write-project-docs.md](katalish/skills/write-project-docs.md) |

## Credits

- **狐莉 (ｷﾂﾉﾘ)** — creator ｱﾝﾄﾞ maintainer
- **小爪 (ｷﾂﾉﾒ)** — design, development feat. DeepSeek V4 Pro (Max)
- **小小爪 (ｷﾂﾉﾒ)** — hardware inference infrastructure feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## License

[MIT](../LICENSE)