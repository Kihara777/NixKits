# ｶﾑﾌｨUI-ﾛｯｸｴﾑ-patch

[中文](../../zh/comfyui-rocm-patch.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

ﾛｯｸｴﾑ capability ﾊﾟｯﾁ ﾌｫｱ ｶﾑﾌｨUI.

## ｲﾝﾌｫ

- **ﾌｨｰﾁｬｰ**: ﾊﾟｯﾁｰｽﾞ ｶﾑﾌｨUI ﾛｯｸｴﾑ ｻﾎﾟｰﾄ, enables ｶｽﾀﾑ node ﾋﾞﾙﾄﾞ toolchain (via `gfxOverride` ﾌｫｱ ｶｽﾀﾑ GPU target)
- **Location**: `modules/comfyui-rocm-patch.nix`

## ﾕｰｾｰｼﾞ

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # custom GPU target version
}
```

When `rocmGfxOverride` ｲｽﾞ set, ｻﾞ ﾓｼﾞｭｰﾙ injects `HSA_OVERRIDE_GFX_VERSION` into ｻﾞ ｶﾑﾌｨUI ｻｰﾋﾞｽ.