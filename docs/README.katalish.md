# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | [ｶﾀﾘｯｼｭ](README.katalish.md) | [偽中国語](README.pcn.md)

NixKits — ｱ collection ｵﾌﾞ ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ assistant ｽｷﾙｽﾞ.

## Quick ｽﾀｰﾄ

```nix
# Remote
inputs.nix-kits.url = "github:Kihara777/NixKits";

# Local
inputs.nix-kits.url = "/home/kix/NixKits";
```

## ｿﾌﾄｳｪｱ

Compatible ｳｨｽﾞ ｵｰﾙ `lib.platforms.linux` — follows nixpkgs automatically.

| ｿﾌﾄｳｪｱ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|---|------|------|
| codewhale | DeepSeek V4 terminal ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/codewhale.md](codewhale.md) |
| kitsfmt | ﾆｯｸｽ ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice ｵｰﾄ-fixes) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/kitsfmt.md](kitsfmt.md) |
| ｴﾑｼｰﾋﾟｰ-searxng | ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ﾌｫｱ SearXNG | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｴﾑｼｰﾋﾟｰ-searxng.md](mcp-searxng.md) |
| ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream | OBS Bilibili ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream.md](obs-bilibili-stream.md) |
| opencode-ﾃﾚｸﾞﾗﾑ | ﾃﾚｸﾞﾗﾑ ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ ﾌｫｱ OpenCode | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/opencode-ﾃﾚｸﾞﾗﾑ.md](opencode-telegram.md) |
| ruyi | RuyiSDK ﾊﾟｯｹｰｼﾞ manager (ﾘｽｸ-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾂｰﾙｽﾞ) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ruyi.md](ruyi.md) |
| ｶﾑﾌｨUI-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ｶﾑﾌｨUI ﾛｯｸｴﾑ ｻﾎﾟｰﾄ | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｶﾑﾌｨUI-strix-halo.md](comfyui-strix-halo.md) |

## ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ

`nix develop` ready-ﾄｩ-use environments. First, ｱﾄﾞ ｻﾞ registry:

```bash
nix registry add nix-kits github:Kihara777/NixKits
```

| ﾊﾟｯｹｰｼﾞ | `nix develop` |
|---------|---------------|
| ruyi | `nix develop nix-kits#ruyi` |

## ﾊﾟｯﾁｰｽﾞ

Standalone ｵｰﾊﾞｰﾚｲｽﾞ, ﾉｯﾄ included ｲﾝ `default`:

| ﾊﾟｯﾁ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| llama-cpp-rocm | ﾛｯｸｴﾑ-accelerated ﾋﾞﾙﾄﾞｽﾞ tracking latest upstream release | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/llama-cpp-rocm.md](llama-cpp-rocm.md) |
| rcc-fix | Fixes 2-in-1 device experience ﾌｫｱ asusctl | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/rcc-fix.md](rcc-fix.md) |
| ruyi-ﾆｯｸｽOS-compat | NixOS runtime compatibility ﾌｫｱ ruyi (ELF ｲﾝﾀｰﾌﾟﾘﾀ redirect + GCC ｻﾌﾞﾌﾟﾛｾｽ fix) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ruyi-ﾆｯｸｽOS-compat.md](ruyi-nixos-compat.md) |
| mihomo-alpha | Prerelease-Alpha tracking (proxy ﾂｰﾙ) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/mihomo-alpha.md](mihomo-alpha.md) |

## ｽｷﾙｽﾞ

ﾌｫｱ AI ｺｰﾃﾞｨﾝｸﾞ assistants:

> Skills in this project are primarily aimed at Chinese-speaking users and Chinese open-source models. All SKILL.md files are written in Chinese.

| ｽｷﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| nixkits-check-updates | Check ﾌｫｱ upstream ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｱﾝﾄﾞ ｵｰﾄ-upgrade | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/nixkits-check-updates.md](skills/nixkits-check-updates.md) |
| nixkits-ｽｷﾙｽﾞ | NixKits ｽｷﾙ installer (local/online) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/nixkits-ｽｷﾙｽﾞ.md](skills/nixkits-skills.md) |
| ﾆｯｸｽOS-modern-cli | NixOS modern CLI ｶﾞｲﾄﾞ (ﾌｫｱ AI ﾓﾃﾞﾙｽﾞ) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/ﾆｯｸｽOS-modern-cli.md](skills/nixos-modern-cli.md) |
| recover-ﾆｯｸｽOS-config | Recover deleted /etc/ﾆｯｸｽOS ｺﾝﾌｨｸﾞ ﾌﾛﾑ ﾆｯｸｽ store | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/recover-ﾆｯｸｽOS-config.md](skills/recover-nixos-config.md) |
| translate-ｶﾀﾘｯｼｭ | Katakana ｲﾝｸﾞﾘｯｼｭ ﾄﾗﾝｽﾚｰｼｮﾝ (mechanical word-ﾚﾍﾞﾙ substitution ｵﾌﾞ ｲﾝｸﾞﾘｯｼｭ ﾄﾞｷｭｽﾞ) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/translate-ｶﾀﾘｯｼｭ.md](skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-ﾁｬｲﾆｰｽﾞ ﾄﾗﾝｽﾚｰｼｮﾝ (kana stripping + word order conversion ﾌﾛﾑ ｼﾞｬﾊﾟﾆｰｽﾞ) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/translate-pseudocn.md](skills/translate-pseudocn.md) |
| ﾗｲﾄ-maintenance-log | ﾗｲﾄ MAINTENANCE.md entries per NixKits spec (ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ + bug fixes) | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/ﾗｲﾄ-maintenance-log.md](skills/write-maintenance-log.md) |
| ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs | ﾗｲﾄ multilingual ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ﾌｫｱ ｴﾆｰ ﾌﾟﾛｼﾞｪｸﾄ ｲﾝ NixKits style | [ﾄﾞｷｭｽﾞ/ｾﾞｯﾄｴｲﾁ/ｽｷﾙｽﾞ/ﾗｲﾄ-ﾌﾟﾛｼﾞｪｸﾄ-docs.md](skills/write-project-docs.md) |

## Credits

- **狐莉 (キツのり)** — creator ｱﾝﾄﾞ maintainer
- **小爪 (キツのめ)** — design, ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツのめ)** — hardware inference infrastructure feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](../LICENSE)