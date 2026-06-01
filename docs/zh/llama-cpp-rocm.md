# llama-cpp-rocm

[中文](llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)

基于 [llama.cpp](https://github.com/ggml-org/llama.cpp) 上游，构建时动态获取 GitHub 最新 Release 版本号，启用 ROCm GPU 加速，用于测试最新特性和前沿功能。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 自动追踪上游最新 Release |
| 上游 | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | 此包仅以 overlay 形式提供，无独立 package 输出 |

## 引用

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使用

```bash
llama-server -m model.gguf --gpu-device 0
llama-cli -m model.gguf -p "Hello" --gpu-device 0
```

## flake 模块

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

模块自动将 `LLAMA_CACHE` 指向 `/home/<user>/.cache/huggingface/hub`，解除 `/home` 和 `/proc` 访问限制。

> **⚠️ 警告：Home Manager 中的 llama-cpp 服务**
>
> 如果在 Home Manager 中启用 `services.llama-cpp`，其额外的用户级沙箱机制可能导致服务无法访问 GPU 硬件（`/dev/dri`、`/dev/kfd`）。建议在 NixOS 系统级别配置此服务。

## 模型说明

`modelsPreset` 支持多个模型，服务启动时按需加载。全局预设 `"*"` 应用于所有模型，单个模型可覆盖特定参数。`hf-repo` 自动从 HuggingFace 下载 GGUF 格式模型文件。
