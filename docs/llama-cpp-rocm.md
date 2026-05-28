# llama-cpp-rocm

基于 [llama.cpp](https://github.com/ggml-org/llama.cpp) 上游，启用 ROCm GPU 加速。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 自动追踪上游最新 Release |
| 上游 | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |

## 引用

```nix
# Overlay → pkgs.llama-cpp-rocm
nixpkgs.overlays = [ inputs.nix-kits.overlays.llama-cpp-rocm ];
environment.systemPackages = [ pkgs.llama-cpp-rocm ];
```

## 使用

```bash
llama-server -m model.gguf --gpu-device 0
```
