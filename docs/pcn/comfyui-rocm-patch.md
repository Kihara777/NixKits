# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI 用 ROCm 機能補丁。

## 基本情報

| 項目 | 値 |
|------|-----|
| 選項 | `nixkits.comfyui-rocm-patch.enable` |
| 位置 | `modules/comfyui-rocm-patch.nix` |

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # 任意：自定 GPU 目標
}
```

設定 `rocmGfxOverride` 則 `HSA_OVERRIDE_GFX_VERSION` 環境変数注入 ComfyUI 服務。又 xformers 自動無効化（nixpkgs 版欠 ROCm 後端）並注入 C 構築工具鎖。
