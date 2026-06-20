# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

ComfyUI に ROCm 機能パッチを提供。

## 基本情報

- **機能**：ComfyUI の ROCm サポートにパッチを当て、カスタムノードビルドツールチェーンを有効化（`gfxOverride` でカスタム GPU ターゲットを指定）
- **位置**：`modules/comfyui-rocm-patch.nix`

## 使い方

```nix
{
  services.comfyui.rocmGfxOverride = "gfx1100";  # カスタム GPU ターゲットバージョン
}
```

`rocmGfxOverride` が設定されると、`HSA_OVERRIDE_GFX_VERSION` 環境変数が ComfyUI サービスに注入されます。
