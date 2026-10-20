# rea

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-x86_64.yml?branch=main&label=x86_64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-rea-aarch64.yml?branch=main&label=aarch64%20v6.7.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/rea.md) | [日本語](../ja/rea.md)  | [偽中国語](../pcn/rea.md)

**REA（Reverse Engineer Anything）** — 用 agent 逆向任何东西：一个 CLI + MCP 服务，从应用行为一直下探到原生二进制。分析在本地跑，结论带证据与局限。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 6.7.0 |
| 上游 | <https://github.com/morluto/rea> |
| npm 名 | `rea-agents` |
| 许可 | MIT |
| 打包形态 | 上游**已构建**的 npm tarball（`dist/` 原样，不在 Nix 里编译） |
| 平台 | x86_64-linux / aarch64-linux |

## 使用

```bash
rea --help                                    # 命令一览（约 100 个子命令）
rea doctor                                    # 就绪性诊断（客户端注册 / 分析引擎 / 宿主机）
rea capabilities                              # provider 能力与副作用清单
rea analyze-javascript-application <目录> --format json   # 静态重建 JS/Electron 应用
rea mcp                                       # stdio MCP 服务
```

分析结果是一份 **Evidence envelope**：`normalized_result` 里放结论，`limitations` 里放这一条结论到不了的边界。

## 能力与依赖边界

REA 的大部分能力**不需要外部引擎**，这也是本包的主要用途；需要引擎的部分请你自备，本包不去猜路径。

| 目标 | 返回什么 | 需要什么 |
|------|---------|---------|
| JavaScript / Electron | 模块、导入、source map、路由、IPC、原生插件关系 | 本包已带 `ps`（procps） |
| .NET 程序集 | 元数据、CIL 指令、声明的原生依赖 | 无（纯静态） |
| Go / Rust 二进制 | 内嵌编译版本、模块、依赖边 | 无（纯静态） |
| Godot PCK / IL2CPP / SQLite / 包与资源 | 归档清单、类型与方法名、表结构、digest | 无（纯静态） |
| 原生二进制（伪代码 / 反汇编） | 伪代码、汇编、字符串、符号、调用与引用 | 外部安装的 Hopper / Ghidra / IDA |
| Android APK | manifest、类、反编译方法 | JADX + 完整 JDK |

## 本包的已知边界

> 下面这些不是「没测过」，是**已知不可用**或**已知会报错**——写出来，免得你在别处读到相反的期待。

| 事项 | 实际情况 |
|------|---------|
| `rea doctor` 的宿主机判定 | NixOS 上报 `host: unsupported_host`（上游按 apt / dnf / pacman 家族识别发行版，NixOS 不在名单里）。**纯静态分析实测照常可用**，`doctor` 该行是判定口径而非运行前提 |
| frida 动态插桩 | 上游的 optionalDependency，靠 `prebuild-install` 在安装期**下载**二进制。Nix 构建离线且 `npmRebuildFlags = [ "--ignore-scripts" ]`，所以 frida 的 native binding 不存在——相关命令会失败，不会静默降级 |
| Hopper / Ghidra / IDA / JADX | 本包一律不提供。用环境变量指过去（如 `GHIDRA_INSTALL_DIR`、`HOPPER_LAUNCHER_PATH`、`REA_JADX_MCP_JAR`） |
| riscv64 | **不支持**：`@lydell/node-pty` 只发 x64/arm64 预编译件，REA 会 import 它 |

## 引用

```nix
# 直接引用
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.rea ];

# Default overlay (推荐)
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];  # → pkgs.rea
```

## 依赖 MCP 的用法

`rea mcp` 是 stdio 传输。其他客户端的手工注册方式见上游 `docs/installation.md`；`rea doctor` 会列出它在本机找到的客户端配置与缺失项。

## 升级

`packages/rea.nix` 钉住三样东西：npm tarball 的 `hash`、`npmDepsHash`、以及 vendored 的 `packages/rea-package-lock.json`。三者必须同源——vendored lock 只含生产依赖，因此 `postPatch` 会删掉 tarball 里的 `devDependencies`，两边不一致时 `npm ci` 会硬失败（这是有意的：不一致比编译错误更难查）。通用流程见 `nix-flake-update-check` 技能。

真实产物验证在 `develop/qemu-smoke-tests/rea.sh`（CI 的 x86_64 / aarch64 两个 workflow 都会跑），判据是**真跑一次静态分析**，不是 `--version`。
