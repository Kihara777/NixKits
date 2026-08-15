# comfyui-rocm

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui-rocm%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui-rocm%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/comfyui-rocm.md) | [日本語](../ja/comfyui-rocm.md)  | [偽中国語](../pcn/comfyui-rocm.md)

为 ComfyUI 提供 ROCm 功能补丁。

含 **Strix Halo（gfx1151 / RDNA 3.5 APU）专属优化**，已在 Ryzen AI MAX+ 395 / Radeon 8060S 上实测验证。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | overlay + NixOS 模块 |
| 选项 | `nixkits.comfyui-rocm.enable` |
| 位置 | `modules/comfyui-rocm.nix` + `patches/comfyui-nix-strix-halo.patch` + `patches/comfyui-nix-nixpkgs-compat.patch` |
| 适用 GPU | gfx1151（Strix Halo）— ROCm 7.1 原生识别 |

## 功能

- **rocmGfxOverride 选项**：声明 `services.comfyui.rocmGfxOverride`，设置 `HSA_OVERRIDE_GFX_VERSION`
- **xformers 自动禁用**：`--disable-xformers`（nixpkgs 的 xformers 不含 ROCm 后端）
- **C 编译工具链**：PATH 注入 `gcc`、`binutils`、`gnumake`，设置 `CC=gcc`
- **ROCm 运行时自动安装**：`hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo 内核参数**：`amdgpu.gttsize=131072`
- **服务加固**：GPU 设备访问权限（`/dev/kfd`、`/dev/dri/renderD128`）
- **PyTorch 7.2 wheel 可选升级**

## 兼容性补丁（nixpkgs ≥ 2026-08-05）

配套补丁 `patches/comfyui-nix-nixpkgs-compat.patch` 解决 nixpkgs 漂移导致的构建失败：

- **`pythonRuntimeDepsCheckHook`**：vendored wheel 的 METADATA 声明的运行时依赖由 comfyui pythonRuntime 提供，构建时检查会失败 → mkWheel 加 `dontCheckRuntimeDeps = true`
- **flaky 测试**：jupyter-server / scipy / fastapi / einops 等测试在沙箱中失败 → `doInstallCheck = false`（pytestCheckHook 跑在 installCheckPhase，`doCheck = false` 无效）

使用 nixpkgs ≥ 2026-08-05 时需应用此补丁。

## 使用

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui-rocm ];

  nixkits.comfyui-rocm.enable = true;
  services.comfyui = {
    enable = true;
    rocmGfxOverride = "11.0.0";  # 可选：自定义 GPU 目标版本
  };
}
```

## 安装（在线集成模式）

直接使用上游 flake，由本地模块补丁覆盖（推荐）：

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # 在线版，无需 fork
    nixkits.url = "github:Kihara777/NixKits";
  };

  outputs = { nixkits, comfyui-nix, ... }:
    nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nixkits.nixosModules.comfyui-rocm
        {
          nixkits.comfyui-rocm.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
}
```

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。

> ⚠️ 本条目为 overlay，修改上游 nixpkgs 包而非独立构建，不在二进制缓存中。

## 注意

- ROCm 7.1 已可原生识别 gfx1151，无需 `HSA_OVERRIDE_GFX_VERSION`
- GPU 未识别时可尝试 `services.comfyui.rocmGfxOverride = "11.0.0"`
- xformers 报错时：模块已自动 `--disable-xformers`
- 模块自动设置 `amdgpu.gttsize=131072`（适配 Strix Halo 统一内存架构）
- C 工具链注入后，ComfyUI Manager 可在线编译自定义节点依赖
