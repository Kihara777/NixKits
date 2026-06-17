# ruyi

[中文](ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md)

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

模块自动生成 `/etc/xdg/ruyi/config.toml` 并设置对应的环境变量。

## 注意

- 上游为 [ISCAS](https://www.iscas.ac.cn) 维护的 RISC-V 开发者工具
- 二进制通过 wrapProgram 注入了 curl、gnutar、git 等运行时依赖
- 测试覆盖：ruff lint、mypy 类型检查、pytest 单元测试（277 项）、集成测试（52 项）——全部通过
