# comfyui-rocm-patch

[中文](../zh/comfyui-rocm-patch.md) | [English](../en/comfyui-rocm-patch.md) | [日本語](comfyui-rocm-patch.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-rocm-patch.md) | [偽中国語](../pcn/comfyui-rocm-patch.md)

> `services.comfyui` に `rocmGfxOverride` オプションと ROCm 環境変数注入を追加し、NixOS 上で AMD ROCm GPU による ComfyUI 実行を可能にする。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種類 | NixOS モジュール |
| モジュールパス | `nix-kits.nixosModules.comfyui-rocm-patch` |
| 依存 | comfyui-strix-halo |

## 機能

- `services.comfyui.rocmGfxOverride` オプション — `HSA_OVERRIDE_GFX_VERSION` を設定
- `--disable-xformers` フラグ注入（ROCm は xformers 非対応）
- カスタムノードコンパイル用 C ビルドツールチェーン（gcc、binutils、make）

## インストール

```nix
{
  nixpkgs.overlays = [ nix-kits.overlays.default ];
}

services.comfyui = {
  enable = true;
  rocmGfxOverride = "11.5.1";
};
```

## 注意

- `rocmGfxOverride` のデフォルトは `null`（HSA_OVERRIDE_GFX_VERSION 未設定）
- `comfyui-strix-halo` モジュールが `nixkits.comfyui-strix-halo.gfxOverride` 経由で自動設定
