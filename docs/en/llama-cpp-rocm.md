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
                # Batching: the measured optimum. 512 -> 2048 raised prefill from
                # 142.7 to 168.7 t/s (costing only ~0.9 GiB VRAM). 4096 regressed
                # to 116.8.
                batch-size       = "2048";
                ubatch-size      = "2048";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                parallel         = "1";
                jinja            = "on";
                # The following are llama defaults, listed only to state a
                # position; they may be omitted: flash-attn (on), warmup (on),
                # fit (on). Never hard-code n-gpu-layers / load-mode — that
                # disables fit's automatic sizing.
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
| `fit` | `"on"` (default) | Auto-sizes unset arguments to device memory. **`"off"` OOMs on limited VRAM**. Do not hard-code `n-gpu-layers`, which disables that sizing |
| `jinja` | `"on"` | Applies the model's built-in chat template. **Disabling it produces degenerate output** |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache quantisation. **`iq4_nl` falls back to CPU (no ROCm kernel) and runs ~2.6× slower**; `f16` measured *slower* prefill (150.8 t/s) |
| `batch-size` | `"2048"` | Logical batch. **The measured optimum**: 512 → 2048 raised prefill 142.7 → 168.7 t/s (+18%); 4096 regressed to 116.8 |
| `ubatch-size` | `"2048"` | Physical batch, aligned with `batch-size` |
| `parallel` | `"1"` | Server slots; more slots multiply KV reservation |
| `threads` | `"32"` | CPU thread count, matching the core count |
| `warmup` | `"on"` (default) | One empty run after load, making the first real request faster |

> **Need not be set**: `flash-attn`, `warmup` and `fit` already default to the recommended values — writing them out only states a position. `presence-penalty`, `repeat-penalty` and `prio` showed no measured benefit; setting them to defaults is redundant.

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

## DeepSeek Deployment Measurements

Measured record of deploying DeepSeek-V4-Flash-Vision on Strix Halo (Ryzen AI Max, 128 GiB unified memory). Covers two quantisations: **IQ1_S (1.5625 bpw)** and **IQ3_S (3.4375 bpw)**.

### Test Subject

| Item | IQ1_S | IQ3_S |
|------|-------|-------|
| Model | `unsloth/DeepSeek-V4-Flash-Vision-Exp-GGUF:UD-IQ1_S` | `…:UD-IQ3_S` |
| Quantisation | 1.5625 bpw (82.4 GB) | **3.4375 bpw (114.4 GB)** |
| Parameters | 284 B total (MoE) | 284 B total (MoE) |
| Hardware | Strix Halo / Radeon 8060S (`gfx1151`, unified memory) | same as left |
| Backend | ROCm, llama.cpp 0.4.0 | same as left |

### Quantisation Overhead Is Not a Fixed Value

The estimate before loading IQ3_S was "a fixed overhead of about 3.7 GiB" — **the measurement was off by nearly an order of magnitude**:

| Quantisation | Weight files | GPUActive after load | Overhead beyond the weights |
|--------------|--------------|----------------------|------------------------------|
| IQ1_S | 82.4 GiB | ≈ 88.9 GiB | **≈ 6.5 GiB** |
| IQ3_S | 114.4 GiB | **112.8–112.9 GiB** | **≈ 13.3 GiB**† |

> † IQ3_S's weights are split across 4 shards, so the on-disk footprint is slightly smaller than
> the nominal figure; the overhead here is therefore computed as the difference between the
> *actual shard footprint* and GPUActive.

**Conclusion: never extrapolate overhead from a fixed constant.** Overhead varies with quantisation precision, the sharding scheme, the KV cache quantisation and `fit`'s automatic sizing. **After changing quantisation you must re-measure GPUActive**; the previous tier's figure does not carry over.

**IQ3_S headroom**: at GPUActive 112.8–112.94 GiB the system has only about 5.8–6 GiB left, against a GTT cap of 124.9 GiB. Measured 15013-token and 40012-token prefills did not OOM, with only 179 pages swapped out. **But the headroom is already tight**, so:

- do not raise `ubatch-size`
- do not add `parallel`
- do not change the KV cache to `f16`

### Optimisation Results

| Optimisation | Change | Gain | Cost |
|--------------|--------|------|------|
| **Batching** | `batch-size`/`ubatch-size` 512 → **2048** | prefill **142.7 → 168.7 t/s** (+18%) | +0.9 GiB VRAM |
| **KV quant** | kept `q4_0` (not `f16`) | prefill 168.7 vs 150.8, generation 12.8 vs 10.6 t/s | saves 5.2 GiB |
| **KV type** | dropped `iq4_nl` | avoids CPU fallback (5.54 → 14.14 t/s) | — |
| **Slots** | `parallel` auto(4) → **1** | per-slot KV reservation cut to ¼, loads at all | concurrency 1 |
| **Speculative** | `--spec-type ngram-mod` | generation **12.8 → 30.8 t/s** (+141%, content-dependent) | zero memory |

