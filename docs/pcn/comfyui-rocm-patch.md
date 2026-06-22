# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI ROCm 機能提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| | `nixkits.comfyui-rocm-patch.enable` |
| 書類 | `modules/comfyui-rocm-patch.nix` |

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # 任意：カスタム GPU ターゲット
}
```

`rocmGfxOverride` 設定、`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI 服務注入。 xformers 自動無効化（nixpkgs 版 ROCm 非対応）、C 構築道具注入。
