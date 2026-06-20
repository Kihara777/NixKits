# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/llama-cpp-rocm.md) | [ｶﾀﾘｯｼｭ](../katalish/llama-cpp-rocm.md) | [偽中国語](../pcn/llama-cpp-rocm.md)

Upstream llama.cpp with ROCm GPU acceleration. Dynamically fetches the latest GitHub Release ﾊﾞｰｼﾞｮﾝ at ﾋﾞﾙﾄﾞ time for testing cutting-edge features.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Auto-tracks ｳﾌﾟｽﾄﾗｴｱﾑ |
| Upstream | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| Note | Overlay-only, no standalone ﾊﾟｯｹｰｼﾞ output |

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

The ﾓｼﾞｭｰﾙ auto-sets `LLAMA_CACHE` to `/home/<user>/.cache/huggingface/hub` and lifts `/home` and `/proc` sandbox restrictions.

> **Warning: Home Manager llama-cpp ｻｰﾋﾞｽ**
>
> If enabled via Home Manager, additional user-level sandboxing may prevent GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-level ｺﾝﾌｨｷﾞｭﾗｴｰｼｮﾝ.

## Migration Guide

### Affected Versions

| Component | Affected | Change |
|-----------|----------|--------|
| nixpkgs | ≥ 2026-06 (master) | `ｻｰﾋﾞｽs.llama-cpp.modelsPreset` removed; `port`/`host`/`model`/`modelsDir` renamed to `settings.port`/`settings.host`/… |
| NixKits | ≥ `6f52ddf` (`ﾓｼﾞｭｰﾙs/llama-cpp-rocm.nix`) | Namespace: `ｻｰﾋﾞｽs.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` |
| Upstream llama.cpp | b9605 | `--models-preset` CLI argument retained |

### Config Key Mapping

| Old (deprecated) | New | Notes |
|------------------|-----|-------|
| `ｻｰﾋﾞｽs.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | Removed from nixpkgs, restored via NixKits |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | Namespace unified |
| `ｻｰﾋﾞｽs.llama-cpp.port` | `ｻｰﾋﾞｽs.llama-cpp.settings.port` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.host` | `ｻｰﾋﾞｽs.llama-cpp.settings.host` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.model` | `ｻｰﾋﾞｽs.llama-cpp.settings.model` | nixpkgs rename |
| `ｻｰﾋﾞｽs.llama-cpp.modelsDir` | `ｻｰﾋﾞｽs.llama-cpp.settings.models-dir` | nixpkgs rename |
| Manual `systemd.ｻｰﾋﾞｽs.llama-cpp.ｻｰﾋﾞｽConfig` | Remove | Handled by NixKits ﾓｼﾞｭｰﾙ |
| `ｻｰﾋﾞｽs.llama-cpp.extraFlags` | Add flags to `ｻｰﾋﾞｽs.llama-cpp.settings` | nixpkgs removal |

### Migration Example

> **⚠️ Step 1**: Add `nix-kits.nixosModules.llama-cpp-rocm` to your flake ﾓｼﾞｭｰﾙ list.

**Before**:

```nix
# flake.nix — module list
{ modules = [
    # nix-kits.nixosModules.llama-cpp-rocm  # ← not yet imported
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
# flake.nix — module list (new)
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
  # Extra env vars not covered by NixKits options
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=/home/kix/.cache/huggingface/hub"
    "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
  ];
}
```
