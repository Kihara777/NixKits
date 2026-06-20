# comfyui-rocm-ﾊﾟｯﾁ

[中文](../zh/comfyui-rocm-ﾊﾟｯﾁ.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/comfyui-rocm-ﾊﾟｯﾁ.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-ﾊﾟｯﾁ.md) | [偽中国語](../pcn/comfyui-rocm-ﾊﾟｯﾁ.md)

ROCm capability ﾊﾟｯﾁ ﾌｫｱ ComfyUI.

## ｲﾝﾌｫ

- **Feature**: ﾊﾟｯﾁｰｽﾞ ComfyUI ROCm ｻﾎﾟｰﾄ, enables ｶｽﾀﾑ node ﾋﾞﾙﾄﾞ ﾂｰﾙﾁｪｰﾝ (ﾌﾞｲｱ `gfxOverride` ﾌｫｱ ｶｽﾀﾑ GPU target)
- **Location**: `ﾓｼﾞｭｰﾙs/comfyui-rocm-ﾊﾟｯﾁ.nix`

## ﾕｰｾｰｼﾞ

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # ｶｽﾀﾑ GPU target version
}
```

When `rocmGfxOverride` ｲｽﾞ set, ｻﾞ ﾓｼﾞｭｰﾙ injects `HSA_OVERRIDE_GFX_VERSION` into ｻﾞ ComfyUI ｻｰﾋﾞｽ.
