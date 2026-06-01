# llama-cpp-rocm

[中文](../zh/llama-cpp-rocm.md) | [English](llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)

Upstream [llama.cpp](https://github.com/ggml-org/llama.cpp) with ROCm GPU acceleration. Dynamically fetches the latest GitHub Release version at build time for testing cutting-edge features.

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
              "*" = {
                n-gpu-layers = "99";
                flash-attn = "on";
              };
              "Qwen3.6-27B-MTP" = {
                hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
                temp = "0.6";
                ctx-size = "1048576";
              };
            };
          };
        }
      ];
    };
  };
}
```

The module auto-sets `LLAMA_CACHE` to `/home/<user>/.cache/huggingface/hub` and lifts `/home` and `/proc` sandbox restrictions.

> **Warning: Home Manager llama-cpp service**
>
> If enabled via Home Manager, additional user-level sandboxing may prevent GPU access (`/dev/dri`, `/dev/kfd`). Prefer system-level configuration.
