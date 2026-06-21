# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/comfyui-rocm-patch.md)

ComfyUI ﾆ ROCm 機能ﾊﾟｯﾁ ｦ 提供ｼﾏｽ。

## 基本ｼﾞｮｳﾎｳ

| ｺｳﾓｸ | ｱﾀｲ |
|------|-----|
| ｵﾌﾟｼｮﾝ | `nixkits.comfyui-rocm-patch.enable` |
| ﾌｧｲﾙ | `modules/comfyui-rocm-patch.nix` |

## ｼﾖｳﾎｳﾎｳ

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # ｵﾌﾟｼｮﾅﾙ：ｶｽﾀﾑ GPU ﾀｰｹﾞｯﾄ
}
```

`rocmGfxOverride` ｦ 設定ｽﾙﾄ、`HSA_OVERRIDE_GFX_VERSION` 環境変数 ｶﾞ ComfyUI ｻｰﾋﾞｽ ﾆ 注入ｻﾚﾏｽ。ﾏﾀ xformers ｦ 自動無効化（nixpkgs 版 ﾊ ROCm ﾊﾞｯｸｴﾝﾄﾞ 非対応）ｼ、C ﾋﾞﾙﾄﾞ ﾂｰﾙﾁｪｰﾝ ｦ 注入ｼﾏｽ。
