# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)

Upstream [llama.cpp](https://github.com/ggml-org/llama.cpp) with ROCm GPU acceleration. Version auto-tracks latest Release.

## Info

| Item | Value |
|------|-------|
| Version | Auto-tracks upstream |
| Upstream | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| Note | Overlay-only, no standalone package output |

## Install

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## Usage

```bash
llama-server -m model.gguf --gpu-device 0
llama-cli -m model.gguf -p "Hello" --gpu-device 0
```

## System Service

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

  # Override defaults for user-directory model cache access
  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser  = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome  = lib.mkForce false;    # allow model files in /home
    ProcSubset   = lib.mkForce "all";     # suppress /proc access warnings
    User  = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=${hfCache}"
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
  };
}
```

> **Warning: Home Manager llama-cpp service**
>
> If enabled via Home Manager, additional user-level sandboxing may prevent GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-level configuration.
