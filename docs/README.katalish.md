# NixKits

[中文](../ﾘｰﾄﾞﾐｰ.md) | [English](ﾘｰﾄﾞﾐｰ.en.md) | [日本語](ﾘｰﾄﾞﾐｰ.ja.md) | ｶﾀﾘｯｼｭ | [偽中国語](ﾘｰﾄﾞﾐｰ.pcn.md)

NixKits — a ｺﾚｸｼｮﾝ of ｿﾌﾄｳｪｱ, ﾊﾟｯﾁｰｽﾞ, NixOS ﾓｼﾞｭｰﾙｽﾞ, ｱﾝﾄﾞ AI ｺｰﾃﾞｨﾝｸﾞ ｱｽｽｲｽﾄｱﾝﾄ ｽｷﾙｽﾞ.

## ｸｲｯｸ ｽﾀｰﾄ

```nix
# ﾘﾓｰﾄ
inputs.nix-kits.url = "github:Kihara777/NixKits";

# ﾛｰｶﾙ
inputs.nix-kits.url = "/ﾎｰﾑ/kix/NixKits";
```

## ｿﾌﾄｳｪｱ

ｸｵﾑﾌﾟｱﾄｲﾌﾞﾙｴ ｳｨｽﾞ ｵｰﾙ `lib.platforms.linux` — ﾌｫﾛｰｽﾞ ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ｱｳﾄｵﾑｱﾄｲｸｱﾙﾘｰ.

