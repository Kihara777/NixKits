# comfyui-rocm-ﾊﾟｯﾁ

[中文](../zh/comfyui-rocm-ﾊﾟｯﾁ.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/comfyui-rocm-ﾊﾟｯﾁ.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-ﾊﾟｯﾁ.md) | [偽中国語](../pcn/comfyui-rocm-ﾊﾟｯﾁ.md)

ROCm capability ﾊﾟｯﾁ for ComfyUI.

## ｲﾝﾌｫ

- **Feature**: ﾊﾟｯﾁｰｽﾞ ComfyUI ROCm ｻﾎﾟｰﾄ, enables custom node ﾋﾞﾙﾄﾞ toolchain (via `gfxOverride` for custom GPU target)
- **Location**: `ﾓｼﾞｭｰﾙs/comfyui-rocm-ﾊﾟｯﾁ.nix`

## ﾕｰｾｰｼﾞ

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # custom GPU target version
}
```

When `rocmGfxOverride` is set, the ﾓｼﾞｭｰﾙ injects `HSA_OVERRIDE_GFX_VERSION` into the ComfyUI ｻｰﾋﾞｽ.
