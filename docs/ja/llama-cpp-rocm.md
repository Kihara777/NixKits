# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](llama-cpp-rocm.md)

[llama.cpp](https://github.com/ggml-org/llama.cpp) に ROCm GPU アクセラレーションを有効化。ビルド時に GitHub 最新リリースバージョンを動的取得し、最先端機能のテストに使用します。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | アップストリーム最新リリースを自動追跡 |
| アップストリーム | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | overlay のみ提供、単独パッケージ出力なし |

## インストール

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使い方

```bash
llama-server -m model.gguf --gpu-device 0
llama-cli -m model.gguf -p "こんにちは" --gpu-device 0
```

## Flake モジュール

```nix
# flake.nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nix-kits.nixosModules.llama-cpp-rocm
        {
          services.llama-cpp-rocm = {
            enable = true;
            user = "kix";
            group = "users";
          };
          services.llama-cpp = {
            enable = true;
            package = pkgs.llama-cpp-rocm;
            port = 2027;
            modelsPreset = {
              "*" = {
                n-gpu-layers = "99";
                flash-attn = "on";
              };
              "Qwen3.6-27B-MTP" = {
                hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
                temp = "0.6";
                ctx-size = "1048576";
              };
            };
          };
        }
      ];
    };
  };
}
```

モジュールは `LLAMA_CACHE` を `/home/<user>/.cache/huggingface/hub` に自動設定し、`/home` と `/proc` のサンドボックス制限を解除します。

> **警告: Home Manager の llama-cpp サービス**
>
> Home Manager 経由で有効にした場合、追加のユーザーレベルサンドボックスにより GPU アクセス（`/dev/dri`、`/dev/kfd`）がブロックされる可能性があります。システムレベルでの設定を推奨します。
