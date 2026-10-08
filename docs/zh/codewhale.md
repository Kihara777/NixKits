# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md)  | [偽中国語](../pcn/codewhale.md)

DeepSeek V4 专用的终端编码代理（TUI 工具）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.10.1 |
| 上游 | [codewhale-hq/Codewhale](https://github.com/codewhale-hq/Codewhale) |
| 类型 | 预编译二进制（x86_64 / aarch64）；源码构建（riscv64） |
| 平台 | x86_64 / aarch64 / riscv64 |

## 引用

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

无需安装即可直接运行：

```bash
nix run github:Kihara777/NixKits#codewhale
```

## 使用

```bash
codewhale                              # 交互 TUI
codew                                  # TUI 入口（v0.9.9 起上游更名，原 codewhale-tui）
codewhale "explain this function"      # 单次提示
codewhale --model auto "fix this bug"  # 自动选择模型
codewhale --sandbox-mode <tier>        # 按需选择沙箱权限档位（默认不放开）
codewhale --approval-policy never      # 工具审批策略：on-request / untrusted / never
codewhale doctor                       # 检查配置
codewhale auth set --provider deepseek # 保存 API key
```

首次运行需配置 [DeepSeek API Key](https://platform.deepseek.com/api_keys)。

> 沙箱档位 `--sandbox-mode` 的合法取值：`read-only`、`workspace-write`、`danger-full-access`、`external-sandbox`（实测 `codewhale --help`；`danger-full-access` 完全关闭沙箱）。注意参数名是 **`--sandbox-mode`**，不是 `--sandbox`（后者不存在，会被拒绝）。

## 启用 sudo

codewhale v0.10.1 默认阻止 `sudo` 执行。解决方案见 [codewhale-sudo 补丁文档](../zh/codewhale-sudo.md)。

## 已知问题

> ⚠️ **riscv64 源码构建**：上游从 v0.9.8 起移除了 riscv64 预编译二进制。NixKits 通过 `rustPlatform.buildRustPackage` 从源码交叉编译提供 riscv64 支持。**2026-10-08 实测**：该变体已验到 **eval + 构建 + 运行**——产物是 RISC-V ELF，经 qemu-user/binfmt 真的跑起 `codewhale doctor`；三个架构的 CI 也开了 `smoke-test`（`develop/qemu-smoke-tests/codewhale.sh`，本地与 CI 同一份）。**构建过不等于跑得起来**，这里判的是后者。

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。

