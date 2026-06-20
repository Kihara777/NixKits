# 項目文書
[中文](../zh/project.md) | [English](../en/project.md) | [日本語](project.md)
NixKits 項目架構組件関係
## 概要
NixKits Nix flake 軟件合集構造代碼管理組件 5 分類分類：**軟件**自前維護＋上流追跡**模塊**NixOS 系統服務設定**覆蓋層**nixpkgs /軟件包置換**補丁**運行時補丁文件**技能**AI 向特化命令
## 組件
```NixKits/├── packages/         # 软件包 derivations│   ├── codewhale.nix│   ├── kitsfmt.nix│   ├── mcp-searxng.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── ruyi.nix│   ├── comfyui-strix-halo.nix│   └── kitsfmt-src/  #   (Rust 源码，本地 vendor)├── modules/          # NixOS 模块 (services.*)│   ├── comfyui-rocm-patch.nix│   ├── comfyui-strix-halo.nix│   ├── llama-cpp-rocm.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── rog-control-center-fix.nix│   ├── ruyi.nix├── overlays/         # nixpkgs 覆盖层│   ├── default.nix│   ├── llama-cpp-rocm.nix│   ├── mihomo-alpha.nix│   ├── rog-control-center-fix.nix│   ├── ruyi-nixos-compat.nix├── patches/          # 构建/运行时补丁├── skills/           # AI 编码助手技能│   ├── nixkits-check-updates/│   ├── nixkits-skills/│   ├── nixos-modern-cli/│   ├── recover-nixos-config/│   ├── translate-katalish/│   ├── translate-pseudocn/│   ├── write-maintenance-log/│   ├── write-project-docs/├── docs/             # 多语ドキュメント│   ├── zh/  (中文基准)│   ├── en/│   ├── ja/│   ├── katalish/│   └── pcn/├── flake.nix├── flake.lock└── README.md```
## 軟件
### codewhale
DeepSeek V4 终端编码代理
- 文檔: `docs/zh/codewhale.md`
- 軟件包定義: `packages/codewhale.nix`
### kitsfmt
Nix 格式化器AST 排序 + Best-Practice 自动修正
- 文檔: `docs/zh/kitsfmt.md`
- 軟件包定義: `packages/kitsfmt.nix`
### mcp-searxng
SearXNG 的 MCP Server
- 文檔: `docs/zh/mcp-searxng.md`
- 軟件包定義: `packages/mcp-searxng.nix`
### obs-bilibili-stream
OBS 的 Bilibili 直播插件
- 文檔: `docs/zh/obs-bilibili-stream.md`
- 軟件包定義: `packages/obs-bilibili-stream.nix`
### opencode-telegram
OpenCode 的 Telegram Bot 客户端
- 文檔: `docs/zh/opencode-telegram.md`
- 軟件包定義: `packages/opencode-telegram.nix`
### ruyi
RuyiSDK 包管理器RISC-V 开发工具
- 文檔: `docs/zh/ruyi.md`
- 軟件包定義: `packages/ruyi.nix`
### comfyui-strix-halo
为 AMD Strix Halo (gfx1151/RDNA3.5) 提供 ComfyUI ROCm 支持
- 文檔: `docs/zh/comfyui-strix-halo.md`
- 軟件包定義: `packages/comfyui-strix-halo.nix`
## 模塊
### comfyui-rocm-patch
- 定義: `modules/comfyui-rocm-patch.nix`
### comfyui-strix-halo
- 定義: `modules/comfyui-strix-halo.nix`
- 文檔: `docs/zh/comfyui-strix-halo.md`
### llama-cpp-rocm
- 定義: `modules/llama-cpp-rocm.nix`
- 文檔: `docs/zh/llama-cpp-rocm.md`
### obs-bilibili-stream
- 定義: `modules/obs-bilibili-stream.nix`
- 文檔: `docs/zh/obs-bilibili-stream.md`
### opencode-telegram
- 定義: `modules/opencode-telegram.nix`
- 文檔: `docs/zh/opencode-telegram.md`
### rog-control-center-fix
- 定義: `modules/rog-control-center-fix.nix`
- 文檔: `docs/zh/rog-control-center-fix.md`
### ruyi
- 定義: `modules/ruyi.nix`
- 文檔: `docs/zh/ruyi.md`
## 覆蓋層
### default
- 定義: `overlays/default.nix`
### llama-cpp-rocm
- 定義: `overlays/llama-cpp-rocm.nix`
### mihomo-alpha
- 定義: `overlays/mihomo-alpha.nix`
- 説明: flake input: https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha
### rog-control-center-fix
- 定義: `overlays/rog-control-center-fix.nix`
### ruyi-nixos-compat
- 定義: `overlays/ruyi-nixos-compat.nix`
- 説明: The patch's _maybe_fix_toolchain_sub_binaries references
## 技能
### nixkits-check-updates
检查上游软件更新并自动升级
- 定義: `skills/nixkits-check-updates/SKILL.md`
- 文檔: `docs/zh/skills/nixkits-check-updates.md`
### nixkits-skills
NixKits 技能安装器本地/在线
- 定義: `skills/nixkits-skills/SKILL.md`
- 文檔: `docs/zh/skills/nixkits-skills.md`
### nixos-modern-cli
NixOS 现代 CLI 操作指南面向 AI 模型
- 定義: `skills/nixos-modern-cli/SKILL.md`
- 文檔: `docs/zh/skills/nixos-modern-cli.md`
### recover-nixos-config
从 Nix store 恢复误删的 /etc/nixos 配置
- 定義: `skills/recover-nixos-config/SKILL.md`
- 文檔: `docs/zh/skills/recover-nixos-config.md`
### translate-katalish
ｶﾀﾘｯｼｭ 翻译半角片假名逐词机械替换英文文檔
- 定義: `skills/translate-katalish/SKILL.md`
- 文檔: `docs/zh/skills/translate-katalish.md`
### translate-pseudocn
偽中国語翻译日语假名剥离 + 语序转换
- 定義: `skills/translate-pseudocn/SKILL.md`
- 文檔: `docs/zh/skills/translate-pseudocn.md`
### write-maintenance-log
按 NixKits 规范撰写维护日志软件更新 + 错误修复
- 定義: `skills/write-maintenance-log/SKILL.md`
- 文檔: `docs/zh/skills/write-maintenance-log.md`
### write-project-docs
按 NixKits 风格为任意项目编写多语言文檔系统
- 定義: `skills/write-project-docs/SKILL.md`
- 文檔: `docs/zh/skills/write-project-docs.md`
## Flake 出力
```nix# packages: codewhale kitsfmt mcp-searxng obs-bilibili-stream opencode-telegram ruyi comfyui-strix-halo# nixosModules: comfyui-rocm-patch comfyui-strix-halo llama-cpp-rocm obs-bilibili-stream opencode-telegram rog-control-center-fix ruyi# overlays: default llama-cpp-rocm mihomo-alpha rog-control-center-fix ruyi-nixos-compat# nixpkgs = github:NixOS/nixpkgs/nixos-unstable# flake-utils = github:numtide/flake-utils# llama-cpp-ver = https://api.github.com/repos/ggml-org/llama.cpp/releases/latest# mihomo-ver = https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha```
## 多言語文檔
|言語|代碼|目錄|対象||------|------|------|---------||中国語|zh|`docs/zh/`|言語全文檔||英語|en|`docs/en/`|英語；翻訳||日本語|ja|`docs/ja/`|日本語；偽中国語翻訳||英語|katalish|`docs/katalish/`|英語機械的英→変換||偽中国語|pcn|`docs/pcn/`|偽中国語仮名除去＋SOV→SVO|拡張言語（katalish、pcn）は `translate-*` スキルが `write-project-docs` を通じて自動検出します。
## 使方
### NixOS 模塊
```nix# flake.nix{  inputs = {    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";    nix-kits.url = "github:Kihara777/NixKits";  };  outputs = { nixpkgs, nix-kits, ... }: {    nixosConfigurations.example = nixpkgs.lib.nixosSystem {      modules = [        nix-kits.nixosModules.ruyi      ];    };  };}```
### DevShell
```bashnix registry add nix-kits github:Kihara777/NixKitsnix develop nix-kits#ruyi```
## 軟件包↔覆蓋層関係
|軟件|覆蓋層|関係||------|----------|------||llama-cpp-rocm|`overlays/llama-cpp-rocm.nix`|上流 ROCm 版本動的追跡||rcc-fix|`overlays/rog-control-center-fix.nix`|asusctl 設備支持補丁||ruyi-nixos-compat|`overlays/ruyi-nixos-compat.nix`|NixOS ELF解釋器互換||mihomo-alpha|`overlays/mihomo-alpha.nix`|Prerelease-Alpha 追跡|
## 言語
|言語|代碼|目錄|翻訳元|技能||------|------|------|--------|---------||中国語|zh|`docs/zh/`|—|—||英語|en|`docs/en/`|zh→en 手動|—||日本語|ja|`docs/ja/`|zh→ja 手動|—||英語|katalish|`docs/katalish/`|en→kata 自動|translate-katalish||偽中国語|pcn|`docs/pcn/`|ja→pcn 自動|translate-pseudocn|