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
                # 批处理：实测最优点。512 → 2048 使 prefill 从 142.7 提升至
                # 168.7 t/s（代价仅约 0.9 GiB 显存）。4096 反而退化至 116.8。
                batch-size       = "2048";
                ubatch-size      = "2048";
                cache-type-k     = "q4_0";
                cache-type-v     = "q4_0";
                threads          = "32";
                parallel         = "1";
                jinja            = "on";
                # 以下为 llama 默认值，显式写出仅为表明立场，可按需省略：
                # flash-attn（默认 on）、warmup（默认 on）、fit（默认 on）。
                # 切勿写死 n-gpu-layers / load-mode：会让 fit 的自适应失效。
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
| `fit` | `"on"`（默认） | 按设备可用内存自动调整未设置的参数。**设 `"off"` 会在显存受限时直接 OOM**。不要写死 `n-gpu-layers`，否则自适应失效 |
| `jinja` | `"on"` | 应用模型内建 chat template。**关闭会导致输出退化乱码** |
| `cache-type-k` / `cache-type-v` | `"q4_0"` | KV cache 量化。**用 `iq4_nl` 会因缺 ROCm kernel 回退 CPU，速度降至约 1/2.6**；改 `f16` 实测 prefill 反降至 150.8 t/s |
| `batch-size` | `"2048"` | 逻辑批大小。**实测最优点**：512 → 2048 使 prefill 142.7 → 168.7 t/s（+18%）；4096 退化至 116.8 |
| `ubatch-size` | `"2048"` | 物理批大小，与 `batch-size` 对齐 |
| `parallel` | `"1"` | 服务槽位数。多槽位会按槽位倍增 KV 预留 |
| `threads` | `"32"` | CPU 线程数，与核心数一致 |
| `warmup` | `"on"`（默认） | 加载后空跑一次，令首次真实请求更快 |

> **不必设置的项**：`flash-attn`、`warmup`、`fit` 的默认值已是推荐值，显式写出仅表明立场；`presence-penalty`、`repeat-penalty`、`prio` 未实测出收益，写默认值属冗余。

### 禁用项

| 项 | 原因 |
|----|------|
| `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1` | **会导致模型输出退化**（重复 token、乱码）。同样的模型与预设，不加此变量的 CLI 或 server 均正常。详见下节 |
| `mmap` | 已弃用，改用 `load-mode` |
| `--no-mmproj` | 仅在 mmproj 与权重量化不匹配时作为临时规避；正常情况应保留以支持图片输入 |

### 统一内存环境变量的退化风险

在 StrixHalo 等统一内存（UMA）设备上，**不要设置 `GGML_CUDA_ENABLE_UNIFIED_MEMORY=1`**。该变量改变 GPU 显存分配路径（由独立显存改为统一内存寻址），在此类设备上会导致模型输出退化。

> ⚠️ **风险随模型量化精度降低而显著提升。** 低比特量化受影响最重 —— 量化越激进，权重数值分布越窄，对分配路径改变引入的噪声越敏感。

**退化表现**：token 重复（`We need need need…`、`The user user user…`）、语句崩坏、无法终止。

**实测对照**（Strix Halo / Ryzen AI Max，模型 `UD-IQ1_S` 1.5625 bpw）：

| 运行方式 | 是否设置该变量 | 输出结果 |
|---------|--------------|---------|
| systemd 服务 | ✅ 设置 | ❌ **退化**（重复 token） |
| 手动启动 server（同一 ini/模型） | ❌ 未设置 | ✅ 正常 |
| `llama-cli`（同一 ini/模型） | ❌ 未设置 | ✅ 正常 |
| 手动启动 server | ✅ 设置 | ❌ **复现退化** |

后两行构成关键证据：**同一模型、同一预设、同一配置文件下，唯一变量即为该环境变量**，且可双向复现。

**为何容易被误判**：`llama-cli` 默认 `--fit on`、`--n-gpu-layers auto`，而服务预设若显式设置 `fit off` 会 OOM；两者症状（输出异常 vs 加载失败）容易与量化、模板（`jinja`）等相关因素混淆。诊断时应**优先排除该环境变量**，再怀疑量化与模板。

