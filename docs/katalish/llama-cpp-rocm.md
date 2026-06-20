# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/llama-cpp-rocm.md) | [ｶﾀﾘｯｼｭ](../katalish/llama-cpp-rocm.md) | [偽中国語](../pcn/llama-cpp-rocm.md)

ｳﾌﾟｽﾄﾗｴｱﾑ llama.cpp ｳｨｽﾞ ROCm GPU acceleration. Dynamically fetches ｻﾞ latest ｷﾞｯﾄﾊﾌﾞ Release ﾊﾞｰｼﾞｮﾝ ｱｯﾄ ﾋﾞﾙﾄﾞ time ﾌｫｱ testing cutting-edge features.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| Version | Auto-tracks ｳﾌﾟｽﾄﾗｴｱﾑ |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| ﾉｰﾄ | Overlay-ｵﾝﾘｰ, ﾉｰ standalone ﾊﾟｯｹｰｼﾞ ｱｳﾄﾌﾟｯﾄ |

## ｲﾝｽﾄｰﾙ

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## ﾕｰｾｰｼﾞ

See ｳﾌﾟｽﾄﾗｴｱﾑ llama.cpp docs.

## Flake Module

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
            ﾎﾟｰﾄ = 2027;
          };
          nixkits.llama-cpp-rocm = {
            enable = true;
            ﾕｰｻﾞｰ = "kix";
            ｸﾞﾙｰﾌﾟ = "users";
            modelsPreset = {
              "*" = {
                presence-penalty = "0.0";
                repeat-penalty   = "1.0";
                flash-attn       = "ｵﾝ";
                n-gpu-layers     = "99";
                cache-ﾀｲﾌﾟ-k     = "q4_0";
                cache-ﾀｲﾌﾟ-v     = "q4_0";
                threads          = "32";
                mmap             = "off";
                warmup           = "ｵﾝ";
                jinja            = "ｵﾝ";
                fit              = "off";
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
                spec-ﾀｲﾌﾟ            = "draft-mtp";
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
                spec-ﾀｲﾌﾟ            = "draft-mtp";
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
                spec-ﾀｲﾌﾟ            = "draft-mtp";
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

The ﾓｼﾞｭｰﾙ ｵｰﾄ-sets `LLAMA_CACHE` ﾄｩ `/ﾎｰﾑ/<ﾕｰｻﾞｰ>/.cache/huggingface/hub` ｱﾝﾄﾞ lifts `/ﾎｰﾑ` ｱﾝﾄﾞ `/proc` sandbox restrictions.

> **Warning: Home Manager llama-cpp ｻｰﾋﾞｽ**
>
> If enabled ﾌﾞｲｱ Home Manager, additional ﾕｰｻﾞｰ-ﾚﾍﾞﾙ sandboxing ﾒｲ ﾌﾟﾗｴﾌﾞｴﾝﾄ GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-ﾚﾍﾞﾙ ｺﾝﾌｨｷﾞｭﾗｴｰｼｮﾝ.

## Migration Guide

### Affected Versions

| Component | Affected | Change |
|-----------|----------|--------|
| nixpkgs | ≥ 2026-06 (master) | `ｻｰﾋﾞｽs.llama-cpp.modelsPreset` removed; `ﾎﾟｰﾄ`/`host`/`ﾓﾃﾞﾙ`/`modelsDir` renamed ﾄｩ `ｾｯﾃｨﾝｸﾞｽﾞ.ﾎﾟｰﾄ`/`ｾｯﾃｨﾝｸﾞｽﾞ.host`/… |
| NixKits | ≥ `6f52ddf` (`ﾓｼﾞｭｰﾙs/llama-cpp-rocm.nix`) | Namespace: `ｻｰﾋﾞｽs.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` |
| ｳﾌﾟｽﾄﾗｴｱﾑ llama.cpp | b9605 | `--models-preset` ｼｰｴﾙｱｲ argument retained |

### Config Key Mapping

| Old (deprecated) | New | Notes |
|------------------|-----|-------|
| `ｻｰﾋﾞｽs.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | Removed ﾌﾛﾑ nixpkgs, restored ﾌﾞｲｱ NixKits |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.ｲﾈｰﾌﾞﾙ` | `nixkits.llama-cpp-rocm.ｲﾈｰﾌﾞﾙ` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.ﾕｰｻﾞｰ` | `nixkits.llama-cpp-rocm.ﾕｰｻﾞｰ` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.ｸﾞﾙｰﾌﾟ` | `nixkits.llama-cpp-rocm.ｸﾞﾙｰﾌﾟ` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp.ﾎﾟｰﾄ` | `ｻｰﾋﾞｽs.llama-cpp.ｾｯﾃｨﾝｸﾞｽﾞ.ﾎﾟｰﾄ` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.host` | `ｻｰﾋﾞｽs.llama-cpp.ｾｯﾃｨﾝｸﾞｽﾞ.host` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.ﾓﾃﾞﾙ` | `ｻｰﾋﾞｽs.llama-cpp.ｾｯﾃｨﾝｸﾞｽﾞ.ﾓﾃﾞﾙ` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.modelsDir` | `ｻｰﾋﾞｽs.llama-cpp.ｾｯﾃｨﾝｸﾞｽﾞ.models-dir` | nixpkgs rename |
| Manual `systemd.ｻｰﾋﾞｽs.llama-cpp.ｻｰﾋﾞｽConfig` | Remove | Handled ﾊﾞｲ NixKits ﾓｼﾞｭｰﾙ |
| `ｻｰﾋﾞｽs.llama-cpp.extraFlags` | Add flags ﾄｩ `ｻｰﾋﾞｽs.llama-cpp.ｾｯﾃｨﾝｸﾞｽﾞ` | nixpkgs removal |

### Migration Example

> **⚠️ Step 1**: Add `nix-kits.nixosModules.llama-cpp-rocm` ﾄｩ your flake ﾓｼﾞｭｰﾙ ﾘｽﾄ.

**Before**:

```nix
# flake.nix — module ﾘｽﾄ
{ modules = [
    # nix-kits.nixosModules.llama-cpp-rocm  # ← ﾉｯﾄ yet imported
];}

# llama-cpp.nix
{
  services.llama-cpp-rocm = {
    enable = true;
    ﾕｰｻﾞｰ = "kix";
    ｸﾞﾙｰﾌﾟ = "users";
  };
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    ﾎﾟｰﾄ = 2027;
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # Manual systemd overrides
  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome = lib.mkForce false;
    User = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=/ﾎｰﾑ/kix/.cache/huggingface/hub"
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
    ProcSubset = lib.mkForce "ｵｰﾙ";
  };
}
```

**After**:

```nix
# flake.nix — module ﾘｽﾄ (ﾆｭｰ)
{ modules = [
    nix-kits.nixosModules.llama-cpp-rocm
];}

# llama-cpp.nix
{
  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-rocm;
    ｾｯﾃｨﾝｸﾞｽﾞ.ﾎﾟｰﾄ = 2027;
  };
  nixkits.llama-cpp-rocm = {
    enable = true;
    ﾕｰｻﾞｰ = "kix";
    ｸﾞﾙｰﾌﾟ = "users";
    hfCacheDir = "/ﾎｰﾑ/kix/.cache/huggingface/hub";
    modelsPreset = {
      "Qwen3-Coder-Next" = {
        hf-repo = "unsloth/Qwen3-Coder-Next-GGUF";
        hf-file = "Qwen3-Coder-Next-UD-Q4_K_XL.gguf";
        temp = "1.0";
      };
    };
  };
  # Extra env vars ﾉｯﾄ covered ﾊﾞｲ NixKits options
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=/ﾎｰﾑ/kix/.cache/huggingface/hub"
    "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
  ];
}
```
