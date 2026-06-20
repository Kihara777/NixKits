# ruyi

中文 | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | [Katalish](../katalish/ruyi.md) | [Pseudo-Chinese](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org) 的包管理器，用于 RISC-V 开发环境的工具链安装、虚拟环境管理、设备烧录与软件包仓库操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.51.0-alpha.20260616 |
| 上游 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 许可 | Apache 2.0 |
| 注意 | Alpha 阶段软件，API 可能变动 |

## 安装

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# 或通过 overlay
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## 使用

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
{ modules = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
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
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS 兼容性

NixKits 打包的 ruyi 包含 `patches/ruyi-nixos-compat.patch`，在 NixOS 上透明处理以下兼容性问题：

- **动态链接器路径**：预编译的 RISC-V 工具链二进制文件（GCC、QEMU 等）期望 `/lib64/ld-linux-x86-64.so.2`，在 NixOS 上不存在。补丁自动通过 NixOS 的 `ld.so` 重定向执行。
- **工具链子进程修复**：GCC 内部启动的 `cc1`、`as`、`collect2` 等子进程绕过 ruyi mux，补丁通过 `patchelf` 自动修复其 ELF interpreter。
- **Nix console_scripts 兼容**：通过 `RUYI_ARGV0` 环境变量解决 Nix wrapper 中 `exec -a` 丢失的问题。

## 注意

- 上游为 [ISCAS](https://www.iscas.ac.cn) 维护的 RISC-V 开发者工具
- 二进制通过 wrapProgram 注入了 curl、gnutar、git、patchelf 等运行时依赖
- 测试覆盖：ruff lint、mypy 类型检查、pytest 单元测试（320 项）、集成测试（52 项）——全部通过
