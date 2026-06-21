# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

ComfyUI に ROCm 機能パッチを提供します。

## 基本情報

| 項目 | 値 |
|------|-----|
| オプション | `nixkits.comfyui-rocm-patch.enable` |
| ファイル | `modules/comfyui-rocm-patch.nix` |

## 使用方法

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm-patch ];

  nixkits.comfyui-rocm-patch.enable = true;
  services.comfyui.rocmGfxOverride = "11.0.0";  # 任意：カスタム GPU ターゲット
}
```

`rocmGfxOverride` を設定すると、`HSA_OVERRIDE_GFX_VERSION` 環境変数が ComfyUI サービスに注入されます。また xformers を自動無効化（nixpkgs 版は ROCm バックエンド非対応）し、C ビルドツールチェーンを注入します。
