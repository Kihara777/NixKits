# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](../ja/comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | 偽中国語

ComfyUI  ROCm 機能パッチ提供。

## 基本情報

- **機能**：ComfyUI  ROCm サポートパッチ当，カスタムノードビルドツールチェーン有効化(`gfxOverride` カスタム GPU ターゲット指定)
- **位置**：`modules/comfyui-rocm-patch.nix`

## 使方

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # カスタム GPU ターゲットバージョン
}
```

`rocmGfxOverride` 設定，`HSA_OVERRIDE_GFX_VERSION` 環境変数 ComfyUI サービス注入。
