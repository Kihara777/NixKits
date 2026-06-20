# Project Documentation
[中文](../zh/project.md) | [English](project.md) | [日本語](../ja/project.md)
NixKits project architecture and component relationships.
## Overview
NixKits is a Nix flake software collection organised as a monorepo. Components fall into five categories:**Software** (self-maintained and upstream-tracked applications), **Modules** (NixOS system service configurations),**Overlays** (nixpkgs overrides/package replacements), **Patches** (runtime patch files),**Skills** (task-specific instructions for AI coding assistants).
## Component Tree
```NixKits/├── packages/         # package derivations│   ├── codewhale.nix│   ├── kitsfmt.nix│   ├── mcp-searxng.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── ruyi.nix│   ├── comfyui-strix-halo.nix│   └── kitsfmt-src/  #   (Rust source, vendored locally)├── modules/          # NixOS modules (services.*)│   ├── comfyui-rocm-patch.nix│   ├── comfyui-strix-halo.nix│   ├── llama-cpp-rocm.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── rog-control-center-fix.nix│   ├── ruyi.nix├── overlays/         # nixpkgs overlays│   ├── default.nix│   ├── llama-cpp-rocm.nix│   ├── mihomo-alpha.nix│   ├── rog-control-center-fix.nix│   ├── ruyi-nixos-compat.nix├── patches/          # build/runtime patches├── skills/           # AI coding assistant skills│   ├── nixkits-check-updates/│   ├── nixkits-skills/│   ├── nixos-modern-cli/│   ├── recover-nixos-config/│   ├── translate-katalish/│   ├── translate-pseudocn/│   ├── write-maintenance-log/│   ├── write-project-docs/├── docs/             # multilingual docs│   ├── zh/  (中文基准)│   ├── en/│   ├── ja/│   ├── katalish/│   └── pcn/├── flake.nix├── flake.lock└── README.md```
## Software
### codewhale
DeepSeek V4 终端编码代理
- Docs: `docs/zh/codewhale.md`
- Package def: `packages/codewhale.nix`
### kitsfmt
Nix 格式化器（AST 排序 + Best-Practice 自动修正）
- Docs: `docs/zh/kitsfmt.md`
- Package def: `packages/kitsfmt.nix`
### mcp-searxng
SearXNG 的 MCP Server
- Docs: `docs/zh/mcp-searxng.md`
- Package def: `packages/mcp-searxng.nix`
### obs-bilibili-stream
OBS 的 Bilibili 直播插件
- Docs: `docs/zh/obs-bilibili-stream.md`
- Package def: `packages/obs-bilibili-stream.nix`
### opencode-telegram
OpenCode 的 Telegram Bot 客户端
- Docs: `docs/zh/opencode-telegram.md`
- Package def: `packages/opencode-telegram.nix`
### ruyi
RuyiSDK 包管理器（RISC-V 开发工具）
- Docs: `docs/zh/ruyi.md`
- Package def: `packages/ruyi.nix`
### comfyui-strix-halo
为 AMD Strix Halo (gfx1151/RDNA3.5) 提供 ComfyUI ROCm 支持
- Docs: `docs/zh/comfyui-strix-halo.md`
- Package def: `packages/comfyui-strix-halo.nix`
## Modules
### comfyui-rocm-patch
- Def: `modules/comfyui-rocm-patch.nix`
### comfyui-strix-halo
- Def: `modules/comfyui-strix-halo.nix`
- Docs: `docs/zh/comfyui-strix-halo.md`
### llama-cpp-rocm
- Def: `modules/llama-cpp-rocm.nix`
- Docs: `docs/zh/llama-cpp-rocm.md`
### obs-bilibili-stream
- Def: `modules/obs-bilibili-stream.nix`
- Docs: `docs/zh/obs-bilibili-stream.md`
### opencode-telegram
- Def: `modules/opencode-telegram.nix`
- Docs: `docs/zh/opencode-telegram.md`
### rog-control-center-fix
- Def: `modules/rog-control-center-fix.nix`
- Docs: `docs/zh/rog-control-center-fix.md`
### ruyi
- Def: `modules/ruyi.nix`
- Docs: `docs/zh/ruyi.md`
## Overlays
### default
- Def: `overlays/default.nix`
### llama-cpp-rocm
- Def: `overlays/llama-cpp-rocm.nix`
### mihomo-alpha
- Def: `overlays/mihomo-alpha.nix`
- Description: flake input: https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha
### rog-control-center-fix
- Def: `overlays/rog-control-center-fix.nix`
### ruyi-nixos-compat
- Def: `overlays/ruyi-nixos-compat.nix`
- Description: The patch's _maybe_fix_toolchain_sub_binaries references
## Skills
### nixkits-check-updates
检查上游软件更新并自动升级
- Def: `skills/nixkits-check-updates/SKILL.md`
- Docs: `docs/zh/skills/nixkits-check-updates.md`
### nixkits-skills
NixKits 技能安装器（本地/在线）
- Def: `skills/nixkits-skills/SKILL.md`
- Docs: `docs/zh/skills/nixkits-skills.md`
### nixos-modern-cli
NixOS 现代 CLI 操作指南（面向 AI 模型）
- Def: `skills/nixos-modern-cli/SKILL.md`
- Docs: `docs/zh/skills/nixos-modern-cli.md`
### recover-nixos-config
从 Nix store 恢复误删的 /etc/nixos 配置
- Def: `skills/recover-nixos-config/SKILL.md`
- Docs: `docs/zh/skills/recover-nixos-config.md`
### translate-katalish
ｶﾀﾘｯｼｭ 翻译（半角片假名逐词机械替换英文Docs）
- Def: `skills/translate-katalish/SKILL.md`
- Docs: `docs/zh/skills/translate-katalish.md`
### translate-pseudocn
偽中国語翻译（日语假名剥离 + 语序转换）
- Def: `skills/translate-pseudocn/SKILL.md`
- Docs: `docs/zh/skills/translate-pseudocn.md`
### write-maintenance-log
按 NixKits 规范撰写维护日志（软件更新 + 错误修复）
- Def: `skills/write-maintenance-log/SKILL.md`
- Docs: `docs/zh/skills/write-maintenance-log.md`
### write-project-docs
按 NixKits 风格为任意项目编写多语言Docs系统
- Def: `skills/write-project-docs/SKILL.md`
- Docs: `docs/zh/skills/write-project-docs.md`
## Flake Outputs
```nix# packages: codewhale kitsfmt mcp-searxng obs-bilibili-stream opencode-telegram ruyi comfyui-strix-halo# nixosModules: comfyui-rocm-patch comfyui-strix-halo llama-cpp-rocm obs-bilibili-stream opencode-telegram rog-control-center-fix ruyi# overlays: default llama-cpp-rocm mihomo-alpha rog-control-center-fix ruyi-nixos-compat# nixpkgs = github:NixOS/nixpkgs/nixos-unstable# flake-utils = github:numtide/flake-utils# llama-cpp-ver = https://api.github.com/repos/ggml-org/llama.cpp/releases/latest# mihomo-ver = https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha```
## multilingual docs
| Language | Code | Directory | Audience ||------|------|------|---------|| Chinese | zh | `docs/zh/` | Baseline language, source of all docs || English | en | `docs/en/` | English users; source for katalish translation || Japanese | ja | `docs/ja/` | Japanese users; source for pseudo-Chinese translation || Katakana English | katalish | `docs/katalish/` | Katakana English (mechanical English→katakana) || Pseudo-Chinese | pcn | `docs/pcn/` | Pseudo-Chinese (kana stripping + SOV→SVO) |Extended languages (katalish, pcn) are auto-discovered by `translate-*` skills via `write-project-docs`.
## Usage
### NixOS Module
```nix# flake.nix{  inputs = {    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";    nix-kits.url = "github:Kihara777/NixKits";  };  outputs = { nixpkgs, nix-kits, ... }: {    nixosConfigurations.example = nixpkgs.lib.nixosSystem {      modules = [        nix-kits.nixosModules.ruyi      ];    };  };}```
### DevShell
```bashnix registry add nix-kits github:Kihara777/NixKitsnix develop nix-kits#ruyi```
## Package↔Overlay Relationships
| Software | Overlay | Relationship ||------|----------|------|| llama-cpp-rocm | `overlays/llama-cpp-rocm.nix` | Dynamic upstream ROCm version tracking || rcc-fix | `overlays/rog-control-center-fix.nix` | Patches asusctl device support || ruyi-nixos-compat | `overlays/ruyi-nixos-compat.nix` | NixOS ELF interpreter compatibility || mihomo-alpha | `overlays/mihomo-alpha.nix` | Prerelease-Alpha tracking |
## Language Map
| Language | Code | Directory | From | Skill ||------|------|------|--------|---------|| Chinese | zh | `docs/zh/` | — | — || English | en | `docs/en/` | zh→en manual | — || Japanese | ja | `docs/ja/` | zh→ja manual | — || Katakana English | katalish | `docs/katalish/` | en→kata auto | translate-katalish || Pseudo-Chinese | pcn | `docs/pcn/` | ja→pcn auto | translate-pseudocn |