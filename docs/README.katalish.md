# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | ｶﾀﾘｯｼｭ | [偽中国語](README.pcn.md)

NixKits — ｱ ｺﾚｸｼｮﾝ ｵﾌﾞ ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ ｱｽｽｲｽﾄｱﾝﾄ ｽｷﾙｽﾞ.

## ｸｲｯｸ ｽﾀｰﾄ

```nix
# Remote
inputs.nix-kits.url = "github:Kihara777/NixKits";

# Local
inputs.nix-kits.url = "/home/kix/NixKits";
```

## ｿﾌﾄｳｪｱ

ｸｵﾑﾌﾟｱﾄｲﾌﾞﾙｴ ｳｨｽﾞ ｵｰﾙ `lib.platforms.linux` — ﾌｫﾛｰｽﾞ nixpkgs ｱｳﾄｵﾑｱﾄｲｸｱﾙﾘｰ.

| ｿﾌﾄｳｪｱ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|---|------|------|
| codewhale | ﾄﾞｴｴﾌﾟｽｴｴｸ V4 ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [docs/zh/codewhale.md](codewhale.md) |
| kitsfmt | Nix ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice ｵｰﾄ-ﾌｨｯｸｽｽﾞ) | [docs/zh/kitsfmt.md](kitsfmt.md) |
| mcp-searxng | MCP ｻｰﾊﾞｰ ﾌｫｱ SearXNG | [docs/zh/mcp-searxng.md](mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ | [docs/zh/obs-bilibili-stream.md](obs-bilibili-stream.md) |
| opencode-telegram | Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ OpenCode | [docs/zh/opencode-telegram.md](opencode-telegram.md) |
| ruyi | RuyiSDK ﾊﾟｯｹｰｼﾞ ﾑｱﾝｱｼﾞｴﾗ (RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾂｰﾙｽﾞ) | [docs/zh/ruyi.md](ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm ｻﾎﾟｰﾄ | [docs/zh/comfyui-strix-halo.md](comfyui-strix-halo.md) |

## ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ

`nix develop` ﾗｴｱﾄﾞｲ-ﾄｩ-ﾕｰｽﾞ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ. ﾌｧｰｽﾄ, ｱﾄﾞ ｻﾞ ﾚｼﾞｽﾄﾘ:

```bash
nix registry add nix-kits github:Kihara777/NixKits
```

| ﾊﾟｯｹｰｼﾞ | `nix develop` |
|---------|---------------|
| ruyi | `nix develop nix-kits#ruyi` |

## ﾊﾟｯﾁｰｽﾞ

ｽﾄｱﾝﾄﾞｱﾙｵﾝｴ ｵﾌﾞｴﾗﾙｱｲｽﾞ, ﾉｯﾄ ｲﾝｸﾙｳﾄﾞﾄﾞ ｲﾝ `default`:

| ﾊﾟｯﾁ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| llama-cpp-rocm | ROCm-ｱｸｾﾗﾚｲﾃｨｯﾄﾞ ﾌﾞｳｲﾙﾄﾞｽﾞ ﾄﾗｯｷﾝｸﾞ ﾙｱﾄｴｽﾄ ｳﾌﾟｽﾄﾗｴｱﾑ ﾘﾘｰｽ | [docs/zh/llama-cpp-rocm.md](llama-cpp-rocm.md) |
| rcc-fix | ﾌｨｯｸｽｽﾞ 2-ｲﾝ-1 ﾃﾞｨﾌﾞｱｲｽ ｴｸｽﾌﾟｴﾗｲｴﾝｽ ﾌｫｱ asusctl | [docs/zh/rcc-fix.md](rcc-fix.md) |
| ruyi-nixos-compat | NixOS ﾗﾝﾀｲﾑ ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ruyi (ELF interpreter redirect + GCC subprocess ﾌｨｯｸｽ) | [docs/zh/ruyi-nixos-compat.md](ruyi-nixos-compat.md) |

## ｽｷﾙｽﾞ

ﾌｫｱ AI ｺｰﾃﾞｨﾝｸﾞ ｱｽｽｲｽﾄｱﾝﾄｽﾞ:

> ｽｷﾙｽﾞ ｲﾝ ﾃﾞｨｽ ﾌﾟﾛｼﾞｪｸﾄ ｱｰ ﾌﾟﾗｲﾑｱﾗｲﾘｰ ｱｲﾑﾄﾞ ｱｯﾄ ﾁｬｲﾆｰｽﾞ-ｽﾌﾟｴｱｸｲﾝｸﾞ ﾕｰｻﾞｰｽﾞ ｱﾝﾄﾞ ﾁｬｲﾆｰｽﾞ ｵｰﾌﾟﾝ-ｿｰｽ ﾑｵﾄﾞｴﾙｽﾞ. ｵｰﾙ SKILL.md ﾌｧｲﾙｽﾞ ｱｰ ｳﾗｲﾄﾄｴﾝ ｲﾝ ﾁｬｲﾆｰｽﾞ.

| ｽｷﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| nixkits-check-updates | ﾁｪｯｸ ﾌｫｱ ｳﾌﾟｽﾄﾗｴｱﾑ ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｱﾝﾄﾞ ｵｰﾄ-ｱｯﾌﾟｸﾞﾚｰﾄﾞ | [docs/zh/skills/nixkits-check-updates.md](skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits ｽｷﾙ ｲﾝｽﾄｱﾙﾙｱ (ﾛｰｶﾙ/ｵﾝﾙｲﾝ) | [docs/zh/skills/nixkits-skills.md](skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS ﾑｵﾄﾞｴﾗﾝ CLI ｶﾞｲﾄﾞ (ﾌｫｱ AI ﾑｵﾄﾞｴﾙｽﾞ) | [docs/zh/skills/nixos-modern-cli.md](skills/nixos-modern-cli.md) |
| recover-nixos-config | ﾘｶﾊﾞｰ ﾃﾞｨﾘｰﾃｯﾄﾞ /etc/nixos ｺﾝﾌｨｸﾞ ﾌﾛﾑ Nix ｽﾄｴﾗ | [docs/zh/skills/recover-nixos-config.md](skills/recover-nixos-config.md) |
| translate-katalish | Katakana ｲﾝｸﾞﾘｯｼｭ ﾄﾗｱﾝｽﾙｱｼｮﾝ (ﾑｴﾁｱﾝｲｸｱﾙ ﾜｰﾄﾞ-ﾚﾍﾞﾙ ｻﾌﾞｽﾃｨﾃｭｰｼｮﾝ ｵﾌﾞ ｲﾝｸﾞﾘｯｼｭ ﾄﾞｷｭｽﾞ) | [docs/zh/skills/translate-katalish.md](skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-Chinese ﾄﾗｱﾝｽﾙｱｼｮﾝ (kana ｽﾄﾘｯﾋﾟﾝｸﾞ + ﾜｰﾄﾞ ｵﾗﾄﾞｴﾗ ｺﾝﾊﾞｰｼﾞｮﾝ ﾌﾛﾑ ｼﾞｬﾊﾟﾆｰｽﾞ) | [docs/zh/skills/translate-pseudocn.md](skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md ｴﾝﾄﾘｰｽﾞ ﾊﾟｰ NixKits ｽﾌﾟｴｸ (ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ + ﾊﾞｸﾞ ﾌｨｯｸｽｽﾞ) | [docs/zh/skills/write-maintenance-log.md](skills/write-maintenance-log.md) |
| write-project-docs | Write ﾏﾙﾁﾘﾝｶﾞﾙ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ﾌｫｱ ｴﾆｰ ﾌﾟﾛｼﾞｪｸﾄ ｲﾝ NixKits ｽﾀｲﾙ | [docs/zh/skills/write-project-docs.md](skills/write-project-docs.md) |

## ｸﾚｼﾞｯﾄ

^- **狐莉 (キツのり)** — ｸﾗｴｱﾄｵﾗ ｱﾝﾄﾞ ﾑｱｲﾝﾄｱｲﾝｴﾗ
- **小爪 (キツのめ)** — ﾄﾞｴｽｲｸﾞﾝ, ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. ﾄﾞｴｴﾌﾟｽｴｴｸ V4 Pro (Max)
- **小小爪 (キツのめ)** — ﾊｰﾄﾞｳｪｱ ｲﾝﾌｧﾚﾝｽ ｲﾝﾌﾗｽﾄﾗｸﾁｬｰ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](../LICENSE)