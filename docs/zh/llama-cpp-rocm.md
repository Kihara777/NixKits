# llama-cpp-rocm

中文 | [English](../en/llama-cpp-rocm.md) | [日本語](../ja/llama-cpp-rocm.md)  | [偽中国語](../pcn/llama-cpp-rocm.md)

基于 llama.cpp 上游，构建时动态获取 GitHub 最新 Release 版本号，启用 ROCm GPU 加速，用于测试最新特性和前沿功能。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 自动追踪上游最新 Release |
| 上游 | [ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) |
| 注意 | 此包仅以 overlay 形式提供，无独立 package 输出 |

## 引用

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.llama-cpp-rocm ];
  environment.systemPackages = [ pkgs.llama-cpp-rocm ];
}
```

## 使用

参考上游 llama.cpp 文档。

## flake 模块

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

模块自动将 `LLAMA_CACHE` 指向 `~/.cache/huggingface/hub`，解除 `/home` 和 `/proc` 访问限制。

> **⚠️ 警告：Home Manager 中的 llama-cpp 服务**
>
> 如果在 Home Manager 中启用 `services.llama-cpp`，其额外的用户级沙箱机制可能导致服务无法访问 GPU 硬件（`/dev/dri`、`/dev/kfd`）。建议在 NixOS 系统级别配置此服务。

## 模型说明

`modelsPreset` 支持多个模型，服务启动时按需加载。全局预设 `"*"` 应用于所有模型，单个模型可覆盖特定参数。`hf-repo` 自动从 HuggingFace 下载 GGUF 格式模型文件。

> **注意**：`modelsPreset` 的值必须是**字符串**（`attrsOf (attrsOf str)`）。布尔开关写成 `"on"` / `"off"`，不要写 `true` / `false`。

## 参数详解

以下参数经实测验证，说明基于 Strix Halo（统一内存架构）上的 llama.cpp 0.4.0。

| 参数 | 推荐值 | 说明 |
|------|--------|------|
| `fit` | `"on"` | 按设备可用内存自动调整未设置的参数。**设 `"off"` 会在显存受限时直接 OOM** |
| `jinja` | `"on"` | 应用模型内建 chat template。**关闭会导致输出退化乱码** |
| `load-mode` | `"none"` | 取代已弃用的 `mmap`；`"none"` 等价于旧 `--no-mmap` |
| `n-gpu-layers` | `"99"` | 将全部层卸载到 GPU |
| `flash-attn` | `"on"` | 启用 Flash Attention，降低注意力显存占用 |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache 量化。**用 `iq4_nl` 会因缺 ROCm kernel 回退 CPU，速度降至约 1/2.6** |
| `threads` | `"32"` | CPU 线程数 |
| `parallel` | `"1"` | 服务槽位数。多槽位会按槽位倍增 KV 预留 |
| `batch-size` | `"512"` | 逻辑批大小，与 `ubatch-size` 默认值对齐以缩小计算缓冲 |
| `warmup` | `"on"` | 加载后空跑一次，令首次真实请求更快 |

### 禁用项

| 项 | 原因 |
|----|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **会导致模型输出退化**（重复 token、乱码）。同样的模型与预设，不加此变量的 CLI 或 server 均正常 |
| `mmap` | 已弃用，改用 `load-mode` |
| `--no-mmproj` | 仅在 mmproj 与权重量化不匹配时作为临时规避；正常情况应保留以支持图片输入 |

## 迁移指南

### 受影响版本

| 组件 | 受影响版本 | 变更内容 |
|------|-----------|---------|
| nixpkgs | ≥ 2026-06（master） | `services.llama-cpp.modelsPreset` 移除，`port`/`host`/`model`/`modelsDir` 重命名为 `settings.port`/`settings.host`/… |
| NixKits | ≥ `6f52ddf`（`modules/llama-cpp-rocm.nix`） | 命名空间从 `services.llama-cpp-rocm` 迁移到 `nixkits.llama-cpp-rocm` |
| 上游 llama.cpp | b9605 | `--models-preset` CLI 参数保留（底層能力未变） |

### 配置项目对照

| 旧配置（已废弃） | 新配置 | 说明 |
|-----------------|--------|------|
| `services.llama-cpp.modelsPreset` | `nixkits.llama-cpp-rocm.modelsPreset` | `modelsPreset` 从 nixpkgs 移除，改为 NixKits 提供 |
| `services.llama-cpp-rocm.enable` | `nixkits.llama-cpp-rocm.enable` | 命名空间统一 |
| `services.llama-cpp-rocm.user` | `nixkits.llama-cpp-rocm.user` | 同上 |
| `services.llama-cpp-rocm.group` | `nixkits.llama-cpp-rocm.group` | 同上 |
| `services.llama-cpp.port` | `services.llama-cpp.settings.port` | nixpkgs 重命名 |
| `services.llama-cpp.host` | `services.llama-cpp.settings.host` | nixpkgs 重命名 |
| `services.llama-cpp.model` | `services.llama-cpp.settings.model` | nixpkgs 重命名 |
| `services.llama-cpp.modelsDir` | `services.llama-cpp.settings.models-dir` | nixpkgs 重命名 |
| 手动 `systemd.services.llama-cpp.serviceConfig` | 删除 | NixKits 模块自动处理 DynamicUser/PrivateUsers/ProtectHome/ProcSubset |
| `services.llama-cpp.extraFlags` | `services.llama-cpp.settings` 中添加对应 flag | nixpkgs 移除 |

### 迁移示例

> **⚠️ 第 1 步**：在 `flake.nix` 模块列表中添加 `nixkits.nixosModules.llama-cpp-rocm`

**迁移前**：

```nix
# flake.nix — 模块列表
{ modules = [
    # nixkits.nixosModules.llama-cpp-rocm  # ← 尚未导入
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
  # 手动 systemd 配置
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

**迁移后**：

```nix
# flake.nix — 模块列表（新增）
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
  # NixKits 模块未覆盖的环境变量
  systemd.services.llama-cpp.serviceConfig.Environment = lib.mkForce [
    "LLAMA_CACHE=~/.cache/huggingface/hub"
  ];
}
```
