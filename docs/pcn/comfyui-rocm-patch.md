# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI  ROCm 機能パッチ提供。

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

`rocmGfxOverride` 設定與、`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI サービス注入。 xformers 自動無効化（nixpkgs 版 ROCm バックエンド非対応）、C ビルドツールチェーン注入。
