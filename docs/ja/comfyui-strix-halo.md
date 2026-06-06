# ComfyUI Strix Halo パッチ

[中文](../zh/comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md) | [日本語](comfyui-strix-halo.md)

AMD Strix Halo（gfx1151 / RDNA 3.5 APU）向け ComfyUI ROCm アクセラレーション。
**Ryzen AI MAX+ 395 / Radeon 8060S** で実機検証済み。

## 背景

Strix Halo（Ryzen AI MAX+ 395 / Radeon 8060S など）の GPU アーキテクチャは gfx1151 です。
ROCm 7.1 時点では gfx1151 は**公式サポート対象外**でしたが、ROCm 7.2 でネイティブサポートが追加されました。

本パッチは [comfyui-nix](https://github.com/utensils/comfyui-nix) に 4 箇所の変更を加えます：

| ファイル | 変更内容 |
|----------|---------|
| `nix/versions.nix` | ROCm 7.2 stable wheel 定義を追加（torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0） |
| `nix/python-overrides.nix` | ROCm バージョン自動選択：rocm72 定義があれば 7.2、なければ 7.1 にフォールバック |
| `nix/modules/comfyui.nix` | `rocmGfxOverride` オプション + ROCm モード時の自動 `--disable-xformers` |

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | comfyui-nix に追従 |
| アップストリーム | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| パッチ | 本リポジトリ `patches/comfyui-nix-strix-halo.patch` |
| 注意 | 手動パッチまたは NixOS モジュールで適用 |

## 検証済み

| 項目 | 結果 |
|------|------|
| ハードウェア | Ryzen AI MAX+ 395 / Radeon 8060S（128 GB VRAM） |
| GPU 認識 | **AMD Radeon 8060S : native**（HSA_OVERRIDE_GFX_VERSION 不要） |
| torch バージョン | 2.12.0+rocm7.2 |
| 生成テスト | Z-Image 1024×1024, 10 steps — 成功（2.0 MB PNG） |

## 使用方法

### 方法 A：NixOS モジュール（推奨）

パッチ適用後、NixKits モジュールを有効化：

```nix
# flake.nix
{
  inputs = {
    nix-kits.url = "github:Kihara777/NixKits";
    # パッチ済み comfyui-nix を使用（ローカル clone または fork）：
    comfyui-nix.url = "/path/to/patched-comfyui-nix";
  };

  outputs = { nix-kits, comfyui-nix, ... }: {
    nixosConfigurations.xxx = nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nix-kits.nixosModules.comfyui-strix-halo
        {
          nixkits.comfyui-strix-halo.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
  };
}
```

モジュール有効化時の自動設定：
- `hardware.graphics` の構成（ROCm ランタイムライブラリ）
- `gpuSupport = "rocm"` の設定
- Strix Halo カーネルパラメータの注入（`amdgpu.gttsize=131072`）
- オプションで `HSA_OVERRIDE_GFX_VERSION` の設定

### 方法 B：手動パッチ適用

```bash
cd comfyui-nix
patch -p1 < /path/to/NixKits/patches/comfyui-nix-strix-halo.patch
```

システム設定：

```nix
inputs.comfyui-nix.url = "/path/to/patched-comfyui-nix";
services.comfyui.gpuSupport = "rocm";
```

パッチには ROCm モードの自動 `--disable-xformers` が含まれています。

### rocmGfxOverride オプション

モジュールはデフォルトで `HSA_OVERRIDE_GFX_VERSION` を**設定しません**。
ROCm 7.2 は gfx1151 をネイティブサポートしており、実機検証でも不要でした。
将来 GPU が認識されない場合は上書きを有効化：

```nix
services.comfyui.rocmGfxOverride = "11.0.0";  # gfx1100 互換パス
```

| 値 | アーキテクチャ | 説明 |
|----|--------------|------|
| `"11.0.0"` | gfx1100（RDNA 3） | gfx1151 に最適な互換選択 |
| `"11.5.1"` | gfx1151（RDNA 3.5） | ネイティブアーキテクチャ |

## トラブルシューティング

### GPU が PyTorch に認識されない

症状：起動ログに `Torch not compiled with ROCm enabled` または `No GPU detected`。

1. `/dev/kfd` と `/dev/dri/renderD128` の存在を確認
2. `rocminfo` の出力を確認（`rocmPackages.rocminfo` が必要）
3. `rocmGfxOverride = "11.0.0"` を試行

### xformers エラー

症状：`NotImplementedError: No operator found for memory_efficient_attention_forward`

パッチは ROCm モード時に自動で `--disable-xformers` を追加します。
モジュールを使用せず手動で ComfyUI を起動する場合は、手動でこのフラグを追加してください。

### ROCm ランタイムが見つからない

```
rocminfo: command not found
libamdhip64.so: cannot open shared object file
```

NixKits モジュールが `hardware.graphics.extraPackages` を自動構成します。
手動設定：

```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.rocminfo
  ];
};
```

## 技術詳細

### アーキテクチャサポート状況

| ROCm バージョン | gfx1151 の状態 |
|----------------|---------------|
| 7.1 | プレビュー — `HSA_OVERRIDE_GFX_VERSION` が必要 |
| 7.2 | ネイティブ — 本パッチのデフォルト、実機検証済み |

### HSA_OVERRIDE_GFX_VERSION の仕組み

ROCm ランタイムは GPU アーキテクチャに応じて事前コンパイル済みカーネルを選択します。
gfx1151 向けカーネルが利用できない場合、`HSA_OVERRIDE_GFX_VERSION=11.0.0` で
ランタイムに gfx1100（RDNA 3）カーネルの読み込みを強制します。
両者はバイナリ互換です。ROCm 7.2 + PyTorch 2.12.0 では gfx1151 カーネルが
ネイティブに含まれているため、上書き不要です。

### xformers について

nixpkgs の `xformers` パッケージは CUDA バックエンドのみ提供しており、
ROCm サポートがありません。パッチは ROCm モード時に自動で `--disable-xformers`
を追加し、PyTorch ネイティブ attention にフォールバックします。
ROCm 上でも同等のパフォーマンスが得られます。

### Strix Halo カーネルパラメータ

Strix Halo は統合メモリアーキテクチャ（UMA）を採用。推奨設定：

```
amdgpu.gttsize=131072  # 128GB GTT、大規模モデル対応
```

NixKits モジュール有効時に自動設定されます。

## 参考

- [ROCm 互換性マトリックス](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- [ROCm RDNA 3.5 最適化ガイド](https://rocm.docs.amd.com/en/latest/how-to/system-optimization/rdna3-5.html)
- [PyTorch ROCm 7.2 wheels](https://download.pytorch.org/whl/rocm7.2/)
- [ROCm/ROCm Issue #5339 — gfx1151 サポート議論](https://github.com/ROCm/ROCm/issues/5339)
