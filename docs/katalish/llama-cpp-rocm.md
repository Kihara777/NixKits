# llama-cpp-rocm

[中文](../../zh/llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../../ja/llama-cpp-rocm.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/llama-cpp-rocm.md)

Upstream llama.cpp ｳｨｽﾞ ﾛｯｸｴﾑ GPU acceleration. Dynamically fetches ｻﾞ latest GitHub Release ﾊﾞｰｼﾞｮﾝ ｱｯﾄ ﾋﾞﾙﾄﾞ time ﾌｫｱ testing cutting-edge ﾌｨｰﾁｬｰｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | ｵｰﾄ-tracks upstream |
| Upstream | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| Note | ｵｰﾊﾞｰﾚｲ-ｵﾝﾘｰ, ﾉｰ standalone ﾊﾟｯｹｰｼﾞ output |

## ｲﾝｽﾄｰﾙ

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## ﾕｰｾｰｼﾞ

See upstream llama.cpp ﾄﾞｷｭｽﾞ.

## Flake ﾓｼﾞｭｰﾙ

```nix
# flake.ﾆｯｸｽ
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
                repeat-penalty   = "1.0";
                flash-attn       = "on";
                n-gpu-layers     = "99";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                mmap             = "off";
                warmup           = "on";
                jinja            = "on";
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

ｻﾞ ﾓｼﾞｭｰﾙ ｵｰﾄ-sets `LLAMA_CACHE` ﾄｩ `/home/<user>/.cache/huggingface/hub` ｱﾝﾄﾞ lifts `/home` ｱﾝﾄﾞ `/proc` sandbox restrictions.

> **Warning: Home Manager llama-cpp service**
>
> If enabled via Home Manager, additional user-level sandboxing may prevent GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-level configuration.

## Migration ｶﾞｲﾄﾞ

### Affected ﾊﾞｰｼﾞｮﾝｽﾞ

| Component | Affected | Change |
|-----------|----------|--------|
| nixpkgs | ≥ 2026-06 (master) | `services.llama-cpp.modelsPreset` removed; `port`/`host`/`model`/`modelsDir` renamed ﾄｩ `settings.port`/`settings.host`/… |
| NixKits | ≥ `6f52ddf` (`modules/llama-cpp-rocm.nix`) | Namespace: `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` |
| Upstream llama.cpp | b9605 | `--models-preset` CLI argument retained |

### ｺﾝﾌｨｸﾞ ｷｰ ﾏｯﾋﾟﾝｸﾞ

| ｵｰﾙﾄﾞ (deprecated) | ﾆｭｰ | Notes |
|------------------|-----|-------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | Removed ﾌﾛﾑ nixpkgs, restored via NixKits |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | Namespace unified |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | Namespace unified |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | Namespace unified |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs rename |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs rename |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs rename |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs rename |
| Manual `systemd.services.llama-cpp.serviceConfig` | ﾘﾑｰﾌﾞ | Handled ﾊﾞｲ NixKits ﾓｼﾞｭｰﾙ |
| `services.llama-cpp.extraFlags` | ｱﾄﾞ flags ﾄｩ `services.llama-cpp.settings` | nixpkgs removal |

### Migration Example

> **⚠️ Step 1**: Add `nix-kits.nixosModules.llama-cpp-rocm` to your flake module list.

**Before**:

```nix
# flake.ﾆｯｸｽ — ﾓｼﾞｭｰﾙ ﾘｽﾄ
{ modules = [
    # ﾆｯｸｽ-kits.nixosModules.llama-cpp-rocm  # ← ﾉｯﾄ yet imported
];}

# llama-cpp.ﾆｯｸｽ
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
  # Manual systemd overrides
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

**After**:

```nix
# flake.ﾆｯｸｽ — ﾓｼﾞｭｰﾙ ﾘｽﾄ (ﾆｭｰ)
{ modules = [
    nix-kits.nixosModules.llama-cpp-rocm
];}

# llama-cpp.ﾆｯｸｽ
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
  # Extra env vars ﾉｯﾄ covered ﾊﾞｲ NixKits options
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=/home/kix/.cache/huggingface/hub"
    "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
  ];
}
```