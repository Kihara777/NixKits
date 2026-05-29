# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](llama-cpp-rocm.md)

[llama.cpp](https://github.com/ggml-org/llama.cpp) に ROCm GPU アクセラレーションを有効化した派生パッケージ。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs `llama-cpp` に追従 |
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

## システムサービス

```nix
let
  hfCache = "/home/kix/.cache/huggingface/hub";
in
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    port = 2027;
    modelsPreset = {
      "*" = {
        n-gpu-layers = "99";
        threads = "32";
        flash-attn = "on";
      };
      "Qwen3.6-27B-MTP" = {
        hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
        temp = "0.6";
        ctx-size = "1048576";
      };
    };
  };

  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser  = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome  = lib.mkForce false;    # /home 以下のモデルファイルにアクセス
    ProcSubset   = lib.mkForce "all";     # journalctl のメモリ情報警告を抑制
    User  = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=${hfCache}"
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
  };
}
```

> **警告: Home Manager の llama-cpp サービス**
>
> Home Manager 経由で有効にした場合、追加のユーザーレベルサンドボックスにより GPU アクセス（`/dev/dri`、`/dev/kfd`）がブロックされる可能性があります。システムレベルでの設定を推奨します。
