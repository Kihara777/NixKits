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
| codewhale | ﾄﾞｴｴﾌﾟｽｴｴｸ V4 ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ | [docs/katalish/codewhale.md](katalish/codewhale.md) |
| kitsfmt | Nix ﾌｫｰﾏｯﾀｰ (AST sorting + best-practice ｵｰﾄ-ﾌｨｯｸｽｽﾞ) | [docs/katalish/kitsfmt.md](katalish/kitsfmt.md) |
| mcp-searxng | MCP ｻｰﾊﾞｰ ﾌｫｱ SearXNG | [docs/katalish/mcp-searxng.md](katalish/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ | [docs/katalish/obs-bilibili-stream.md](katalish/obs-bilibili-stream.md) |
| opencode-telegram | Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ OpenCode | [docs/katalish/opencode-telegram.md](katalish/opencode-telegram.md) |
| ruyi | RuyiSDK ﾊﾟｯｹｰｼﾞ ﾑｱﾝｱｼﾞｴﾗ (RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾂｰﾙｽﾞ) | [docs/katalish/ruyi.md](katalish/ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm ｻﾎﾟｰﾄ | [docs/katalish/comfyui-strix-halo.md](katalish/comfyui-strix-halo.md) |

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
| llama-cpp-rocm | ROCm-ｱｸｾﾗﾚｲﾃｨｯﾄﾞ ﾌﾞｳｲﾙﾄﾞｽﾞ ﾄﾗｯｷﾝｸﾞ ﾙｱﾄｴｽﾄ ｳﾌﾟｽﾄﾗｴｱﾑ ﾘﾘｰｽ | [docs/katalish/llama-cpp-rocm.md](katalish/llama-cpp-rocm.md) |
| rcc-fix | ﾌｨｯｸｽｽﾞ 2-ｲﾝ-1 ﾃﾞｨﾌﾞｱｲｽ ｴｸｽﾌﾟｴﾗｲｴﾝｽ ﾌｫｱ asusctl | [docs/katalish/rcc-fix.md](katalish/rcc-fix.md) |
| ruyi-nixos-compat | NixOS ﾗﾝﾀｲﾑ ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ruyi (ELF interpreter redirect + GCC subprocess ﾌｨｯｸｽ) | [docs/katalish/ruyi-nixos-compat.md](katalish/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | ComfyUI ROCm ﾌｧﾝｸｼｮﾅﾙ ﾊﾟｯﾁ | [docs/katalish/comfyui-rocm-patch.md](katalish/comfyui-rocm-patch.md) |
| rog-control-center-fix | ﾌｨｯｸｽｽﾞ asusd ﾃﾞｯﾄﾞﾛｯｸ on ｼｬｯﾄﾀﾞｳﾝ | [docs/katalish/rog-control-center-fix.md](katalish/rog-control-center-fix.md) |

## ｽｷﾙｽﾞ

ﾌｫｱ AI ｺｰﾃﾞｨﾝｸﾞ ｱｽｽｲｽﾄｱﾝﾄｽﾞ:

> ｽｷﾙｽﾞ ｲﾝ ﾃﾞｨｽ ﾌﾟﾛｼﾞｪｸﾄ ｱｰ ﾌﾟﾗｲﾑｱﾗｲﾘｰ ｱｲﾑﾄﾞ ｱｯﾄ ﾁｬｲﾆｰｽﾞ-ｽﾌﾟｴｱｸｲﾝｸﾞ ﾕｰｻﾞｰｽﾞ ｱﾝﾄﾞ ﾁｬｲﾆｰｽﾞ ｵｰﾌﾟﾝ-ｿｰｽ ﾑｵﾄﾞｴﾙｽﾞ. ｵｰﾙ SKILL.md ﾌｧｲﾙｽﾞ ｱｰ ｳﾗｲﾄﾄｴﾝ ｲﾝ ﾁｬｲﾆｰｽﾞ.

| ｽｷﾙ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| nixkits-check-updates | ﾁｪｯｸ ﾌｫｱ ｳﾌﾟｽﾄﾗｴｱﾑ ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｱﾝﾄﾞ ｵｰﾄ-ｱｯﾌﾟｸﾞﾚｰﾄﾞ | [docs/katalish/skills/nixkits-check-updates.md](katalish/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits ｽｷﾙ ｲﾝｽﾄｱﾙﾙｱ (ﾛｰｶﾙ/ｵﾝﾙｲﾝ) | [docs/katalish/skills/nixkits-skills.md](katalish/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS ﾑｵﾄﾞｴﾗﾝ CLI ｶﾞｲﾄﾞ (ﾌｫｱ AI ﾑｵﾄﾞｴﾙｽﾞ) | [docs/katalish/skills/nixos-modern-cli.md](katalish/skills/nixos-modern-cli.md) |
| recover-nixos-config | ﾘｶﾊﾞｰ ﾃﾞｨﾘｰﾃｯﾄﾞ /etc/nixos ｺﾝﾌｨｸﾞ ﾌﾛﾑ Nix ｽﾄｴﾗ | [docs/katalish/skills/recover-nixos-config.md](katalish/skills/recover-nixos-config.md) |
| translate-katalish | Katakana ｲﾝｸﾞﾘｯｼｭ ﾄﾗｱﾝｽﾙｱｼｮﾝ (ﾑｴﾁｱﾝｲｸｱﾙ ﾜｰﾄﾞ-ﾚﾍﾞﾙ ｻﾌﾞｽﾃｨﾃｭｰｼｮﾝ ｵﾌﾞ ｲﾝｸﾞﾘｯｼｭ ﾄﾞｷｭｽﾞ) | [docs/katalish/skills/translate-katalish.md](katalish/skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-Chinese ﾄﾗｱﾝｽﾙｱｼｮﾝ (kana ｽﾄﾘｯﾋﾟﾝｸﾞ + ﾜｰﾄﾞ ｵﾗﾄﾞｴﾗ ｺﾝﾊﾞｰｼﾞｮﾝ ﾌﾛﾑ ｼﾞｬﾊﾟﾆｰｽﾞ) | [docs/katalish/skills/translate-pseudocn.md](katalish/skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md ｴﾝﾄﾘｰｽﾞ ﾊﾟｰ NixKits ｽﾌﾟｴｸ (ｿﾌﾄｳｪｱ ｱｯﾌﾟﾃﾞｰﾄｽﾞ + ﾊﾞｸﾞ ﾌｨｯｸｽｽﾞ) | [docs/katalish/skills/write-maintenance-log.md](katalish/skills/write-maintenance-log.md) |
| write-project-docs | Write ﾏﾙﾁﾘﾝｶﾞﾙ ﾄﾞｷｭﾒﾝﾃｰｼｮﾝ ﾌｫｱ ｴﾆｰ ﾌﾟﾛｼﾞｪｸﾄ ｲﾝ NixKits ｽﾀｲﾙ | [docs/katalish/skills/write-project-docs.md](katalish/skills/write-project-docs.md) |

## ｸﾚｼﾞｯﾄ

^- **狐莉 (キツのり)** — ｸﾗｴｱﾄｵﾗ ｱﾝﾄﾞ ﾑｱｲﾝﾄｱｲﾝｴﾗ
- **小爪 (キツのめ)** — ﾄﾞｴｽｲｸﾞﾝ, ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. ﾄﾞｴｴﾌﾟｽｴｴｸ V4 Pro (Max)
- **小小爪 (キツのめ)** — ﾊｰﾄﾞｳｪｱ ｲﾝﾌｧﾚﾝｽ ｲﾝﾌﾗｽﾄﾗｸﾁｬｰ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](../LICENSE)