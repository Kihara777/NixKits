# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | English | [日本語](../ja/llama-cpp-rocm.md)  | [偽中国語](../pcn/llama-cpp-rocm.md)

Upstream llama.cpp with ROCm GPU acceleration. Dynamically fetches the latest GitHub Release version at build time for testing cutting-edge features.

## Info

| Item | Value |
|------|-------|
| Version | Auto-tracks upstream |
| Upstream | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| Note | Overlay-only, no standalone package output |

## Install

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## Usage

See upstream llama.cpp docs.

## Flake Module

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

The module auto-sets `LLAMA_CACHE` to `~/.cache/huggingface/hub` and lifts `/home` and `/proc` sandbox restrictions.

> **Warning: Home Manager llama-cpp service**
>
> If enabled via Home Manager, additional user-level sandboxing may prevent GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-level configuration.

## Model Notes

`modelsPreset` holds multiple models, loaded on demand when the service starts. The global `"*"` preset applies to every model, and a per-model entry can override specific parameters. `hf-repo` downloads GGUF model files from HuggingFace automatically.

## Parameter Reference

Parameters below are verified on Strix Halo (unified memory) with llama.cpp 0.4.0.

| Parameter | Recommended | Notes |
|-----------|-------------|-------|
| `fit` | `"on"` | Auto-sizes unset arguments to device memory. **`"off"` OOMs on limited VRAM** |
| `jinja` | `"on"` | Applies the model's built-in chat template. **Disabling it produces degenerate output** |
| `load-mode` | `"none"` | Replaces the deprecated `mmap`; `"none"` equals the old `--no-mmap` |
| `n-gpu-layers` | `"99"` | Offload every layer to the GPU |
| `flash-attn` | `"on"` | Enables Flash Attention, lowering attention memory |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache quantisation. **`iq4_nl` falls back to CPU (no ROCm kernel) and runs ~2.6× slower** |
| `threads` | `"32"` | CPU thread count |
| `parallel` | `"1"` | Server slots; more slots multiply KV reservation |
| `batch-size` | `"512"` | Logical batch, matched to the default `ubatch-size` to shrink compute buffers |
| `warmup` | `"on"` | One empty run after load, making the first real request faster |

> **Note**: `modelsPreset` values must be **strings** (`attrsOf (attrsOf str)`). Write `"on"` / `"off"`, not `true` / `false`.

### Avoid

| Item | Reason |
|------|--------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **Corrupts model output** (repeated tokens, garbage). The same model and preset answer correctly without it. See the next section |
| `mmap` | Deprecated; use `load-mode` |
| `--no-mmproj` | Only a workaround when mmproj mismatches the quantisation; keep it for image input |

### Unified-Memory Environment Variable Degeneration Risk

On unified-memory (UMA) devices such as StrixHalo, **do not set `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1`**. The variable changes the GPU memory allocation path (from dedicated VRAM to unified-memory addressing) and degenerates model output on such hardware.

> ⚠️ **The risk rises significantly as model quantisation precision drops.** Low-bit quants are affected worst — the more aggressive the quantisation, the narrower the weight distribution and the more sensitive it becomes to the noise this allocation change introduces.

**Symptoms**: token repetition (`We need need need…`, `The user user user…`), broken sentences, failure to terminate.

**Measured comparison** (Strix Halo / Ryzen AI Max, model `UD-IQ1_S` 1.5625 bpw):

| Launch method | Variable set | Result |
|---------------|-------------|--------|
| systemd service | ✅ yes | ❌ **degenerate** (repeated tokens) |
| Hand-started server (same ini/model) | ❌ no | ✅ correct |
| `llama-cli` (same ini/model) | ❌ no | ✅ correct |
| Hand-started server | ✅ yes | ❌ **degeneration reproduced** |

The last two rows are the key evidence: with the **same model, same preset and same config file**, the only variable is this environment variable, and it reproduces in both directions.

**Why it is easily misdiagnosed**: `llama-cli` defaults to `--fit on` and `--n-gpu-layers auto`, while a preset that sets `fit off` will OOM instead; the two symptoms (bad output vs. failed load) are easy to confuse with quantisation or template (`jinja`) issues. **Rule this variable out first**, before suspecting quantisation or templates.

## Migration Guide

### Affected Versions

| Component | Affected | Change |
|-----------|----------|--------|
| nixpkgs | ≥ 2026-06 (master) | `services.llama-cpp.modelsPreset` removed; `port`/`host`/`model`/`modelsDir` renamed to `settings.port`/`settings.host`/… |
| NixKits | ≥ `6f52ddf` (`modules/llama-cpp-rocm.nix`) | Namespace: `services.llama-cpp-rocm` → `nixkits.llama-cpp-rocm` |
| Upstream llama.cpp | b9605 | `--models-preset` CLI argument retained |

### Config Key Mapping

| Old (deprecated) | New | Notes |
|------------------|-----|-------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | Removed from nixpkgs, restored via NixKits |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | Namespace unified |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | Namespace unified |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | Namespace unified |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs rename |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs rename |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs rename |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs rename |
| Manual `systemd.services.llama-cpp.serviceConfig` | Remove | Handled by NixKits module |
| `services.llama-cpp.extraFlags` | Add flags to `services.llama-cpp.settings` | nixpkgs removal |

### Migration Example

> **⚠️ Step 1**: Add `nixkits.nixosModules.llama-cpp-rocm` to your flake module list.

**Before**:

```nix
# flake.nix — module list
{ modules = [
    # nixkits.nixosModules.llama-cpp-rocm  # ← not yet imported
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
      "LLAMA_CACHE=~/.cache/huggingface/hub"
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
  # Extra env vars not covered by NixKits options
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=~/.cache/huggingface/hub"
  ];
}
```