**Prefill detail** (11015 tokens, 3 runs each):

| Configuration | prompt t/s |
|---------------|-----------|
| batch512 / ubatch512 | 142.7 |
| batch2048 / ubatch1024 | 164.2 / 158.9 / 152.5 |
| **batch2048 / ubatch2048** | **168.7 / 162.4 / 154.0** |
| batch4096 / ubatch2048 | 156.4 / 157.3 / 151.9 |
| batch2048 + KV `f16` | 165.7 / 159.0 / 153.5 |

### Ruled Out

Measured and confirmed to give **no benefit** — no need to retry:

| Direction | Conclusion |
|-----------|-----------|
| GPU not saturated | `GPU use = 100%` during prefill; already at hardware compute ceiling |
| Missing ROCm target | `gfx1151` is in nixpkgs' `gpuTargets`; not a generic fallback |
| KV to `f16` | prefill degraded to 150.8 t/s *and* cost 5.2 GiB more |
| `cache-ram` | default 8192 is a **cap**, not preallocation; disabling it left GPUActive identical |
| Larger batching | `ubatch` 4096 regressed to 116.8 t/s |
| `draft-mtp` | model has no MTP layers (no `nextn` in the GGUF); unavailable |
| **Higher quantisation precision** | IQ1_S 1.56 bpw → IQ3_S 3.44 bpw, **no change in generation speed** (12.8 → 12.9 t/s) |
| **Higher GPU clock** | the performance profile costs 54% more power than balanced for only +2.4% generation |

### Generation Speed: the Bottleneck Is Dependency Latency

**Higher weight precision does not raise generation speed**: taking the weights from 1.56 bpw to 3.44 bpw (a 39% larger footprint) moved generation from 12.8 to 12.9 t/s — **within noise**. If the bottleneck were VRAM bandwidth, the precision increase should have slowed it down markedly.

**Concurrency does not raise aggregate throughput**: three concurrent requests still aggregate 12.5 t/s, the same as a single request — so the bottleneck is not throughput capacity.

**Clock barely affects generation**: the performance profile runs sclk 2778 MHz at 70.2 W for 12.9 t/s; balanced runs 2436 MHz at 45.6 W for 12.6 t/s. **54% more power buys only 2.4% more speed.**

All three lines of evidence point the same way: **generation is limited by per-token dependency latency**, not by bandwidth, compute or power. That is also why low-bit quantisation barely affects generation while affecting prefill markedly.

### Power Profile Measurements

Same prompt, same session, 400-token generation:

| Profile | Power | sclk | Temperature | Generation speed |
|---------|-------|------|-------------|------------------|
| quiet | **38.6–43.9 W** | 2228–2464 MHz | **59–78 °C** | 12.12–12.35 t/s |
| balanced | 55.1 W | 2586–2731 MHz | 87–93 °C | 12.84 t/s |
| performance | 76.7 W | 2753–2859 MHz | 90–95 °C | 13.07 t/s |

**quiet versus performance: −49% power, −17~36 °C, only −5~7% speed.**
Measured as throughput per watt, quiet is the most efficient of the three.

### Key Findings

**The two-sided nature of low-bit quantisation**: low bit-width helps **generation** (small weight bandwidth) but hurts **prefill** — every layer must dequantise weights, and prefill is compute-bound, so the dequantisation share rises as bit-width falls. Measured prefill is only 142–169 t/s against 12.8 t/s generation, a ratio of about 11–13× (healthy GPU values are usually 15–30×).

**So prefill is the main bottleneck for agentic use**: a 6k-token context costs ~35 s of warm-up, while generating 200 tokens takes only ~8 s.

> ⚠️ During testing, **always confirm `GPUActive` has returned to zero before starting the service**. This box fits only one large model instance at a time; a leftover process holds tens of GiB of unified memory and makes the service OOM in a way that masquerades as a configuration error.
>
> Note: the real VRAM metric is **`GPUActive`** in `/proc/meminfo`, **not** `mem_info_gtt_used` (the latter does not reflect actual usage on unified-memory devices).

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
      # ⚠️ Historical setting, now confirmed harmful: on unified-memory devices
      # such as StrixHalo it degenerates model output, and the risk rises as
      # quantisation precision drops. Remove it when migrating.
      # See the "Unified-Memory Environment Variable Degeneration Risk" section.
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
    hfCacheDir = "/home/kix/.cache/huggingface/hub";  # must be an absolute path:
    # it is injected via systemd Environment=LLAMA_CACHE, which does **not**
    # expand ~. Omit it and the default becomes ${users.users.<user>.home}/.cache/huggingface/hub.
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
