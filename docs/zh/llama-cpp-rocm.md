# llama-cpp-rocm

[中文](llama-cpp-rocm.md) | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)

基于 [llama.cpp](https://github.com/ggml-org/llama.cpp) 上游，启用 ROCm GPU 加速。版本自动追踪上游最新 Release。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `llama-cpp` |
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

## 系统服务

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
        cache-type-k = "q4_0";
        cache-type-v = "q4_0";
      };
      "Qwen3.6-27B-MTP" = {
        hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
        alias = "Qwen3.6-27B-MTP";
        temp = "0.6";
        ctx-size = "1048576";
      };
    };
  };

  # 修改默认 systemd 服务以支持用户目录下的模型缓存
  systemd.services.llama-cpp.serviceConfig = {
    DynamicUser  = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    ProtectHome  = lib.mkForce false;    # 允许访问 /home 下的模型目录
    ProcSubset   = lib.mkForce "all";     # 避免 journalctl 内存信息受限提示
    User  = lib.mkForce "kix";
    Group = lib.mkForce "users";
    Environment = lib.mkForce [
      "LLAMA_CACHE=${hfCache}"            # HuggingFace 缓存路径
      "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
    ];
  };
}
```

> **⚠️ 警告：Home Manager 中的 llama-cpp 服务**
>
> 如果在 Home Manager 中启用 `services.llama-cpp`，其额外的用户级沙箱机制可能导致服务无法访问 GPU 硬件（`/dev/dri`、`/dev/kfd`）。建议在 NixOS 系统级别配置此服务。

## 模型说明

`modelsPreset` 支持多个模型，服务启动时按需加载。全局预设 `"*"` 应用于所有模型，单个模型可覆盖特定参数。`hf-repo` 自动从 HuggingFace 下载 GGUF 格式模型文件。
