# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | [ｶﾀﾘｯｼｭ](README.katalish.md)

NixKits — ｱ collection ｵﾌﾞ ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ assistant ｽｷﾙｽﾞ.

## Quick ｽﾀｰﾄ

```nix
# Remote
ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "github:Kihara777/NixKits";

# Local
ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "/ﾎｰﾑ/kix/NixKits";
```

## ｿﾌﾄｳｪｱ

Compatible ｳｨｽﾞ ｵｰﾙ `lib.platforms.linux` — ﾌｫﾛｰｽﾞ nixpkgs automatically.

| ｿﾌﾄｳｪｱ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|---|------|------|
| codewhale | DeepSeek V4 ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [docs/zh/codewhale.md](codewhale.md) |
| kitsfmt | ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice auto-fixes) | [docs/zh/kitsfmt.md](kitsfmt.md) |
| mcp-searxng | ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ﾌｫｱ SearXNG | [docs/zh/mcp-searxng.md](mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ | [docs/zh/obs-bilibili-stream.md](obs-bilibili-stream.md) |
| opencode-telegram | Telegram ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ ﾌｫｱ OpenCode | [docs/zh/opencode-telegram.md](opencode-telegram.md) |
| ruyi | RuyiSDK ﾊﾟｯｹｰｼﾞ manager (RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾂｰﾙｽﾞ) | [docs/zh/ruyi.md](ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ｶﾑﾌｨUI ﾛｯｸｴﾑ ｻﾎﾟｰﾄ | [docs/zh/comfyui-strix-halo.md](comfyui-strix-halo.md) |

## ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ

`nix develop` ready-to-use environments. ﾌｧｰｽﾄ, ｱﾄﾞ ｻﾞ ﾚｼﾞｽﾄﾘ:

```bash
ﾆｯｸｽ ﾚｼﾞｽﾄﾘ ｱﾄﾞ nix-kits github:Kihara777/NixKits
```

| ﾊﾟｯｹｰｼﾞ | `nix develop` |
|---------|---------------|
| ruyi | `nix develop nix-kits#ruyi` |

## ﾊﾟｯﾁｰｽﾞ

Standalone overlays, ﾉｯﾄ included ｲﾝ `default`:

| ﾊﾟｯﾁ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| llama-cpp-rocm | ROCm-accelerated builds tracking latest upstream release | [docs/zh/llama-cpp-rocm.md](llama-cpp-rocm.md) |
| rcc-fix | ﾌｨｯｸｼｰｽﾞ 2-in-1 device experience ﾌｫｱ asusctl | [docs/zh/rcc-fix.md](rcc-fix.md) |
| ruyi-nixos-compat | NixOS ﾗﾝﾀｲﾑ compatibility ﾌｫｱ ruyi (ELF ｲﾝﾀｰﾌﾟﾘﾀ redirect + GCC subprocess ﾌｨｯｸｽ) | [docs/zh/ruyi-nixos-compat.md](ruyi-nixos-compat.md) |

## ｽｷﾙｽﾞ

ﾌｫｱ AI ｺｰﾃﾞｨﾝｸﾞ assistants:

> ｽｷﾙｽﾞ ｲﾝ ﾃﾞｨｽ ﾌﾟﾛｼﾞｪｸﾄ ｱｰ primarily aimed ｱｯﾄ Chinese-speaking ﾕｰｻﾞｰｽﾞ ｱﾝﾄﾞ Chinese open-source models. ｵｰﾙ ｽｷﾙ.md ﾌｧｲﾙｽﾞ ｱｰ written ｲﾝ Chinese.

| ｽｷﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| nixkits-check-updates | ﾁｪｯｸ ﾌｫｱ upstream ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｱﾝﾄﾞ auto-upgrade | [docs/zh/skills/nixkits-check-updates.md](skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits ｽｷﾙ installer (local/online) | [docs/zh/skills/nixkits-skills.md](skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern CLI ｶﾞｲﾄﾞ (ﾌｫｱ AI models) | [docs/zh/skills/nixos-modern-cli.md](skills/nixos-modern-cli.md) |
| recover-nixos-config | ﾘｶﾊﾞｰ deleted /etc/ﾆｯｸｽOS ｺﾝﾌｨｸﾞ ﾌﾛﾑ ﾆｯｸｽ store | [docs/zh/skills/recover-nixos-config.md](skills/recover-nixos-config.md) |
| translate-katalish | Katakana English translation (mechanical word-level substitution ｵﾌﾞ English ﾄﾞｷｭｽﾞ) | [docs/zh/skills/translate-katalish.md](skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-Chinese translation (kana stripping + word order conversion ﾌﾛﾑ Japanese) | [docs/zh/skills/translate-pseudocn.md](skills/translate-pseudocn.md) |
| write-maintenance-log | ﾗｲﾄ ﾒﾝﾃﾅﾝｽ.md entries per NixKits spec (ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ + ﾊﾞｸﾞ ﾌｨｯｸｼｰｽﾞ) | [docs/zh/skills/write-maintenance-log.md](skills/write-maintenance-log.md) |
| write-project-docs | ﾗｲﾄ multilingual ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ﾌｫｱ ｴﾆｰ ﾌﾟﾛｼﾞｪｸﾄ ｲﾝ NixKits style | [docs/zh/skills/write-project-docs.md](skills/write-project-docs.md) |

## Credits

- **狐莉 (キツのり)** — creator ｱﾝﾄﾞ maintainer
- **小爪 (キツのめ)** — design, ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — hardware inference infrastructure feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](../LICENSE)