| ｿﾌﾄｳｪｱ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|---|------|------|
| codewhale | ﾄﾞｴｴﾌﾟｽｴｴｸ V4 terminal coding agent | [docs/zh/codewhale.md](codewhale.md) |
| kitsfmt | Nix formatter (AST sorting + best-practice ｵｰﾄ-fixes) | [docs/zh/kitsfmt.md](kitsfmt.md) |
| mcp-searxng | MCP server ﾌｫｱ SearXNG | [docs/zh/mcp-searxng.md](mcp-searxng.md) |
| obs-bilibili-ｽﾄﾘｰﾑ | OBS Bilibili streaming plugin | [docs/zh/obs-bilibili-ｽﾄﾘｰﾑ.md](obs-bilibili-ｽﾄﾘｰﾑ.md) |
| opencode-telegram | Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ OpenCode | [docs/zh/opencode-telegram.md](opencode-telegram.md) |
| ruyi | RuyiSDK package manager (RISC-V development ﾂｰﾙｽﾞ) | [docs/zh/ruyi.md](ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm support | [docs/zh/comfyui-strix-halo.md](comfyui-strix-halo.md) |

## ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ

`nix develop` ﾗｴｱﾄﾞｲ-ﾄｩ-ﾕｰｽﾞ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ. ﾌｧｰｽﾄ, ｱﾄﾞ ｻﾞ ﾚｼﾞｽﾄﾘ:

```bash
nix registry ｱﾄﾞ nix-kits github:Kihara777/NixKits
```

| Package | `nix develop` |
|---------|---------------|
| ruyi | `nix develop nix-kits#ruyi` |

## ﾊﾟｯﾁes

ｽﾄｱﾝﾄﾞｱﾙｵﾝｴ ｵﾌﾞｴﾗﾙｱｲｽﾞ, ﾉｯﾄ ｲﾝｸﾙｳﾄﾞﾄﾞ ｲﾝ `default`:

| ﾊﾟｯﾁ | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| llama-cpp-rocm | ROCm-accelerated builds tracking latest upstream release | [docs/zh/llama-cpp-rocm.md](llama-cpp-rocm.md) |
| rcc-ﾌｨｯｸｽ | Fixes 2-ｲﾝ-1 ﾃﾞｨﾌﾞｱｲｽ experience ﾌｫｱ asusctl | [docs/zh/rcc-ﾌｨｯｸｽ.md](rcc-ﾌｨｯｸｽ.md) |
| ruyi-nixos-compat | NixOS runtime compatibility ﾌｫｱ ruyi (ELF interpreter redirect + GCC subprocess ﾌｨｯｸｽ) | [docs/zh/ruyi-nixos-compat.md](ruyi-nixos-compat.md) |

## Skills

For AI ｺｰﾃﾞｨﾝｸﾞ ｱｽｽｲｽﾄｱﾝﾄs:

> ｽｷﾙｽﾞ ｲﾝ ﾃﾞｨｽ ﾌﾟﾛｼﾞｪｸﾄ ｱｰ ﾌﾟﾗｲﾑｱﾗｲﾘｰ ｱｲﾑﾄﾞ ｱｯﾄ ﾁｬｲﾆｰｽﾞ-ｽﾌﾟｴｱｸｲﾝｸﾞ ﾕｰｻﾞｰｽﾞ ｱﾝﾄﾞ ﾁｬｲﾆｰｽﾞ ｵｰﾌﾟﾝ-ｿｰｽ ﾑｵﾄﾞｴﾙｽﾞ. ｵｰﾙ ｽｷﾙ.ﾑﾄﾞ ﾌｧｲﾙｽﾞ ｱｰ ｳﾗｲﾄﾄｴﾝ ｲﾝ ﾁｬｲﾆｰｽﾞ.

| Skill | ﾃﾞｨｽｸﾘﾌﾟｼｮﾝ | ﾄﾞｷｭｽﾞ |
|------|------|------|
| nixkits-check-updates | Check ﾌｫｱ upstream updates ｱﾝﾄﾞ ｵｰﾄ-upgrade | [docs/zh/ｽｷﾙｽﾞ/nixkits-check-updates.md](skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits skill installer (local/online) | [docs/zh/ｽｷﾙｽﾞ/nixkits-skills.md](skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS modern ｼｰｴﾙｱｲ guide (ﾌｫｱ AI models) | [docs/zh/ｽｷﾙｽﾞ/nixos-modern-cli.md](skills/nixos-modern-cli.md) |
| recover-nixos-ｺﾝﾌｨｸﾞ | Recover deleted /etc/nixos ｺﾝﾌｨｸﾞ ﾌﾛﾑ Nix store | [docs/zh/ｽｷﾙｽﾞ/recover-nixos-ｺﾝﾌｨｸﾞ.md](skills/recover-nixos-ｺﾝﾌｨｸﾞ.md) |
| translate-katalish | Katakana English translation (mechanical word-level substitution of English docs) | [docs/zh/ｽｷﾙｽﾞ/translate-katalish.md](skills/translate-katalish.md) |
| translate-pseudocn | Pseudo-Chinese translation (kana stripping + word order conversion ﾌﾛﾑ Japanese) | [docs/zh/ｽｷﾙｽﾞ/translate-pseudocn.md](skills/translate-pseudocn.md) |
| write-maintenance-log | Write MAINTENANCE.md entries ﾊﾟｰ NixKits spec (ｿﾌﾄｳｪｱ updates + ﾊﾞｸﾞ fixes) | [docs/zh/ｽｷﾙｽﾞ/write-maintenance-log.md](skills/write-maintenance-log.md) |
| write-project-docs | Write multilingual documentation ﾌｫｱ any project ｲﾝ NixKits style | [docs/zh/ｽｷﾙｽﾞ/write-project-docs.md](skills/write-project-docs.md) |

## ｸﾚｼﾞｯﾄ

- **狐莉 (キツのり)** — ｸﾗｴｱﾄｵﾗ ｱﾝﾄﾞ ﾑｱｲﾝﾄｱｲﾝｴﾗ
- **小爪 (キツのめ)** — ﾄﾞｴｽｲｸﾞﾝ, ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ feat. ﾄﾞｴｴﾌﾟｽｴｴｸ V4 Pro (Max)
- **小小爪 (キツのめ)** — ﾊｰﾄﾞｳｪｱ ｲﾝﾌｧﾚﾝｽ ｲﾝﾌﾗｽﾄﾗｸﾁｬｰ feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## ﾗｲｾﾝｽ

[MIT](../LICENSE)
