# comfyui-strix-halo

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [comfyui-strix-halo] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [comfyui-strix-halo] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [comfyui-strix-halo] . md )

[ROCm-accelerated] ｶﾑﾌｨUI ｻﾎﾟｰﾄ ﾌｫｱ AMD [Strix] [Halo] ( [gfx1151] / RDNA 3 . 5 [APU] ).
** [Verified] ** ｵﾝ [Ryzen] AI [MAX] + 395 / [Radeon] [8060S] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|Tracks ｶﾑﾌｨUI - ﾆｯｸｽ
Upstream|[ utensils / ｶﾑﾌｨUI - ﾆｯｸｽ ] ( https : / / github . com / utensils / ｶﾑﾌｨUI - ﾆｯｸｽ )
ﾊﾟｯﾁ|ﾃﾞｨｽ repo ` ﾊﾟｯﾁｰｽﾞ / ｶﾑﾌｨUI - ﾆｯｸｽ - strix - halo . ﾊﾟｯﾁ `
Target GPU|gfx1151 ( Strix Halo ) — natively supported ｲﾝ ﾛｯｸｴﾑ 7 . 2

## Changes

- ** ﾛｯｸｴﾑ 7 . 2 [stable] [wheels] [**:] [adds] [torch] 2 . 12 . 0 / [torchvision] 0 . 27 . 0 / [torchaudio] 2 . 11 . 0
- ** ｵｰﾄ ﾊﾞｰｼﾞｮﾝ [selection] [**:] [prefers] 7 . 2 ｳｪﾝ [rocm72] [definitions] [exist] , [falls] [back] ﾄｩ 7 . 1
- ** [rocmGfxOverride] ｵﾌﾟｼｮﾝ [**:] [override] ﾌｫｱ [unrecognized] [GPU] [architectures] (` [HSA_OVERRIDE_GFX_VERSION] `)
- ** ｵｰﾄ [--disable-xformers] [**:] [nixpkgs] [xformers] [lacks] ｱ ﾛｯｸｴﾑ ﾊﾞｯｸｴﾝﾄﾞ
- ** C ﾋﾞﾙﾄﾞ ﾂｰﾙﾁｪｰﾝ [**:] [injects] ` [stdenv] . cc `, ` [binutils] `, ` [gnumake] `, [sets] ` CC = ｼﾞｰｼｰｼｰ ` ﾌｫｱ ｶﾑﾌｨUI [Manager] ｶｽﾀﾑ [node] [compilation]


## Install

NixKits ﾓｼﾞｭｰﾙ ( [recommended] ):

```nix
# flake.nix — requires a patched comfyui-nix
{
[nixkits] . [comfyui-strix-halo] . [enable] = [true] ;
[services] . ｶﾑﾌｨUI . [enable] = [true] ;
}
```

ｵｱ [apply] ｻﾞ ﾊﾟｯﾁ [manually] :

```bash
cd [comfyui-nix] && ﾊﾟｯﾁ [-p1] < ﾊﾟｯﾁｰｽﾞ / [comfyui-nix-strix-halo] . ﾊﾟｯﾁ
```

## Notes

- ﾛｯｸｴﾑ 7 . 2 [natively] [supports] [gfx1151] — ﾉｰ ` [HSA_OVERRIDE_GFX_VERSION] ` [needed]
- If [GPU] ｲｽﾞ ﾉｯﾄ [detected] , [try] ` [rocmGfxOverride] = " 11 . 0 . 0 "`
- [Missing] ﾛｯｸｴﾑ [runtime] : ` [hardware] . [graphics] . [extraPackages] = [ [rocmPackages] . [clr] [rocmPackages] . [rocminfo] ]`
- [xformers] ｴﾗｰｽﾞ : ｻﾞ ﾊﾟｯﾁ [auto-adds] ` [--disable-xformers] `
- ｻﾞ ﾓｼﾞｭｰﾙ [auto-sets] ` [amdgpu] . [gttsize] = 131072 ` ﾌｫｱ [Strix] [Halo] [UMA]