# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI ROCm 機能修正提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 選項 | `nixkits.comfyui-rocm-patch.enable` |
| 書類 | `modules/comfyui-rocm-patch.nix` |

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # 任意：定制 GPU 目標
}
```

`rocmGfxOverride` 設定時、`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI 服務注入。又 xformers 自動無効化（nixpkgs 版 ROCm 後端非対応）、C 構築道具連注入。
