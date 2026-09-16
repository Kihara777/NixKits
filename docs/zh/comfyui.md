# comfyui

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/comfyui.md) | [日本語](../ja/comfyui.md)  | [偽中国語](../pcn/comfyui.md)

为 ComfyUI 提供 ROCm 功能补丁。

含 **Strix Halo（gfx1151 / RDNA 3.5 APU）专属优化**，已在 Ryzen AI MAX+ 395 / Radeon 8060S 上实测验证。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | 纯 NixOS 模块（**不再附带补丁**） |
| 选项 | `nixkits.comfyui.enable` |
| 位置 | `modules/comfyui.nix` |
| 适用 GPU | gfx1151（Strix Halo）— ROCm 7.1 原生识别 |

## 功能

- **rocmGfxOverride 选项**：声明 `services.comfyui.rocmGfxOverride`，设置 `HSA_OVERRIDE_GFX_VERSION`
- **xformers 自动禁用**：`--disable-xformers`（nixpkgs 的 xformers 不含 ROCm 后端）
- **C 编译工具链**：PATH 注入 `gcc`、`binutils`、`gnumake`，设置 `CC=gcc`
- **ROCm 运行时自动安装**：`hardware.graphics.extraPackages`（clr + rocminfo）
- **Strix Halo 内核参数**：`amdgpu.gttsize=131072`
- **服务加固**：GPU 设备访问权限（`/dev/kfd`、`/dev/dri/renderD128`）

## 关于上游兼容性（2026-09-15 清理）

本模块**曾附带三个补丁，现已全部移除**：

| 已移除的补丁 | 移除原因 |
|--------------|----------|
| `comfyui-nix-strix-halo` | 上游已自带等效的 ROCm 7.1 / PyTorch 2.10.0 wheels（版本、URL、hash 完全一致） |
| `comfyui-nix-stdenv-api` | 上游已自行迁移到 `stdenv.hostPlatform.*`（旧写法 0 处） |
| `comfyui-nix-nixpkgs-compat` | 此前判定为"仍可能需要"，**该判定已被推翻** —— 详见下方警示 |

> ⚠️ **`nixpkgs-compat` 的判定曾出错，值得引以为戒。**
> 初次评估的"完整构建验证"（717 derivation 全成功）中，`scipy` 其实是
> **缓存命中、从未真正构建**；升级后立即因 `test_support_moments_sample`
> 浮点断言失败 —— 当时误以为这正是该补丁要跳过的测试。
>
> **真因是本地遗留的一个多余 pin**：本机把 `comfyui-nix` 的
> `inputs.nixpkgs` 钉死在旧 rev，而顶层走滚动 `nixos-unstable`。
> 顶层命中公共缓存，被钉住的子 flake 则需现建 —— 于是"缓存本可解决的
> 问题"看起来像"需要打补丁"。**删掉那行 pin 后构建全绿，无需任何补丁。**
>
> **教训一：构建验证必须确认目标 derivation 真的被构建。** 日志中出现
> `building '…'` 才算数；"构建成功"无法区分"构建通过"与"无需构建"。
>
> **教训二：额外的 `inputs.*` pin 会让子 flake 失去主 nixpkgs 的缓存覆盖。**
> 加 pin 前先问它解决了什么；问题消失后记得删。

**完整记录见 [`deprecated/comfyui-rocm.md`](deprecated/comfyui-rocm.md)**
（索引：[`DEPRECATED.md`](../../DEPRECATED.md)）。

> **不再需要 fork**：此前建议"fork comfyui-nix 并应用补丁"，现已无必要 ——
> 直接把 `comfyui-nix` input 指向上游即可。
>
> ⚠️ 同时移除了一个给 `pkgs.comfyui` 打补丁的 overlay。它的作用已被上游
> `disabledModules` + 自带 package 取代；若保留，会因补丁文件不存在而
> **在构建期失败**（求值期不报错，故不易察觉）。

## 使用

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
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
        nixkits.nixosModules.comfyui
        {
          nixkits.comfyui.enable = true;
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
