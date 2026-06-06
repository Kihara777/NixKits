# comfyui-strix-halo

[中文](comfyui-strix-halo.md) | [English](../en/comfyui-strix-halo.md) | [日本語](../ja/comfyui-strix-halo.md)

为 AMD Strix Halo（gfx1151 / RDNA 3.5 APU）提供 ComfyUI ROCm 加速支持。
已在 **Ryzen AI MAX+ 395 / Radeon 8060S** 上实测验证。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 comfyui-nix |
| 上游 | [utensils/comfyui-nix](https://github.com/utensils/comfyui-nix) |
| 补丁 | 本仓库 `patches/comfyui-nix-strix-halo.patch` |
| 适用 GPU | gfx1151（Strix Halo）— ROCm 7.2 原生支持 |

## 修正内容

- **ROCm 7.2 stable wheel**: 新增 torch 2.12.0 / torchvision 0.27.0 / torchaudio 2.11.0
- **版本自动选择**: 存在 rocm72 定义时优先 7.2，否则回退 7.1
- **rocmGfxOverride 选项**: GPU 架构未识别时的覆盖开关（`HSA_OVERRIDE_GFX_VERSION`）
- **xformers 自动禁用**: nixpkgs 的 xformers 不含 ROCm 后端
- **C 编译工具链**: 注入 `stdenv.cc`、`binutils`、`gnumake`，设置 `CC=gcc`，支持 ComfyUI Manager 自定义节点编译


## 安装

使用 NixKits 模块（推荐）：

```nix
# flake.nix — 需要已应用补丁的 comfyui-nix
{
  nixkits.comfyui-strix-halo.enable = true;
  services.comfyui.enable = true;
}
```

或手动打补丁：

```bash
cd comfyui-nix && patch -p1 < patches/comfyui-nix-strix-halo.patch
```

## 注意

- ROCm 7.2 已原生支持 gfx1151，无需 `HSA_OVERRIDE_GFX_VERSION`
- GPU 未识别时可尝试 `rocmGfxOverride = "11.0.0"`
- ROCm 运行时缺失：`hardware.graphics.extraPackages = [ rocmPackages.clr rocmPackages.rocminfo ]`
- xformers 报错时：补丁已自动 `--disable-xformers`
- 模块自动设置 `amdgpu.gttsize=131072`（适配 Strix Halo 统一内存架构）
