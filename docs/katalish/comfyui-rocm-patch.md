# ｶﾑﾌｨUI-ﾛｯｸｴﾑ-patch

[中文](../zh/comfyui-rocm-patch.md) | [ｲﾝｸﾞﾘｯｼｭ](comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

> ｱﾄﾞﾄﾞｽﾞ ｱ `rocmGfxOverride` ｵﾌﾟｼｮﾝ ｱﾝﾄﾞ ﾛｯｸｴﾑ ｴﾝﾊﾞｲﾛﾒﾝﾄ ﾌﾞｱﾗｲｱﾌﾞﾙ ｲﾝｼﾞｴｸｼｮﾝ ﾄｩ `services.comfyui`, ｴﾝｱﾌﾞﾙｲﾝｸﾞ ｶﾑﾌｨUI ﾄｩ ﾗﾝ ｵﾝ AMD ﾛｯｸｴﾑ ｸﾞﾌﾟｳｽﾞ ｵﾝ NixOS.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|------|
| ﾀｲﾌﾟ | NixOS ﾓｼﾞｭｰﾙ |
| ﾓｼﾞｭｰﾙ ﾊﾟｽ | `nix-kits.nixosModules.comfyui-rocm-patch` |
| ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰ | ｶﾑﾌｨUI-ｽﾄﾘｯｸｽ-halo |

## ﾌｨｰﾁｬｰｽﾞ

- `services.comfyui.rocmGfxOverride` ｵﾌﾟｼｮﾝ — ｽｴﾄｽﾞ `HSA_OVERRIDE_GFX_VERSION`
- ｲﾝｼﾞｴｸﾄｽﾞ `--disable-xformers` ﾌﾗｸﾞ (ﾛｯｸｴﾑ ﾄﾞｵｽﾞ ﾉｯﾄ ｻﾎﾟｰﾄ ｸｽﾌｵﾗﾑｴﾗｽﾞ)
- ｱﾄﾞﾄﾞｽﾞ c ﾋﾞﾙﾄﾞ ﾂｰﾙﾁｪｰﾝ (ｼﾞｰｼｰｼｰ, ﾌﾞｲﾝｳﾄｲﾙｽﾞ, ﾒｲｸ) ﾌｫｱ ｶｽﾀﾑ ﾝｵﾄﾞｴ ｸｵﾑﾌﾟｲﾙｱｼｮﾝ

## ｲﾝｽﾄｱﾙﾙｱｼｮﾝ

```nix
{
  nixpkgs.overlays = [ nix-kits.overlays.default ];
}

services.comfyui = {
  enable = true;
  rocmGfxOverride = "11.5.1";
};
```

## ﾉｰﾂ

- `rocmGfxOverride` ﾄﾞｴﾌｱｳﾙﾄｽﾞ ﾄｩ `null` (ﾉｰ ﾎｽｱ_OVERRIDE_GFX_VERSION ｾｯﾄ)
- ｵｰﾄ-ｸｵﾝﾌｲｸﾞｳﾗﾄﾞ ﾊﾞｲ `comfyui-strix-halo` ﾓｼﾞｭｰﾙ ﾌﾞｲｱ `nixkits.comfyui-strix-halo.gfxOverride`