# プロジェクト文書
[中文](../zh/project.md) | [English](../en/project.md) | [日本語](project.md)
NixKits プロジェクトアーキテクチャとコンポーネント関係。
## 概要
NixKits は Nix flake ソフトウェアコレクションで、モノレポ構造でコードを管理します。コンポーネントは 5 つのカテゴリに分類されます：**ソフトウェア**（自前メンテナンス＋上流追跡アプリ）、**モジュール**（NixOS システムサービス設定）、**オーバーレイ**（nixpkgs オーバーライド/パッケージ置換）、**パッチ**（ランタイムパッチファイル）、**スキル**（AI コーディングアシスタント向けタスク特化命令）。
## コンポーネントツリー
```NixKits/├── packages/         # 软件包 derivations│   ├── codewhale.nix│   ├── kitsfmt.nix│   ├── mcp-searxng.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── ruyi.nix│   ├── comfyui-strix-halo.nix│   └── kitsfmt-src/  #   (Rust 源码，本地 vendor)├── modules/          # NixOS 模块 (services.*)│   ├── comfyui-rocm-patch.nix│   ├── comfyui-strix-halo.nix│   ├── llama-cpp-rocm.nix│   ├── obs-bilibili-stream.nix│   ├── opencode-telegram.nix│   ├── rog-control-center-fix.nix│   ├── ruyi.nix├── overlays/         # nixpkgs 覆盖层│   ├── default.nix│   ├── llama-cpp-rocm.nix│   ├── mihomo-alpha.nix│   ├── rog-control-center-fix.nix│   ├── ruyi-nixos-compat.nix├── patches/          # 构建/运行时补丁├── skills/           # AI 编码助手技能│   ├── nixkits-check-updates/│   ├── nixkits-skills/│   ├── nixos-modern-cli/│   ├── recover-nixos-config/│   ├── translate-katalish/│   ├── translate-pseudocn/│   ├── write-maintenance-log/│   ├── write-project-docs/├── docs/             # 多语ドキュメント│   ├── zh/  (中文基准)│   ├── en/│   ├── ja/│   ├── katalish/│   └── pcn/├── flake.nix├── flake.lock└── README.md```
## ソフトウェア
### codewhale
DeepSeek V4 终端编码代理
- ドキュメント: `docs/zh/codewhale.md`
- パッケージ定義: `packages/codewhale.nix`
### kitsfmt
Nix 格式化器（AST 排序 + Best-Practice 自动修正）
- ドキュメント: `docs/zh/kitsfmt.md`
- パッケージ定義: `packages/kitsfmt.nix`
### mcp-searxng
SearXNG 的 MCP Server
- ドキュメント: `docs/zh/mcp-searxng.md`
- パッケージ定義: `packages/mcp-searxng.nix`
### obs-bilibili-stream
OBS 的 Bilibili 直播插件
- ドキュメント: `docs/zh/obs-bilibili-stream.md`
- パッケージ定義: `packages/obs-bilibili-stream.nix`
### opencode-telegram
OpenCode 的 Telegram Bot 客户端
- ドキュメント: `docs/zh/opencode-telegram.md`
- パッケージ定義: `packages/opencode-telegram.nix`
### ruyi
RuyiSDK 包管理器（RISC-V 开发工具）
- ドキュメント: `docs/zh/ruyi.md`
- パッケージ定義: `packages/ruyi.nix`
### comfyui-strix-halo
为 AMD Strix Halo (gfx1151/RDNA3.5) 提供 ComfyUI ROCm 支持
- ドキュメント: `docs/zh/comfyui-strix-halo.md`
- パッケージ定義: `packages/comfyui-strix-halo.nix`
## モジュール
### comfyui-rocm-patch
- 定義: `modules/comfyui-rocm-patch.nix`
### comfyui-strix-halo
- 定義: `modules/comfyui-strix-halo.nix`
- ドキュメント: `docs/zh/comfyui-strix-halo.md`
### llama-cpp-rocm
- 定義: `modules/llama-cpp-rocm.nix`
- ドキュメント: `docs/zh/llama-cpp-rocm.md`
### obs-bilibili-stream
- 定義: `modules/obs-bilibili-stream.nix`
- ドキュメント: `docs/zh/obs-bilibili-stream.md`
### opencode-telegram
- 定義: `modules/opencode-telegram.nix`
- ドキュメント: `docs/zh/opencode-telegram.md`
### rog-control-center-fix
- 定義: `modules/rog-control-center-fix.nix`
- ドキュメント: `docs/zh/rog-control-center-fix.md`
### ruyi
- 定義: `modules/ruyi.nix`
- ドキュメント: `docs/zh/ruyi.md`
## オーバーレイ
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
## スキル
### nixkits-check-updates
检查上游软件更新并自动升级
- 定義: `skills/nixkits-check-updates/SKILL.md`
- ドキュメント: `docs/zh/skills/nixkits-check-updates.md`
### nixkits-skills
NixKits 技能安装器（本地/在线）
- 定義: `skills/nixkits-skills/SKILL.md`
- ドキュメント: `docs/zh/skills/nixkits-skills.md`
### nixos-modern-cli
NixOS 现代 CLI 操作指南（面向 AI 模型）
- 定義: `skills/nixos-modern-cli/SKILL.md`
- ドキュメント: `docs/zh/skills/nixos-modern-cli.md`
### recover-nixos-config
从 Nix store 恢复误删的 /etc/nixos 配置
- 定義: `skills/recover-nixos-config/SKILL.md`
- ドキュメント: `docs/zh/skills/recover-nixos-config.md`
### translate-katalish
ｶﾀﾘｯｼｭ 翻译（半角片假名逐词机械替换英文ドキュメント）
- 定義: `skills/translate-katalish/SKILL.md`
- ドキュメント: `docs/zh/skills/translate-katalish.md`
### translate-pseudocn
偽中国語翻译（日语假名剥离 + 语序转换）
- 定義: `skills/translate-pseudocn/SKILL.md`
- ドキュメント: `docs/zh/skills/translate-pseudocn.md`
### write-maintenance-log
按 NixKits 规范撰写维护日志（软件更新 + 错误修复）
- 定義: `skills/write-maintenance-log/SKILL.md`
- ドキュメント: `docs/zh/skills/write-maintenance-log.md`
### write-project-docs
按 NixKits 风格为任意项目编写多语言ドキュメント系统
- 定義: `skills/write-project-docs/SKILL.md`
- ドキュメント: `docs/zh/skills/write-project-docs.md`
## Flake 出力
```nix# packages: codewhale kitsfmt mcp-searxng obs-bilibili-stream opencode-telegram ruyi comfyui-strix-halo# nixosModules: comfyui-rocm-patch comfyui-strix-halo llama-cpp-rocm obs-bilibili-stream opencode-telegram rog-control-center-fix ruyi# overlays: default llama-cpp-rocm mihomo-alpha rog-control-center-fix ruyi-nixos-compat# nixpkgs = github:NixOS/nixpkgs/nixos-unstable# flake-utils = github:numtide/flake-utils# llama-cpp-ver = https://api.github.com/repos/ggml-org/llama.cpp/releases/latest# mihomo-ver = https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha```
## 多言語ドキュメント
| 言語 | コード | ディレクトリ | 対象 ||------|------|------|---------|| 中国語 | zh | `docs/zh/` | ベースライン言語、全ドキュメントのソース || 英語 | en | `docs/en/` | 英語ユーザー；カタリッシュ翻訳のソース || 日本語 | ja | `docs/ja/` | 日本語ユーザー；偽中国語翻訳のソース || カタカナ英語 | katalish | `docs/katalish/` | カタカナ英語（機械的英→カタカナ変換） || 偽中国語 | pcn | `docs/pcn/` | 偽中国語（仮名除去＋SOV→SVO） |拡張言語（katalish、pcn）は `translate-*` スキルが `write-project-docs` を通じて自動検出します。
## 使い方
### NixOS モジュール
```nix# flake.nix{  inputs = {    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";    nix-kits.url = "github:Kihara777/NixKits";  };  outputs = { nixpkgs, nix-kits, ... }: {    nixosConfigurations.example = nixpkgs.lib.nixosSystem {      modules = [        nix-kits.nixosModules.ruyi      ];    };  };}```
### DevShell
```bashnix registry add nix-kits github:Kihara777/NixKitsnix develop nix-kits#ruyi```
## パッケージ↔オーバーレイ関係
| ソフトウェア | オーバーレイ | 関係 ||------|----------|------|| llama-cpp-rocm | `overlays/llama-cpp-rocm.nix` | 上流 ROCm バージョン動的追跡 || rcc-fix | `overlays/rog-control-center-fix.nix` | asusctl デバイスサポートパッチ || ruyi-nixos-compat | `overlays/ruyi-nixos-compat.nix` | NixOS ELFインタープリタ互換 || mihomo-alpha | `overlays/mihomo-alpha.nix` | Prerelease-Alpha 追跡 |
## 言語マップ
| 言語 | コード | ディレクトリ | 翻訳元 | スキル ||------|------|------|--------|---------|| 中国語 | zh | `docs/zh/` | — | — || 英語 | en | `docs/en/` | zh→en 手動 | — || 日本語 | ja | `docs/ja/` | zh→ja 手動 | — || カタカナ英語 | katalish | `docs/katalish/` | en→kata 自動 | translate-katalish || 偽中国語 | pcn | `docs/pcn/` | ja→pcn 自動 | translate-pseudocn |