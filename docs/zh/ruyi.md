# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org) 的包管理器，用于 RISC-V 开发环境的工具链安装、虚拟环境管理、设备烧录与软件包仓库操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.50.0（稳定） |
| 上游 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 许可 | Apache 2.0 |
| 通道 | 稳定版 | beta 版 | alpha 版 |

## 安装

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 或通过 overlay

> 需要 beta 或 alpha 版本？见下方 [版本通道](#版本通道)。
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 版本通道

ruyi 提供三个独立软件包：

| 包名 | 版本 | 用途 |
|------|------|------|
| `ruyi` | 0.50.0（稳定）| 生产环境 |
| `ruyi-beta` | 0.50.0-beta.20260623 | 尝鲜测试 |
| `ruyi-alpha` | 0.51.0-alpha.20260616 | 前沿开发 |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta  # 使用 beta 版
];
```

```bash
ruyi --help
ruyi list --all          # 列出所有可用软件包
ruyi install <pkg>       # 安装工具链
ruyi venv --toolchain <t> # 创建虚拟环境
ruyi device provision    # 设备烧录
```

> ruyi 需要网络连接以克隆软件包仓库（`packages-index`），首次运行 `ruyi list` 时会自动下载。

## 模块

声明式配置 ruyi 的运行时行为：

```nix
# flake.nix
{ modules = [ nixkits.nixosModules.ruyi ]; }

nixkits.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

模块自动生成 `/etc/xdg/ruyi/config.toml`、设置环境变量，并在系统激活时自动更新包仓库索引。

支持声明式虚拟环境：

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 兼容性

NixKits 打包版本包含 overlay `ruyi-nixos-compat`（`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`），在 NixOS 下透明处理运行时不兼容：

**添加**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # 独立 overlay
];
```

**功能**
- **动态链接器重定向**：预编译 RISC-V 工具链二进制期望 `/lib64/ld-linux-x86-64.so.2`，NixOS 不存在该路径。补丁自动以 NixOS `ld.so` 重定向执行。
- **GCC 子进程修复**：`cc1`、`as`、`collect2` 等子进程绕过 ruyi mux，补丁通过 `patchelf` 修复 ELF interpreter。
- **Nix console_scripts 兼容**：`RUYI_ARGV0` 环境变量恢复 Nix wrapper 丢失的 `exec -a` 语义。

**验证**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> 仅 NixOS 环境启用此 overlay。非 NixOS 下补丁逻辑完全短路，不干扰其他发行版。对使用 ruyi 下载执行 RISC-V 交叉编译工具链的用户必需。

## 注意

- 上游为 [ISCAS](https://www.iscas.ac.cn) 维护的 RISC-V 开发者工具
- 二进制通过 wrapProgram 注入了 curl、gnutar、git、patchelf 等运行时依赖
- 测试覆盖：ruff lint、mypy 类型检查、pytest 单元测试（320 项）、集成测试（52 项）——全部通过

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
