# comfyui-rocm-ﾊﾟｯﾁ

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/comfyui-rocm-patch.md)

ROCm capability ﾊﾟｯﾁ ﾌｫｱ ComfyUI.

## ｲﾝﾌｫ

- **Feature**: ﾊﾟｯﾁｰｽﾞ ComfyUI ROCm ｻﾎﾟｰﾄ, enables custom node ﾋﾞﾙﾄﾞ toolchain (via `gfxOverride` ﾌｫｱ custom GPU target)
- **Location**: `modules/comfyui-rocm-ﾊﾟｯﾁ.nix`

## ﾕｰｾｰｼﾞ

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # custom GPU target version
}
```

When `rocmGfxOverride` ｲｽﾞ set, ｻﾞ ﾓｼﾞｭｰﾙ injects `HSA_OVERRIDE_GFX_VERSION` ｲﾝﾄｩ ｻﾞ ComfyUI ｻｰﾋﾞｽ.
