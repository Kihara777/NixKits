# ﾗﾏ-cpp-rocm

[中文](../../zh/llama-cpp-rocm.md) | [ｲﾝｸﾞﾘｯｼｭ](llama-cpp-rocm.md) | [日本語](../../ja/llama-cpp-rocm.md) | [ｶﾀﾘｯｼｭ](../../katalish/llama-cpp-rocm.md) | [偽中国語](../../pcn/llama-cpp-rocm.md)

ｳﾌﾟｽﾄﾗｴｱﾑ ﾗﾏ.cpp ｳｨｽﾞ ﾛｯｸｴﾑ ｸﾞﾌﾟｳ ｱｸｽｴﾙｴﾗｱｼｮﾝ. ﾄﾞｲﾝｱﾑｲｸｱﾙﾘｰ ﾌｴﾄﾁｽﾞ ｻﾞ ﾙｱﾄｴｽﾄ GitHub ﾘﾘｰｽ ﾊﾞｰｼﾞｮﾝ ｱｯﾄ ﾋﾞﾙﾄﾞ ﾄｲﾑｴ ﾌｫｱ ﾄｴｽﾄｲﾝｸﾞ ｸｳﾄﾄｲﾝｸﾞ-ｴﾄﾞｼﾞｴ ﾌｨｰﾁｬｰｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | ｵｰﾄ-ﾄﾗｱｯｸｽﾞ ｳﾌﾟｽﾄﾗｴｱﾑ |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ｸﾞｸﾞﾑﾙ-ｵﾗｸﾞ/ﾗﾏ.cpp](https://github.com/ggml-org/llama.cpp) |
| ﾉｰﾄ | ｵｰﾊﾞｰﾚｲ-ｵﾝﾘｰ, ﾉｰ ｽﾄｱﾝﾄﾞｱﾙｵﾝｴ ﾊﾟｯｹｰｼﾞ ｱｳﾄﾌﾟｯﾄ |

## ｲﾝｽﾄｰﾙ

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## ﾕｰｾｰｼﾞ

ｼｰ ｳﾌﾟｽﾄﾗｴｱﾑ ﾗﾏ.cpp ﾄﾞｷｭｽﾞ.

## ﾌﾚｲｸ ﾓｼﾞｭｰﾙ

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ
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

ｻﾞ ﾓｼﾞｭｰﾙ ｵｰﾄ-ｽｴﾄｽﾞ `LLAMA_CACHE` ﾄｩ `/home/<user>/.cache/huggingface/hub` ｱﾝﾄﾞ ﾙｲﾌﾄｽﾞ `/home` ｱﾝﾄﾞ `/proc` ｽｱﾝﾄﾞﾌﾞｵｸｽ ﾗｴｽﾄﾗｲｸｼｮﾝｽﾞ.

> **ﾜｰﾆﾝｸﾞ: ﾎｰﾑ ﾑｱﾝｱｼﾞｴﾗ ﾗﾏ-cpp ｻｰﾋﾞｽ**
>
> ｲﾌ ｴﾝｱﾌﾞﾙﾄﾞ ﾌﾞｲｱ ﾎｰﾑ ﾑｱﾝｱｼﾞｴﾗ, ｱﾄﾞﾄﾞｲﾄｲｵﾝｱﾙ ﾕｰｻﾞｰ-ﾚﾍﾞﾙ ｽｱﾝﾄﾞﾌﾞｵｸｽｲﾝｸﾞ ﾒｲ ﾌﾟﾗｴﾌﾞｴﾝﾄ ｸﾞﾌﾟｳ ｱｸｾｽ (`/dev/dri`, `/dev/kfd`). ﾌﾟﾗｴﾌｴﾗ ｼｽﾃﾑ-ﾚﾍﾞﾙ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ.

## ﾑｲｸﾞﾗｱｼｮﾝ ｶﾞｲﾄﾞ

### ｱﾌﾌｴｸﾄﾄﾞ ﾌﾞｴﾗｼﾞｮﾝｽﾞ

| ｺﾝﾎﾟｰﾈﾝﾄ | ｱﾌﾌｴｸﾄﾄﾞ | ﾁｪﾝｼﾞ |
|-----------|----------|--------|
| ﾝｲｸｽﾌﾟｸｸﾞｽﾞ | ≥ 2026-06 (ﾑｱｽﾄｴﾗ) | `services.llama-cpp.modelsPreset` ﾗｴﾑｵﾌﾞﾄﾞ; `port`/`host`/`model`/`modelsDir` ﾗｴﾝｱﾑﾄﾞ ﾄｩ `settings.port`/`settings.host`/… |
| NixKits | ≥ `6f52ddf` (`modules/llama-cpp-rocm.nix`) | ﾝｱﾑｴｽﾌﾟｱｽｴ: `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` |
| ｳﾌﾟｽﾄﾗｴｱﾑ ﾗﾏ.cpp | ﾌﾞ9605 | `--models-preset` ｼｰｴﾙｱｲ ｱﾗｸﾞｳﾒﾝﾄ ﾗｴﾄｱｲﾝﾄﾞ |

### ｺﾝﾌｨｸﾞ ｷｰ ﾏｯﾋﾟﾝｸﾞ

| ｵｰﾙﾄﾞ (ﾄﾞｴﾌﾟﾗｴｸｱﾄﾄﾞ) | ﾆｭｰ | ﾉｰﾂ |
|------------------|-----|-------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | ﾗｴﾑｵﾌﾞﾄﾞ ﾌﾛﾑ ﾝｲｸｽﾌﾟｸｸﾞｽﾞ, ﾗｴｽﾄｵﾗﾄﾞ ﾌﾞｲｱ NixKits |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | ﾝｱﾑｴｽﾌﾟｱｽｴ ｳﾝｲﾌｲﾄﾞ |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | ﾝｱﾑｴｽﾌﾟｱｽｴ ｳﾝｲﾌｲﾄﾞ |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | ﾝｱﾑｴｽﾌﾟｱｽｴ ｳﾝｲﾌｲﾄﾞ |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ﾗｴﾝｱﾑｴ |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ﾗｴﾝｱﾑｴ |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ﾗｴﾝｱﾑｴ |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ﾗｴﾝｱﾑｴ |
| ﾏﾆｭｱﾙ `systemd.services.llama-cpp.serviceConfig` | ﾘﾑｰﾌﾞ | ﾎｱﾝﾄﾞﾙﾄﾞ ﾊﾞｲ NixKits ﾓｼﾞｭｰﾙ |
| `services.llama-cpp.extraFlags` | ｱﾄﾞ ﾌﾗｸﾞｽﾞ ﾄｩ `services.llama-cpp.settings` | ﾝｲｸｽﾌﾟｸｸﾞｽﾞ ﾗｴﾑｵﾌﾞｱﾙ |

### ﾑｲｸﾞﾗｱｼｮﾝ ｴｸﾞｻﾞﾝﾌﾟﾙ

> **⚠️ ｽﾃｯﾌﾟ 1**: ｱﾄﾞ `nix-kits.nixosModules.llama-cpp-rocm` ﾄｩ ｲｵｳﾗ ﾌﾚｲｸ ﾓｼﾞｭｰﾙ ﾘｽﾄ.

**ﾋﾞﾌｫｱ**:

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ — ﾓｼﾞｭｰﾙ ﾘｽﾄ
{ modules = [
    # ﾆｯｸｽ-ｸｲﾄｽﾞ.ﾝｲｸｽｵｽﾑｵﾄﾞｳﾙｽﾞ.ﾗﾏ-cpp-rocm  # ← ﾉｯﾄ ｲｴﾄ ｲﾑﾌﾟｵﾗﾄﾄﾞ
];}

# ﾗﾏ-cpp.ﾆｯｸｽ
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
  # ﾏﾆｭｱﾙ ｽｲｽﾄｴﾑﾄﾞ ｵﾌﾞｴﾗﾗｲﾄﾞｽﾞ
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

**ｱﾌﾀｰ**:

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ — ﾓｼﾞｭｰﾙ ﾘｽﾄ (ﾆｭｰ)
{ modules = [
    nix-kits.nixosModules.llama-cpp-rocm
];}

# ﾗﾏ-cpp.ﾆｯｸｽ
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
  # ｴｸｽﾄﾗｱ ｴﾇﾌﾞｲ ﾌﾞｱﾗｽﾞ ﾉｯﾄ ｸｵﾌﾞｴﾗﾄﾞ ﾊﾞｲ NixKits ｵﾌﾟｼｮﾝｽﾞ
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=/home/kix/.cache/huggingface/hub"
    "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
  ];
}
```