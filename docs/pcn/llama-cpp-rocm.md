# llama-cpp-rocm

[中文](../../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md) | [ｶﾀﾘｯｼｭ](../katalish/llama-cpp-rocm.md) | [偽中国語](llama-cpp-rocm.md)

llama.cpp ROCm GPU 加速有効化構建時 GitHub 最新發佈版本動的取得最先端機能使用

## 基本情報

|項目|値|
|------|-----|
|版本|最新發佈自動追跡|
||[ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp)|
|注意|overlay 提供単独軟件包出力|

## 安裝

```nix
{
nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使方

llama.cpp 文檔参照

## Flake 模塊

```nix
# flake.nix
{
inputs.nix-kits.url = "github:Kihara777/NixKits";

outputs = { nixpkgs, nix-kits, ... }: {
nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
modules = [
nix-kits.nixosModules.llama-cpp-rocm
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
repeat-penalty = "1.0";
flash-attn = "on";
n-gpu-layers = "99";
cache-type-k = "q4_0";
cache-type-v = "q4_0";
threads = "32";
mmap = "off";
warmup = "on";
jinja = "on";
fit = "off";
prio = "3";
};
"Qwen3.6-27B-MTP" = {
hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
alias = "Qwen3.6-27B-MTP";
temp = "0.6";
top-p = "0.95";
top-k = "20";
min-p = "0.00";
ctx-size = "1048576";
rope-scaling = "yarn";
rope-scale = "4";
yarn-orig-ctx = "262144";
spec-type = "draft-mtp";
spec-draft-n-max = "2";
};
"Qwen3.6-35B-A3B-MTP" = {
hf-repo = "unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL";
alias = "Qwen3.6-35B-A3B-MTP";
temp = "0.6";
top-p = "0.95";
top-k = "20";
min-p = "0.00";
ctx-size = "1048576";
rope-scaling = "yarn";
rope-scale = "4";
yarn-orig-ctx = "262144";
spec-type = "draft-mtp";
spec-draft-n-max = "2";
};
"Qwen3.5-122B-A10B-MTP" = {
hf-repo = "unsloth/Qwen3.5-122B-A10B-MTP-GGUF:UD-Q4_K_XL";
alias = "Qwen3.5-122B-A10B-MTP";
temp = "0.6";
top-p = "0.95";
top-k = "20";
min-p = "0.00";
ctx-size = "1048576";
rope-scaling = "yarn";
rope-scale = "4";
yarn-orig-ctx = "262144";
spec-type = "draft-mtp";
spec-draft-n-max = "2";
};
"Qwen3-Coder-Next" = {
hf-repo = "unsloth/Qwen3-Coder-Next-GGUF:UD-Q4_K_XL";
alias = "Qwen3-Coder-Next";
temp = "1.0";
top-p = "0.95";
top-k = "40";
min-p = "0.01";
seed = "3407";
ctx-size = "1048576";
rope-scaling = "yarn";
rope-scale = "4";
yarn-orig-ctx = "262144";
};
"MiniMax-M2.7" = {
hf-repo = "unsloth/MiniMax-M2.7-GGUF:UD-Q2_K_XL";
alias = "MiniMax-M2.7";
temp = "1.0";
top-p = "0.95";
top-k = "40";
min-p = "0.01";
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

模塊 `LLAMA_CACHE` `/home/<user>/.cache/huggingface/hub` 自動設定`/home` `/proc` 制限解除

> **警告: Home Manager llama-cpp 服務**
>
> Home Manager 経由有効場合追加 GPU `/dev/dri``/dev/kfd`可能性系統設定推奨

## 移行指南

### 影響受版本

|組件|影響範囲|変更内容|
|-------------|---------|---------|
|nixpkgs|2026-06 以降master|`services.llama-cpp.modelsPreset` 削除`port`/`host`/`model`/`modelsDir` `settings.port`/`settings.host`/…|
|NixKits|`6f52ddf` 以降`modules/llama-cpp-rocm.nix`|名前空間 `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` 移行|
|llama.cpp|b9605|`--models-preset` CLI 引数維持|

### 設定項目対応表

|旧設定非推奨|新設定|備考|
|-----------------|--------|------|
|`services.llama-cpp.modelsPreset`|`nixkits.llama-cpp-rocm.modelsPreset`|nixpkgs 削除NixKits 復元|
|`services.llama-cpp-rocm.enable`|`nixkits.llama-cpp-rocm.enable`|名前空間統一|
|`services.llama-cpp-rocm.user`|`nixkits.llama-cpp-rocm.user`|同上|
|`services.llama-cpp-rocm.group`|`nixkits.llama-cpp-rocm.group`|同上|
|`services.llama-cpp.port`|`services.llama-cpp.settings.port`|nixpkgs|
|`services.llama-cpp.host`|`services.llama-cpp.settings.host`|nixpkgs|
|`services.llama-cpp.model`|`services.llama-cpp.settings.model`|nixpkgs|
|`services.llama-cpp.modelsDir`|`services.llama-cpp.settings.models-dir`|nixpkgs|
|手動 `systemd.services.llama-cpp.serviceConfig`|削除|NixKits 模塊自動処理|
|`services.llama-cpp.extraFlags`|`services.llama-cpp.settings` 対応追加|nixpkgs 削除|

### 移行例

> **⚠️ 1**: `flake.nix` 模塊 `nix-kits.nixosModules.llama-cpp-rocm` 追加

**移行前**:

```nix
# flake.nix — 模塊
{ modules = [
# nix-kits.nixosModules.llama-cpp-rocm # ← 未
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
"LLAMA_CACHE=/home/kix/.cache/huggingface/hub"
"GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
];
ProcSubset = lib.mkForce "all";
};
}
```

**移行後**:

```nix
# flake.nix — 模塊追加
{ modules = [
nix-kits.nixosModules.llama-cpp-rocm
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
hfCacheDir = "/home/kix/.cache/huggingface/hub";
modelsPreset = {
"Qwen3-Coder-Next" = {
hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
temp = "1.0";
};
};
};
# NixKits 選項環境変数
systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
"LLAMA_CACHE=/home/kix/.cache/huggingface/hub"
"GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
];
}
```