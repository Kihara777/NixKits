# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md)  | [偽中国語](../pcn/codewhale.md)

DeepSeek V4 专用的终端编码代理（TUI 工具）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.9.0 |
| 上游 | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
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
codewhale "explain this function"      # 单次提示
codewhale --model auto "fix this bug"  # 自动选择模型
codewhale --yolo                       # 自动批准工具
codewhale doctor                       # 检查配置
codewhale auth set --provider deepseek # 保存 API key
```

首次运行需配置 [DeepSeek API Key](https://platform.deepseek.com/api_keys)。

## 启用 sudo

codewhale v0.9.0 默认禁用了 `prctl(PR_SET_NO_NEW_PRIVS)`（防御纵深），阻止 `sudo` 执行。使用 `allowSudo` 参数启用 `LD_PRELOAD` shim 绕过：

```nix
# 覆盖参数
(inputs.nixkits.packages.${pkgs.system}.codewhale.override { allowSudo = true; })
```

> 此选项降低沙箱安全性，仅在需要 `sudo` 的开发环境中使用。

## 已知问题

> ⚠️ **riscv64 源码构建**：上游从 v0.9.0 起移除了 riscv64 预编译二进制。NixKits 通过 `rustPlatform.buildRustPackage` 从源码交叉编译提供 riscv64 支持。此项为实验性功能，首次 CI 构建可能因依赖 hash 不匹配失败——我们会在后续 CI 运行中验证并修复。

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。

