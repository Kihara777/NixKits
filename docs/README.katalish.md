# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md)

NixKits — ｱ collection ｵﾌﾞ ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ assistant ｽｷﾙｽﾞ.

## Quick ｽﾀｰﾄ

```nix
# Remote
ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "github:Kihara777/NixKits";

# Local
ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "/ﾎｰﾑ/kix/NixKits";
```

## ﾊﾟｯｹｰｼﾞｰｽﾞ

Supported systems: ｵｰﾙ `lib.platforms.linux` (auto-syncs ｳｨｽﾞ nixpkgs)

| ﾊﾟｯｹｰｼﾞ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|---------|-------------|------|
| codewhale | DeepSeek V4 ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [docs/en/codewhale.md](docs/en/codewhale.md) |
| kitsfmt | ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice auto-fix) | [docs/en/kitsfmt.md](docs/en/kitsfmt.md) |
| mcp-searxng | ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ﾌｫｱ SearXNG | [docs/en/mcp-searxng.md](docs/en/mcp-searxng.md) |
| obs-bilibili-stream | Bilibili ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ OBS | [docs/en/obs-bilibili-stream.md](docs/en/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode Telegram ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ | [docs/en/opencode-telegram.md](docs/en/opencode-telegram.md) |

## ﾊﾟｯﾁｰｽﾞ

Standalone overlays ﾉｯﾄ included ｲﾝ `default`:

| ﾊﾟｯﾁ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|-------|-------------|------|
| comfyui-strix-halo | ｶﾑﾌｨUI ﾛｯｸｴﾑ ｻﾎﾟｰﾄ ﾌｫｱ AMD Strix Halo (gfx1151/RDNA 3.5) | [docs/en/comfyui-strix-halo.md](docs/en/comfyui-strix-halo.md) |
| llama-cpp-rocm | ROCm-accelerated ﾋﾞﾙﾄﾞ tracking latest GitHub Release | [docs/en/llama-cpp-rocm.md](docs/en/llama-cpp-rocm.md) |
| rcc-fix | Patched asusctl ﾌｫｱ 2-in-1 devices | [docs/en/rcc-fix.md](docs/en/rcc-fix.md) |

## ｽｷﾙｽﾞ

Auxiliary ｽｷﾙｽﾞ ﾌｫｱ AI ｺｰﾃﾞｨﾝｸﾞ assistants:

> ﾃﾞｨｰｽﾞ ｽｷﾙｽﾞ ｱｰ written ｲﾝ Chinese, primarily targeting Chinese-speaking ﾕｰｻﾞｰｽﾞ ｱﾝﾄﾞ Chinese open-source LLMs.

| ｽｷﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|-------|-------------|------|
| nixkits-check-updates | ﾁｪｯｸ upstream ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｱﾝﾄﾞ auto-upgrade | [docs/en/skills/nixkits-check-updates.md](docs/en/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits ｽｷﾙｽﾞ installer (local/online) | [docs/en/skills/nixkits-skills.md](docs/en/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern CLI operations ｶﾞｲﾄﾞ (ﾌｫｱ AI models) | [docs/en/skills/nixos-modern-cli.md](docs/en/skills/nixos-modern-cli.md) |
| recover-nixos-config | ﾘｶﾊﾞｰ deleted /etc/ﾆｯｸｽOS ｺﾝﾌｨｸﾞ ﾌﾛﾑ ﾆｯｸｽ store | [docs/en/skills/recover-nixos-config.md](docs/en/skills/recover-nixos-config.md) |
| write-project-docs | ｼﾞｪﾈﾚｲﾄ multi-language ﾌﾟﾛｼﾞｪｸﾄ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ｲﾝ NixKits style | [docs/en/skills/write-project-docs.md](docs/en/skills/write-project-docs.md) |

## Authors

- **狐莉 (キツのり)** — creation ｱﾝﾄﾞ ﾒﾝﾃﾅﾝｽ
- **小爪 (キツのめ)** — design ｱﾝﾄﾞ ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — hardware inference infra feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](LICENSE)