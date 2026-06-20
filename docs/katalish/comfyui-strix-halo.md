# comfyui-strix-halo

[中文](../../zh/comfyui-strix-halo.md) | [English](comfyui-strix-halo.md) | [日本語](../../ja/comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../../katalish/comfyui-strix-halo.md)

ROCm-accelerated ｶﾑﾌｨUI ｻﾎﾟｰﾄ ﾌｫｱ AMD Strix Halo (gfx1151 / RDNA 3.5 APU).
**Verified** ｵﾝ Ryzen AI MAX+ 395 / Radeon 8060S.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | Tracks comfyui-nix |
| Upstream | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| ﾊﾟｯﾁ | ﾃﾞｨｽ repo `patches/comfyui-nix-strix-halo.patch` |
| Target GPU | gfx1151 (Strix Halo) — natively supported ｲﾝ ﾛｯｸｴﾑ 7.2 |

## ﾁｪﾝｼﾞｰｽﾞ

- **ﾛｯｸｴﾑ 7.2 stable wheels**: adds torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0
- **ｵｰﾄ ﾊﾞｰｼﾞｮﾝ selection**: prefers 7.2 ｳｪﾝ rocm72 definitions exist, falls back ﾄｩ 7.1
- **rocmGfxOverride ｵﾌﾟｼｮﾝ**: override ﾌｫｱ unrecognized GPU architectures (`HSA_OVERRIDE_GFX_VERSION`)
- **ｵｰﾄ --disable-xformers**: nixpkgs xformers lacks ｱ ﾛｯｸｴﾑ ﾊﾞｯｸｴﾝﾄﾞ
- **C ﾋﾞﾙﾄﾞ toolchain**: injects `stdenv.cc`, `binutils`, `gnumake`, sets `CC=gcc` ﾌｫｱ ｶﾑﾌｨUI Manager ｶｽﾀﾑ node compilation


## ｲﾝｽﾄｰﾙ

NixKits ﾓｼﾞｭｰﾙ (recommended):

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ — ﾘｸﾜｲｱｽﾞ ｱ patched comfyui-nix
{
  nixkits.comfyui-strix-halo.ｲﾈｰﾌﾞﾙ = true;
  services.ｶﾑﾌｨUI.ｲﾈｰﾌﾞﾙ = true;
}
```

ｵｱ ｱﾌﾟﾗｲ ｻﾞ ﾊﾟｯﾁ manually:

```bash
cd comfyui-nix && ﾊﾟｯﾁ -p1 < ﾊﾟｯﾁｰｽﾞ/comfyui-nix-strix-halo.ﾊﾟｯﾁ
```

## ﾉｰﾂ

- ﾛｯｸｴﾑ 7.2 natively supports gfx1151 — ﾉｰ `HSA_OVERRIDE_GFX_VERSION` needed
- If GPU ｲｽﾞ ﾉｯﾄ detected, try `rocmGfxOverride = "11.0.0"`
- Missing ﾛｯｸｴﾑ ﾗﾝﾀｲﾑ: `hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers ｴﾗｰｽﾞ: ｻﾞ ﾊﾟｯﾁ auto-adds `--disable-xformers`
- ｻﾞ ﾓｼﾞｭｰﾙ auto-sets `amdgpu.gttsize=131072` ﾌｫｱ Strix Halo UMA