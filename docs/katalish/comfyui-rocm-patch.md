# ｶﾑﾌｨUI-ﾛｯｸｴﾑ-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/comfyui-rocm-patch.md)

ﾛｯｸｴﾑ ｸｱﾌﾟｱﾌﾞｲﾙｲﾄｲ ﾊﾟｯﾁ ﾌｫｱ ｶﾑﾌｨUI.

## ｲﾝﾌｫ

- **ﾌｨｰﾁｬｰ**: ﾊﾟｯﾁｰｽﾞ ｶﾑﾌｨUI ﾛｯｸｴﾑ ｻﾎﾟｰﾄ, ｴﾝｱﾌﾞﾙｽﾞ ｶｽﾀﾑ ﾝｵﾄﾞｴ ﾋﾞﾙﾄﾞ ﾂｰﾙﾁｪｰﾝ (ﾌﾞｲｱ `gfxOverride` ﾌｫｱ ｶｽﾀﾑ ｸﾞﾌﾟｳ ﾄｱﾗｼﾞｴﾄ)
- **ﾙｵｸｱｼｮﾝ**: `modules/comfyui-rocm-patch.nix`

## ﾕｰｾｰｼﾞ

```nix
{
  ｽｴﾗﾌﾞｲｸｽﾞ.ｶﾑﾌｨUI.ﾗｵｸﾑｸﾞﾌｸｽｵﾌﾞｴﾗﾗｲﾄﾞｴ = "ｸﾞﾌｸｽ1100";  # ｶｽﾀﾑ ｸﾞﾌﾟｳ ﾄｱﾗｼﾞｴﾄ ﾊﾞｰｼﾞｮﾝ
}
```

ｳｪﾝ `rocmGfxOverride` ｲｽﾞ ｾｯﾄ, ｻﾞ ﾓｼﾞｭｰﾙ ｲﾝｼﾞｴｸﾄｽﾞ `HSA_OVERRIDE_GFX_VERSION` ｲﾝﾄｩ ｻﾞ ｶﾑﾌｨUI ｻｰﾋﾞｽ.