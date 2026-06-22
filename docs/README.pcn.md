# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | [ｶﾀﾘｯｼｭ](README.katalish.md) | 偽中国語

NixKits — 軟体、修正、NixOS 部品、AI 符号化助手技能之収集。

## 追加

```nix
# 遠隔
inputs.nixkits.url = "github:Kihara777/NixKits";

# 局所
inputs.nixkits.url = "/home/kix/NixKits";
```

## 軟体

対応全 `lib.platforms.linux` — nixpkgs 自動追従。

| 軟体 | 説明 | 文書 |
|---|------|------|
| codewhale | DeepSeek V4 端末符号化代理 | [docs/ja/codewhale.md](ja/codewhale.md) |
| kitsfmt | Nix 整形器（AST 整列 + 最良実践自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向 MCP 伺服器 | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 直播拡張 | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向 Telegram Bot 依頼者 | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi | RuyiSDK 包管理者（RISC-V 開発道具） | [docs/ja/ruyi.md](ja/ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm 支援 | [docs/ja/comfyui-strix-halo.md](ja/comfyui-strix-halo.md) |

> ⚠️ comfyui-strix-halo、部品+修正、独立包非、故二進法貯蔵非包含。

## 開発

`nix develop` 即利用可能。先登録 registry：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 包 | `nix develop` |
|-----------|---------------|
| ruyi | `nix develop nixkits#ruyi` |

## 修正

独立上乗。`default` 非包含：

| 修正 | 説明 | 文書 |
|------|------|------|
| llama-cpp-rocm | 追跡上流最新版之 ROCm 加速 | [docs/ja/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | 修正 asusctl 之 2-in-1 装置体験 | [docs/ja/rcc-fix.md](ja/rcc-fix.md) |
| ruyi-nixos-compat | ruyi 之 NixOS 実行時互換性（ELF interpreter redirect + GCC 子過程修正） | [docs/ja/ruyi-nixos-compat.md](ja/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | 提供 ComfyUI ROCm 機能修正 | [docs/ja/comfyui-rocm-patch.md](ja/comfyui-rocm-patch.md) |
| rog-control-center-fix | 修正停止時 asusd 死活 | [docs/ja/rog-control-center-fix.md](ja/rog-control-center-fix.md) |

> ⚠️ 修正、上乗、変更上流 nixpkgs 包、独立構築非。故二進法貯蔵非包含。動的版追跡計画（llama-cpp-rocm 等）、hash 上流版毎変化、貯蔵固定不可。

## 技能

AI 符号化助手向：

> 本計画之技能、主中国語利用者與中国開源模型対象。全 SKILL.md 中国語記述。

| 技能 | 説明 | 文書 |
|------|------|------|
| nixkits-check-updates | 検査上流更新自動更新 | [docs/ja/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits 技能導入器（局所/線上） | [docs/ja/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS 現代 CLI 指南（AI 模型向） | [docs/ja/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除 /etc/nixos 設定、Nix store 自復元 | [docs/ja/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-katalish | 片仮名英語翻訳（英単語→半角片仮名機械置換） | [docs/ja/skills/translate-katalish.md](ja/skills/translate-katalish.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/ja/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様沿 MAINTENANCE.md 入口作成（軟体更新 + 誤修正） | [docs/ja/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意計画 NixKits 様式多言語文書作成 | [docs/ja/skills/write-project-docs.md](ja/skills/write-project-docs.md) |

## 功績

- **狐莉 (キツノリ)** — 作成與保守
- **小爪 (キツノメ)** — 設計・開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (キツノメ)** — 硬体推論基盤 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 許諾

[MIT](../LICENSE)
