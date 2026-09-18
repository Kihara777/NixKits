# ruyi

[![ruyi x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-x86_64.yml?branch=main&label=ruyi%20x86_64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-aarch64.yml?branch=main&label=ruyi%20aarch64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-riscv64.yml?branch=main&label=ruyi%20riscv64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-x86_64.yml?branch=main&label=ruyi-beta%20x86_64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-aarch64.yml?branch=main&label=ruyi-beta%20aarch64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-riscv64.yml?branch=main&label=ruyi-beta%20riscv64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-x86_64.yml?branch=main&label=ruyi-alpha%20x86_64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-aarch64.yml?branch=main&label=ruyi-alpha%20aarch64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-riscv64.yml?branch=main&label=ruyi-alpha%20riscv64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md)  | [偽中国語](../pcn/ruyi.md)

[RuyiSDK](https://ruyisdk.org) 的包管理器，用于 RISC-V 开发环境的工具链安装、虚拟环境管理、设备烧录与软件包仓库操作。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.52.0（稳定） |
| 上游 | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| 许可 | Apache 2.0 |
| 通道 | stable 0.52.0 · beta 0.53.0-beta.20260917 · alpha 0.52.0-alpha.20260714 |

## 安装

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# 或通过 overlay
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

> 需要 beta 或 alpha 版本？见下方 [版本通道](#版本通道)。

## 版本通道

ruyi 提供三个独立软件包：

| 包名 | 版本 | 用途 |
|------|------|------|
| `ruyi` | 0.52.0（稳定）| 生产环境 |
| `ruyi-beta` | 0.53.0-beta.20260917 | 尝鲜测试 |
| `ruyi-alpha` | 0.52.0-alpha.20260714 | 前沿开发 |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta  # 使用 beta 版
];
```

```bash
ruyi --help
ruyi list --all          # 列出所有可用软件包
ruyi install <pkg>       # 安装软件包
ruyi venv -t <toolchain> <profile> <dest>  # 创建虚拟环境（三者缺一不可）
ruyi device provision    # 创建 RISC-V 设备虚拟环境
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
  dest = "~/ruyi-venvs/riscv";
};
```

## NixOS 兼容性

NixKits 打包版本**内置**补丁 `patches/ruyi-nixos-compat.patch`，在 NixOS 下透明处理运行时不兼容。补丁已并入 `packages/ruyi/ruyi.nix`，由 stable / beta / alpha 三通道共用 —— **无需任何 overlay 配置**，装上即生效。

> 历史沿革：该补丁原先经 overlay `ruyi-nixos-compat` 挂载到 **nixpkgs 的 `ruyi`** 上。nixpkgs 后续移除了 `ruyi` 包，overlay 因而失去宿主 —— flake 包与 NixOS 模块都读不到它（只有 devShell 自己套壳才生效）。现改为包内直接 `patches = [...]`，消除了「文档声称包含、实际未生效」的失配。

**功能**
- **动态链接器重定向**：预编译 RISC-V 工具链二进制期望 `/lib64/ld-linux-x86-64.so.2`，NixOS 不存在该路径。补丁自动以 NixOS `ld.so` 重定向执行。
- **GCC 子进程修复**：`cc1`、`as`、`collect2` 等子进程绕过 ruyi mux，补丁通过 `patchelf` 修复 ELF interpreter。
- **Nix console_scripts 兼容**：`RUYI_ARGV0` 环境变量恢复 Nix wrapper 丢失的 `exec -a` 语义。

**验证**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> 补丁逻辑在非 NixOS 环境完全短路，不干扰其他发行版。对使用 ruyi 下载执行 RISC-V 交叉编译工具链的用户必需。

## 注意

- 上游为 [ISCAS](https://www.iscas.ac.cn) 维护的 RISC-V 开发者工具
- 二进制通过 wrapProgram 注入了 curl、gnutar、git、patchelf 等运行时依赖
- Python 侧运行时依赖经 `propagatedBuildInputs` 提供。上游自 0.53.0 起把 `pyelftools`（ELF/ABI 校验）列为运行时依赖，并在测试收集期 `import elftools`——缺它会让整个 pytest 以 `Interrupted: 1 error during collection` 中断。本包在**共享 base 中无条件**加入该依赖，故 0.52.x 通道（上游不需要它）也一并带上：多余但无害，换来三通道定义一致
- 测试覆盖：ruff lint、mypy 类型检查、pytest 单元测试与集成测试——各通道数量不同（实测）：
  - `ruyi`（0.52.0）：单元 **368**、集成 **58**
  - `ruyi-beta`（0.53.0-beta）：单元 **462**、集成 **70**
  - `ruyi-alpha`（0.52.0-alpha）：单元 **346**、集成 **57**
  - ruff / mypy 两步在 `checkPhase` 中为 `|| true`（不阻断），**真正把关的是 pytest**

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
