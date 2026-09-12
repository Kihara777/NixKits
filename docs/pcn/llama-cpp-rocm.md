# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)  | 偽中国語

llama.cpp ROCm GPU 加速有効化。構築時 GitHub 最新版動的取得、最先端機能試験使用。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 上流最新版自動追跡 |
| 上流 | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | 上乗提供、単独包出力無 |

## 導入

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使用法

上流 llama.cpp 文書参照。

## Flake 部品

```nix
# flake.nix
{
  inputs.nixkits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nixkits, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nixkits.nixosModules.llama-cpp-rocm
        {
          services.llama-cpp = {
            enable = true;
            package = pkgs.llama-cpp-rocm;
            port = 2027;
          };
          nixkits.llama-cpp-rocm = {
            enable = true;
            user = "kix";
            group = "users";
            modelsPreset = {
              "*" = {
                presence-penalty = "0.0";
                repeat-penalty   = "1.0";
                flash-attn       = "on";
                n-gpu-layers     = "99";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                load-mode        = "none";
                warmup           = "on";
                jinja            = "on";
                fit              = "on";
                prio             = "3";
              };
              "Qwen3.6-27B-MTP" = {
                hf-repo              = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.6-27B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3.6-35B-A3B-MTP" = {
                hf-repo              = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.6-35B-A3B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3.5-122B-A10B-MTP" = {
                hf-repo              = "unsloth/Qwen3.5-122B-A10B-MTP-GGUF:UD-Q4_K_XL";
                alias                = "Qwen3.5-122B-A10B-MTP";
                temp                 = "0.6";
                top-p                = "0.95";
                top-k                = "20";
                min-p                = "0.00";
                ctx-size             = "1048576";
                rope-scaling         = "yarn";
                rope-scale           = "4";
                yarn-orig-ctx        = "262144";
                spec-type            = "draft-mtp";
                spec-draft-n-max     = "2";
              };
              "Qwen3-Coder-Next" = {
                hf-repo       = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q4_K_XL";
                alias         = "Qwen3-Coder-Next";
                temp          = "1.0";
                top-p         = "0.95";
                top-k         = "40";
                min-p         = "0.01";
                seed          = "3407";
                ctx-size      = "1048576";
                rope-scaling  = "yarn";
                rope-scale    = "4";
                yarn-orig-ctx = "262144";
              };
              "MiniMax-M2.7" = {
                hf-repo  = "unsloth/MiniMax-M2.7-GGUF:UD-Q2_K_XL";
                alias    = "MiniMax-M2.7";
                temp     = "1.0";
                top-p    = "0.95";
                top-k    = "40";
                min-p    = "0.01";
                ctx-size = "196608";
              };
            };
          };
        }
      ];
    };
  };
}
```

部品 `LLAMA_CACHE` `~/.cache/huggingface/hub` 自動設定、`/home` 與 `/proc` 砂箱制限解除。

> **警告: Home Manager llama-cpp 服務**
>
> Home Manager 経由有効化場合、追加利用者段砂箱 GPU 接続（`/dev/dri`、`/dev/kfd`）遮断可能性有。体系段設定推奨。

## 模型説明

`modelsPreset` 複数模型保持、服務起動時必要応読込。全局預設 `"*"` 全模型適用、個別模型項目特定参數上書き可能。`hf-repo` HuggingFace から GGUF 形式模型文件自動取得。

## 参數詳解

以下参數は Strix Halo（統合記憶体）上 llama.cpp 0.4.0 で実測検証済。

| 参數 | 推奨値 | 説明 |
|------|--------|------|
| `fit` | `"on"` | 未設定引數を装置記憶体に合自動調整。**`"off"` は VRAM 制限下 OOM 発生** |
| `jinja` | `"on"` | 模型内蔵 chat template 適用。**無効化時、輸出退化** |
| `load-mode` | `"none"` | 非推奨 `mmap` 置換。`"none"` は旧 `--no-mmap` 相当 |
| `n-gpu-layers` | `"99"` | 全層 GPU 転送 |
| `flash-attn` | `"on"` | Flash Attention 有効化、attention 記憶体削減 |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache 量子化。**`iq4_nl` は ROCm 核心不在 CPU 退回、約 2.6 倍遅** |
| `threads` | `"32"` | CPU 執行糸数 |
| `parallel` | `"1"` | 服務槽位数。増加時 KV 予約倍数増 |
| `batch-size` | `"512"` | 論理批次。既定 `ubatch-size` 合計算緩衝縮小 |
| `warmup` | `"on"` | 読込後空実行一回。最初実請求高速化 |

> **注意**：`modelsPreset` 値は**文字列**（`attrsOf (attrsOf str)`）必須。`"on"` / `"off"` 記述、`true` / `false` 使用不可。

### 回避項目

| 項目 | 理由 |
|------|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **模型輸出破壊**（語彙反復・文字化）。同模型同預設、此変数無場合正常応答 |
| `mmap` | 非推奨。`load-mode` 使用 |
| `--no-mmproj` | mmproj 量子化不一致時暫定回避のみ。画像入力必要 |

## 移行手引

### 影響受版

| 構成素 | 影響範囲 | 変更内容 |
|-------------|---------|---------|
| nixpkgs | 2026-06 以降（master） | `services.llama-cpp.modelsPreset` 削除、`port`/`host`/`model`/`modelsDir` `settings.port`/`settings.host`/… 改名 |
| NixKits | `6f52ddf` 以降（`modules/llama-cpp-rocm.nix`） | 名前空間 `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` 移行 |
| 上流 llama.cpp | b9605 | `--models-preset` CLI 引数維持 |

### 設定項目対応表

| 旧設定（非推奨） | 新設定 | 備考 |
|-----------------|--------|------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | nixpkgs 自削除、NixKits 以復元 |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | 名前空間統一 |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | 同上 |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | 同上 |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs 改名 |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs 改名 |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs 改名 |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs 改名 |
| 手動 `systemd.services.llama-cpp.serviceConfig` | 削除 | NixKits 部品自動処理 |
| `services.llama-cpp.extraFlags` | `services.llama-cpp.settings` 対応旗追加 | nixpkgs 削除 |

### 移行例

> **⚠️ 段階 1**: `flake.nix` 部品一覧 `nixkits.nixosModules.llama-cpp-rocm` 追加

**移行前**:

```nix
# flake.nix — 部品一覧
{ modules = [
    # nixkits.nixosModules.llama-cpp-rocm  # ← 未輸入
];}

# llama-cpp.nix
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
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # 手動 systemd 設定
  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    User = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=~/.cache/huggingface/hub"
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
    ProcSubset = lib.mkForce "all";
  };
}
```

**移行後**:

```nix
# flake.nix — 部品一覧（追加）
{ modules = [
    nixkits.nixosModules.llama-cpp-rocm
];}

# llama-cpp.nix
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    settings.port = 2027;
  };
  nixkits.llama-cpp-rocm = {
    enable = true;
    user = "kix";
    group = "users";
    hfCacheDir = "~/.cache/huggingface/hub";
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # NixKits 選項以覆非環境変数
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=~/.cache/huggingface/hub"
  ];
}
```
