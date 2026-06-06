# ComfyUI Strix Halo 补丁

[中文](comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md)

为 AMD Strix Halo（gfx1151 / RDNA 3.5 APU）提供 ComfyUI ROCm 加速支持。
已在 **Ryzen AI MAX+ 395 / Radeon 8060S** 上实测验证通过。

## 背景

Strix Halo（Ryzen AI MAX+ 395 / Radeon 8060S 等）的 GPU 架构为 gfx1151。
截至 ROCm 7.1，gfx1151 **不在官方支持矩阵内**；ROCm 7.2 开始提供初步原生支持。

本补丁对 [comfyui-nix](https://github.com/utensils/comfyui-nix) 做了四处修改：

| 文件 | 变更 |
|------|------|
| `nix/versions.nix` | 新增 ROCm 7.2 stable wheel 定义（torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0） |
| `nix/python-overrides.nix` | ROCm 版本自动选择：存在 rocm72 定义时优先使用 7.2，回退至 7.1 |
| `nix/modules/comfyui.nix` | 新增 `rocmGfxOverride` 选项 + ROCm 模式下自动 `--disable-xformers` |

## 已验证

| 项目 | 结果 |
|------|------|
| 硬件 | Ryzen AI MAX+ 395 / Radeon 8060S（128 GB VRAM） |
| GPU 识别 | **AMD Radeon 8060S : native**（无需 HSA_OVERRIDE_GFX_VERSION） |
| torch 版本 | 2.12.0+rocm7.2 |
| 生成测试 | Z-Image 1024×1024, 10 steps — 成功（2.0 MB PNG） |

## 使用方式

### 方式 A：NixOS 模块（推荐）

应用补丁后，启用 NixKits 模块即可：

```nix
# flake.nix
{
  inputs = {
    nix-kits.url = "github:Kihara777/NixKits";
    # 使用已应用补丁的 comfyui-nix（本地 clone 或 fork）：
    comfyui-nix.url = "/path/to/patched-comfyui-nix";
  };

  outputs = { nix-kits, comfyui-nix, ... }: {
    nixosConfigurations.xxx = nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nix-kits.nixosModules.comfyui-strix-halo
        {
          nixkits.comfyui-strix-halo.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
  };
}
```

模块启用后自动：
- 配置 `hardware.graphics`（ROCm 运行时库）
- 设置 `gpuSupport = "rocm"`
- 注入 Strix Halo 内核参数（`amdgpu.gttsize=131072`）
- 选项性地设置 `HSA_OVERRIDE_GFX_VERSION`

### 方式 B：手动应用 Patch

```bash
cd comfyui-nix
patch -p1 < /path/to/NixKits/patches/comfyui-nix-strix-halo.patch
```

然后在系统配置中：

```nix
inputs.comfyui-nix.url = "/path/to/patched-comfyui-nix";
services.comfyui.gpuSupport = "rocm";
```

补丁已内置 ROCm 模式自动 `--disable-xformers`，无需手动配置。

### rocmGfxOverride 选项

模块默认 **不设置** `HSA_OVERRIDE_GFX_VERSION`。ROCm 7.2 已原生支持 gfx1151，
实测无需此选项。如果将来遇到 GPU 未被识别的情况，可启用覆盖：

```nix
services.comfyui.rocmGfxOverride = "11.0.0";  # 使用 gfx1100 兼容路径
```

| 值 | 对应架构 | 说明 |
|----|---------|------|
| `"11.0.0"` | gfx1100（RDNA 3） | gfx1151 最佳兼容选择 |
| `"11.5.1"` | gfx1151（RDNA 3.5） | 原生架构 |

## 故障排除

### GPU 未被 PyTorch 识别

症状：启动日志出现 `Torch not compiled with ROCm enabled` 或 `No GPU detected`。

1. 确认 `/dev/kfd` 和 `/dev/dri/renderD128` 存在
2. 检查 `rocminfo` 输出（需安装 `rocmPackages.rocminfo`）
3. 尝试设置 `rocmGfxOverride = "11.0.0"`

### xformers 报错

症状：`NotImplementedError: No operator found for memory_efficient_attention_forward`

补丁已在 ROCm 模式下自动添加 `--disable-xformers`。如果手动启动 ComfyUI 而未使用模块，请自行添加此参数。

### ROCm 运行时缺失

```
rocminfo: command not found
libamdhip64.so: cannot open shared object file
```

启用 NixKits 模块后会自动配置 `hardware.graphics.extraPackages`。
手动配置：

```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    rocmPackages.clr
    rocmPackages.rocminfo
  ];
};
```

## 技术细节

### 架构支持状态

| ROCm 版本 | gfx1151 状态 |
|-----------|-------------|
| 7.1 | 预览支持，需 `HSA_OVERRIDE_GFX_VERSION` |
| 7.2 | 原生支持 — 本补丁默认，已实测验证 |

### HSA_OVERRIDE_GFX_VERSION 原理

ROCm 运行时按 GPU 架构选择预编译内核。如果 gfx1151 的内核不可用，
`HSA_OVERRIDE_GFX_VERSION=11.0.0` 强制运行时加载 gfx1100（RDNA 3）内核。
两者二进制兼容。ROCm 7.2 + PyTorch 2.12.0 已原生包含 gfx1151 内核，无需覆盖。

### xformers 说明

nixpkgs 的 `xformers` 包仅含 CUDA 后端，缺少 ROCm 支持。
补丁在 ROCm 模式下自动添加 `--disable-xformers`，回退至 PyTorch 原生 attention，
后者在 ROCm 上效率相当。

### Strix Halo 内核参数

Strix Halo 使用统一内存架构（UMA），建议：

```
amdgpu.gttsize=131072  # 128GB GTT，适配大模型
```

NixKits 模块启用时自动配置。

## 参考

- [ROCm 兼容性矩阵](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- [ROCm RDNA 3.5 优化指南](https://rocm.docs.amd.com/en/latest/how-to/system-optimization/rdna3-5.html)
- [PyTorch ROCm 7.2 wheels](https://download.pytorch.org/whl/rocm7.2/)
- [ROCm/ROCm Issue #5339 — gfx1151 支持讨论](https://github.com/ROCm/ROCm/issues/5339)
