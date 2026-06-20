# 项目文档
[中文](project.md) | [English](../en/project.md) | [日本語](../ja/project.md)
NixKits 项目架构与组件关系。
## 概述
NixKits 是一个 Nix flake 软件合集，采用 monorepo 结构组织代码。组件分为五个类别：**软件**（自维护及上游追踪的应用程序）、**模块**（NixOS 系统服务配置）、**覆盖层**（nixpkgs 覆盖/包替换）、**补丁**（运行时补丁文件）、**技能**（AI 编码助手的任务专用指令）。
## 组件目录
```NixKits/├── packages/         # 软件包 derivations│   ├── codewhale.nix│   ├── kitsfmt.nix│   ├── mcp-searxng.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── ruyi.nix│   ├── comfyui-strix-halo.nix│   └── kitsfmt-src/  #   (Rust 源码，本地 vendor)├── modules/          # NixOS 模块 (services.*)│   ├── comfyui-rocm-patch.nix│   ├── comfyui-strix-halo.nix│   ├── llama-cpp-rocm.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── rog-control-center-fix.nix│   ├── ruyi.nix├── overlays/         # nixpkgs 覆盖层│   ├── default.nix│   ├── llama-cpp-rocm.nix│   ├── mihomo-alpha.nix│   ├── rog-control-center-fix.nix│   ├── ruyi-nixos-compat.nix├── patches/          # 构建/运行时补丁├── skills/           # AI 编码助手技能│   ├── nixkits-check-updates/│   ├── nixkits-skills/│   ├── nixos-modern-cli/│   ├── recover-nixos-config/│   ├── translate-katalish/│   ├── translate-pseudocn/│   ├── write-maintenance-log/│   ├── write-project-docs/├── docs/             # 多语文档│   ├── zh/  (中文基准)│   ├── en/│   ├── ja/│   ├── katalish/│   └── pcn/├── flake.nix├── flake.lock└── README.md```
## 软件
### codewhale
DeepSeek V4 终端编码代理
- 文档: `docs/zh/codewhale.md`
- 包定义: `packages/codewhale.nix`
### kitsfmt
Nix 格式化器（AST 排序 + Best-Practice 自动修正）
- 文档: `docs/zh/kitsfmt.md`
- 包定义: `packages/kitsfmt.nix`
### mcp-searxng
SearXNG 的 MCP Server
- 文档: `docs/zh/mcp-searxng.md`
- 包定义: `packages/mcp-searxng.nix`
### obs-bilibili-stream
OBS 的 Bilibili 直播插件
- 文档: `docs/zh/obs-bilibili-stream.md`
- 包定义: `packages/obs-bilibili-stream.nix`
### opencode-telegram
OpenCode 的 Telegram Bot 客户端
- 文档: `docs/zh/opencode-telegram.md`
- 包定义: `packages/opencode-telegram.nix`
### ruyi
RuyiSDK 包管理器（RISC-V 开发工具）
- 文档: `docs/zh/ruyi.md`
- 包定义: `packages/ruyi.nix`
### comfyui-strix-halo
为 AMD Strix Halo (gfx1151/RDNA3.5) 提供 ComfyUI ROCm 支持
- 文档: `docs/zh/comfyui-strix-halo.md`
- 包定义: `packages/comfyui-strix-halo.nix`
## 模块
### comfyui-rocm-patch
- 定义: `modules/comfyui-rocm-patch.nix`
### comfyui-strix-halo
- 定义: `modules/comfyui-strix-halo.nix`
- 文档: `docs/zh/comfyui-strix-halo.md`
### llama-cpp-rocm
- 定义: `modules/llama-cpp-rocm.nix`
- 文档: `docs/zh/llama-cpp-rocm.md`
### obs-bilibili-stream
- 定义: `modules/obs-bilibili-stream.nix`
- 文档: `docs/zh/obs-bilibili-stream.md`
### opencode-telegram
- 定义: `modules/opencode-telegram.nix`
- 文档: `docs/zh/opencode-telegram.md`
### rog-control-center-fix
- 定义: `modules/rog-control-center-fix.nix`
- 文档: `docs/zh/rog-control-center-fix.md`
### ruyi
- 定义: `modules/ruyi.nix`
- 文档: `docs/zh/ruyi.md`
## 覆盖层
### default
- 定义: `overlays/default.nix`
### llama-cpp-rocm
- 定义: `overlays/llama-cpp-rocm.nix`
### mihomo-alpha
- 定义: `overlays/mihomo-alpha.nix`
- 说明: flake input: https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha
### rog-control-center-fix
- 定义: `overlays/rog-control-center-fix.nix`
### ruyi-nixos-compat
- 定义: `overlays/ruyi-nixos-compat.nix`
- 说明: The patch's _maybe_fix_toolchain_sub_binaries references
## 技能
### nixkits-check-updates
检查上游软件更新并自动升级
- 定义: `skills/nixkits-check-updates/SKILL.md`
- 文档: `docs/zh/skills/nixkits-check-updates.md`
### nixkits-skills
NixKits 技能安装器（本地/在线）
- 定义: `skills/nixkits-skills/SKILL.md`
- 文档: `docs/zh/skills/nixkits-skills.md`
### nixos-modern-cli
NixOS 现代 CLI 操作指南（面向 AI 模型）
- 定义: `skills/nixos-modern-cli/SKILL.md`
- 文档: `docs/zh/skills/nixos-modern-cli.md`
### recover-nixos-config
从 Nix store 恢复误删的 /etc/nixos 配置
- 定义: `skills/recover-nixos-config/SKILL.md`
- 文档: `docs/zh/skills/recover-nixos-config.md`
### translate-katalish
ｶﾀﾘｯｼｭ 翻译（半角片假名逐词机械替换英文文档）
- 定义: `skills/translate-katalish/SKILL.md`
- 文档: `docs/zh/skills/translate-katalish.md`
### translate-pseudocn
偽中国語翻译（日语假名剥离 + 语序转换）
- 定义: `skills/translate-pseudocn/SKILL.md`
- 文档: `docs/zh/skills/translate-pseudocn.md`
### write-maintenance-log
按 NixKits 规范撰写维护日志（软件更新 + 错误修复）
- 定义: `skills/write-maintenance-log/SKILL.md`
- 文档: `docs/zh/skills/write-maintenance-log.md`
### write-project-docs
按 NixKits 风格为任意项目编写多语言文档系统
- 定义: `skills/write-project-docs/SKILL.md`
- 文档: `docs/zh/skills/write-project-docs.md`
## Flake 输出
```nix# packages: codewhale kitsfmt mcp-searxng obs-bilibili-stream opencode-telegram ruyi comfyui-strix-halo# nixosModules: comfyui-rocm-patch comfyui-strix-halo llama-cpp-rocm obs-bilibili-stream opencode-telegram rog-control-center-fix ruyi# overlays: default llama-cpp-rocm mihomo-alpha rog-control-center-fix ruyi-nixos-compat# nixpkgs = github:NixOS/nixpkgs/nixos-unstable# flake-utils = github:numtide/flake-utils# llama-cpp-ver = https://api.github.com/repos/ggml-org/llama.cpp/releases/latest# mihomo-ver = https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha```
## 多语文档
| 语言 | 代码 | 目录 | 适用对象 ||------|------|------|---------|| 中文 | zh | `docs/zh/` | 基准语言，所有文档的源 || 英文 | en | `docs/en/` | 英语用户；katalish 翻译的源 || 日文 | ja | `docs/ja/` | 日语用户；伪中国语翻译的源 || ｶﾀﾘｯｼｭ | katalish | `docs/katalish/` | 片假名英语（机械式英语→片假名） || 偽中国語 | pcn | `docs/pcn/` | 伪中国语（日语假名剥离+SOV→SVO） |扩展语言（katalish、pcn）由 `translate-*` 技能通过 `write-project-docs` 自动发现。
## 使用
### NixOS 模块
```nix# flake.nix{  inputs = {    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";    nix-kits.url = "github:Kihara777/NixKits";  };  outputs = { nixpkgs, nix-kits, ... }: {    nixosConfigurations.example = nixpkgs.lib.nixosSystem {      modules = [        nix-kits.nixosModules.ruyi      ];    };  };}```
### DevShell
```bashnix registry add nix-kits github:Kihara777/NixKitsnix develop nix-kits#ruyi```
## 包与覆盖层关系
| 软件 | 所属覆盖层 | 关系 ||------|----------|------|| llama-cpp-rocm | `overlays/llama-cpp-rocm.nix` | 动态追踪上游 ROCm 版本 || rcc-fix | `overlays/rog-control-center-fix.nix` | 修补 asusctl 的设备支持 || ruyi-nixos-compat | `overlays/ruyi-nixos-compat.nix` | NixOS ELF interpreter 兼容 || mihomo-alpha | `overlays/mihomo-alpha.nix` | Prerelease-Alpha 追踪 |
## 语言映射
| 语言 | 代码 | 目录 | 翻译源 | 翻译技能 ||------|------|------|--------|---------|| 中文 | zh | `docs/zh/` | — | — || 英文 | en | `docs/en/` | zh→en 人工 | — || 日文 | ja | `docs/ja/` | zh→ja 人工 | — || ｶﾀﾘｯｼｭ | katalish | `docs/katalish/` | en→kata 自动 | translate-katalish || 偽中国語 | pcn | `docs/pcn/` | ja→pcn 自动 | translate-pseudocn |