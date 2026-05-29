# llama-cpp-rocm

基于 [llama.cpp](https://github.com/ggml-org/llama.cpp) 上游，启用 ROCm GPU 加速。版本自动追踪上游最新 Release。

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

## systemd 服务

```nix
services.llama-cpp = {
  enable = true;
  package = pkgs.llama-cpp-rocm;
  port = 2027;
  modelsPreset = {
    "my-model" = {
      hf-repo = "unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL";
      n-gpu-layers = "99";
      ctx-size = "1048576";
      flash-attn = "on";
    };
  };
};
```
