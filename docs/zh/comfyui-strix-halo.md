# comfyui-strix-halo

[中文](comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md) | [日本語](../ja/comfyui-strix-halo.md) | [ｶﾀﾘｯｼｭ](../katalish/comfyui-strix-halo.md) | [偽中国語](../pcn/comfyui-strix-halo.md)

为 AMD Strix Halo（gfx1151 / RDNA 3.5 APU）提供 ComfyUI ROCm 加速支持。
已在 **Ryzen AI MAX+ 395 / Radeon 8060S** 上实测验证。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 `utensils/comfyui-nix` 在线版 |
| 上游 | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| 在线集成 | ✅ 直接使用上游 flake input，无需 fork/本地 clone |
| 适用 GPU | gfx1151（Strix Halo）— ROCm 7.1 原生识别 |

## 修正内容

模块补丁（`comfyui-rocm-patch.nix`）在不修改上游的前提下扩展：

- **rocmGfxOverride 选项**: 声明 `services.comfyui.rocmGfxOverride`，设置 `HSA_OVERRIDE_GFX_VERSION` 环境变量
- **xformers 自动禁用**: `--disable-xformers`（nixpkgs 的 xformers 不含 ROCm 后端）
- **C 编译工具链**: PATH 注入 `gcc`、`binutils`、`gnumake`，设置 `CC=gcc`
- **PyTorch wheel 升级**: 可选 overlay（`flakes/comfyui-rocm-wheels.nix`）将 ROCm 7.1 wheels 替换为 7.2（torch 2.12.0）

NixKits 模块（`nixkits.comfyui-strix-halo`）一站式启用所有优化。

## 安装

**在线集成** — 直接使用上游 flake，由本地模块补丁覆盖（推荐）：

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # 在线版，无需 fork
    nix-kits.url = "/home/kix/NixKits";               # 或 github
    # ...
  };

  outputs = { nix-kits, comfyui-nix, ... }:
    nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default        # 上游模块
        nix-kits.nixosModules.comfyui-strix-halo # Strix Halo 优化
        ./system/software/comfyui-rocm-patch.nix # 本地补丁（rocmGfxOverride 等）
        {
          nixkits.comfyui-strix-halo.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
}
```

**离线集成**（备选）— 手动应用 `.patch`：

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## 文件结构（在线集成模式）

```
flake.nix                          # comfyui-nix.url = "github:utensils/comfyui-nix"
├── flakes/overlays.nix            # nixpkgs.overlays: comfyui-nix + NixKits + wheel overlay
│   └── flakes/comfyui-rocm-wheels.nix  # （可选）ROCm 7.2 wheels 覆盖
└── system/software/
    ├── comfyui.nix                # 主配置（gpuSupport, port, dataDir...）
    ├── comfyui-rocm-patch.nix     # 模块补丁（rocmGfxOverride, --disable-xformers, CC=gcc）
    └── comfyui-strix-halo.nix    # 启用 NixKits 模块
```

## 注意

- ROCm 7.1 已可原生识别 gfx1151，无需 `HSA_OVERRIDE_GFX_VERSION`
- GPU 未识别时可尝试 `services.comfyui.rocmGfxOverride = "11.0.0"`
- ROCm 运行时缺失：模块自动设置 `hardware.graphics.extraPackages`
- xformers 报错时：补丁已自动 `--disable-xformers`
- 模块自动设置 `amdgpu.gttsize=131072`（适配 Strix Halo 统一内存架构）
- C 工具链注入后，ComfyUI Manager 可在线编译自定义节点依赖