## DeepSeek 部署实测

在 Strix Halo（Ryzen AI Max，128 GiB 统一内存）上部署 DeepSeek-V4-Flash-Vision 的实测记录。当前仅覆盖 **IQ1 量化**（1.5625 bpw）。

### 测试对象

| 项目 | 值 |
|------|-----|
| 模型 | `unsloth/DeepSeek-V4-Flash-Vision-Exp-GGUF:UD-IQ1_S` |
| 量化 | IQ1_S，**1.5625 bpw**（82.4 GB） |
| 参数 | 总 284 B（MoE） |
| 硬件 | Strix Halo / Radeon 8060S（`gfx1151`，统一内存） |
| 后端 | ROCm，llama.cpp 0.4.0 |

### 优化成果

| 优化项 | 改动 | 收益 | 成本 |
|--------|------|------|------|
| **批处理** | `batch-size`/`ubatch-size` 512 → **2048** | prefill **142.7 → 168.7 t/s**（+18%） | +0.9 GiB 显存 |
| **KV 量化** | 保持 `q4_0`（未改 `f16`） | prefill 168.7 vs 150.8、生成 12.8 vs 10.6 t/s | 省 5.2 GiB |
| **KV 类型** | 弃用 `iq4_nl` | 避免回退 CPU（5.54 → 14.14 t/s） | — |
| **槽位数** | `parallel` auto(4) → **1** | 单槽 KV 预留降至 1/4，可载入 | 并发降为 1 |
| **投机解码** | `--spec-type ngram-mod` | 生成 **12.8 → 30.8 t/s**（+141%，内容相关） | 零内存 |

**prefill 实测明细**（11015 token，各 3 次）：

| 配置 | prompt t/s |
|------|-----------|
| batch512 / ubatch512 | 142.7 |
| batch2048 / ubatch1024 | 164.2 / 158.9 / 152.5 |
| **batch2048 / ubatch2048** | **168.7 / 162.4 / 154.0** |
| batch4096 / ubatch2048 | 156.4 / 157.3 / 151.9 |
| batch2048 + KV `f16` | 165.7 / 159.0 / 153.5 |

### 已排除的方向

以下经实测确认**无收益**，不必再试：

| 方向 | 结论 |
|------|------|
| GPU 未满载 | prefill 时 `GPU use = 100%`，已到硬件算力上限 |
| ROCm 目标缺失 | `gfx1151` 在 nixpkgs `gpuTargets` 内，非通用回退 |
| KV 改 `f16` | prefill 反降至 150.8 t/s，且多耗 5.2 GiB |
| `cache-ram` | 默认 8192 是**上限**非预分配；禁用后 GPUActive 完全相同 |
| 更大批处理 | `ubatch` 4096 退化至 116.8 t/s |
| `draft-mtp` 投机 | 模型无 MTP 层（GGUF 无 `nextn`），不可用 |

### 关键结论

**1.56 bpw 极低量化的双面性**：低比特对**生成**有利（权重带宽小），但对 **prefill** 不利 —— 每层需反量化权重，而 prefill 是计算密集阶段，反量化算力占比随位宽降低而升高。实测 prefill 仅 142–169 t/s，而生成 12.8 t/s，比值约 11–13×（GPU 上健康值通常 15–30×）。

**因此 prefill 是 agentic 场景的主要瓶颈**：一轮 6k token 上下文需约 35 秒预热，而生成 200 token 仅需约 8 秒。

> ⚠️ 测试期间**务必确认 `GPUActive` 归零后再启动服务**。本机一次只能驻留一个大模型实例；遗留进程会占据数十 GiB 统一内存，导致服务 OOM 并伪装成配置错误。

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
      # ⚠️ 此变量为历史配置，现已确认有害：在 StrixHalo 等统一内存设备上会
      # 导致模型输出退化，且风险随量化精度降低而提升。迁移后务必移除。
      # 详见「统一内存环境变量的退化风险」节。
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
