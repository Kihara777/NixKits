# ｶﾑﾌｨUI-strix-halo

[中文](../../zh/comfyui-strix-halo.md) | [English](comfyui-strix-halo.md) | [日本語](../../ja/comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../../katalish/comfyui-strix-halo.md) | [偽中国語](../../pcn/comfyui-strix-halo.md)

ﾛｯｸｴﾑ-accelerated ｶﾑﾌｨUI ｻﾎﾟｰﾄ ﾌｫｱ AMD Strix Halo (gfx1151 / RDNA 3.5 APU).
**Verified** ｵﾝ Ryzen AI MAX+ 395 / Radeon 8060S.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | Tracks ｶﾑﾌｨUI-ﾆｯｸｽ |
| Upstream | [utensils/ｶﾑﾌｨUI-ﾆｯｸｽ](https://github.com/utensils/comfyui-nix) |
| ﾊﾟｯﾁ | ﾃﾞｨｽ repo `patches/comfyui-nix-strix-halo.patch` |
| Target GPU | gfx1151 (Strix Halo) — natively ｻﾎﾟｰﾄﾄﾞ ｲﾝ ﾛｯｸｴﾑ 7.2 |

## Changes

- **ﾛｯｸｴﾑ 7.2 stable wheels**: ｱﾄﾞｽﾞ torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0
- **ｵｰﾄ ﾊﾞｰｼﾞｮﾝ selection**: prefers 7.2 when ﾛｯｸｴﾑ72 definitions exist, falls back ﾄｩ 7.1
- **rocmGfxOverride option**: override ﾌｫｱ unrecognized GPU architectures (`HSA_OVERRIDE_GFX_VERSION`)
- **ｵｰﾄ --disable-xformers**: nixpkgs xformers lacks ｱ ﾛｯｸｴﾑ ﾊﾞｯｸｴﾝﾄﾞ
- **c ﾋﾞﾙﾄﾞ toolchain**: injects `stdenv.cc`, `binutils`, `gnumake`, sets `CC=gcc` ﾌｫｱ ｶﾑﾌｨUI Manager ｶｽﾀﾑ node compilation


## ｲﾝｽﾄｰﾙ

NixKits ﾓｼﾞｭｰﾙ (recommended):

```nix
# flake.ﾆｯｸｽ — requires ｱ ﾊﾟｯﾁﾄﾞ ｶﾑﾌｨUI-ﾆｯｸｽ
{
  nixkits.comfyui-strix-halo.enable = true;
  services.comfyui.enable = true;
}
```

ｵｱ apply ｻﾞ ﾊﾟｯﾁ manually:

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## Notes

- ﾛｯｸｴﾑ 7.2 natively ｻﾎﾟｰﾄｽﾞ gfx1151 — ﾉｰ `HSA_OVERRIDE_GFX_VERSION` needed
- If GPU ｲｽﾞ ﾉｯﾄ detected, try `rocmGfxOverride = "11.0.0"`
- Missing ﾛｯｸｴﾑ runtime: `hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers errors: ｻﾞ ﾊﾟｯﾁ ｵｰﾄ-ｱﾄﾞｽﾞ `--disable-xformers`
- ｻﾞ ﾓｼﾞｭｰﾙ ｵｰﾄ-sets `amdgpu.gttsize=131072` ﾌｫｱ Strix Halo UMA