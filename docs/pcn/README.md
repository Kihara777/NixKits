# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](../README.ja.md) | [ｶﾀﾘｯｼｭ](README.katalish.md) | 偽中国語

NixKits — 軟体、NixOS 部品、AI 符号化之。

## 追加

```nix
# 
inputs.nixkits.url = "github:Kihara777/NixKits";

# 
inputs.nixkits.url = "/home/kix/NixKits";
```

## 軟体

之 `lib.platforms.linux` 対応 — nixpkgs 自動追従。

| 軟体 | 説明 | 文書 |
|---|------|------|
| codewhale | DeepSeek V4 端末符号化代理 | [docs/ja/codewhale.md](ja/codewhale.md) |
| kitsfmt | Nix （AST + 自動修正） | [docs/ja/kitsfmt.md](ja/kitsfmt.md) |
| mcp-searxng | SearXNG 向 MCP 伺服器 | [docs/ja/mcp-searxng.md](ja/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信拡張 | [docs/ja/obs-bilibili-stream.md](ja/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向 Telegram Bot 依頼者 | [docs/ja/opencode-telegram.md](ja/opencode-telegram.md) |
| ruyi | RuyiSDK 包管理者（RISC-V 開発道具） | [docs/ja/ruyi.md](ja/ruyi.md) |
| comfyui-strix-halo | AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm 支援 | [docs/ja/comfyui-strix-halo.md](ja/comfyui-strix-halo.md) |

> ⚠️ comfyui-strix-halo 部品+、独立包、含。

## 開発

`nix develop` 即利用可能。追加：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 包 | `nix develop` |
|-----------|---------------|
| ruyi | `nix develop nixkits#ruyi` |

## 

上乗。`default` 含：

| | 説明 | 文書 |
|------|------|------|
| llama-cpp-rocm | 上流最新追跡 ROCm | [docs/ja/llama-cpp-rocm.md](ja/llama-cpp-rocm.md) |
| rcc-fix | asusctl 之 2-in-1 体験修正 | [docs/ja/rcc-fix.md](ja/rcc-fix.md) |
| ruyi-nixos-compat | ruyi 之 NixOS 実行時互換性（ELF interpreter + GCC 子修正） | [docs/ja/ruyi-nixos-compat.md](ja/ruyi-nixos-compat.md) |
| comfyui-rocm-patch | ComfyUI ROCm 機能提供 | [docs/ja/comfyui-rocm-patch.md](ja/comfyui-rocm-patch.md) |
| rog-control-center-fix | 時之 asusd 修正 | [docs/ja/rog-control-center-fix.md](ja/rog-control-center-fix.md) |

> ⚠️ overlay、上流之 nixpkgs 包変更之、独立構築。之含。動的版追跡計画（llama-cpp-rocm）上流変化、固定不可。

## 

AI 符号化向：

> 本計画之主中国語中国之模型対象。之 SKILL.md 中国語記述。

| | 説明 | 文書 |
|------|------|------|
| nixkits-check-updates | 上流自動更新 | [docs/ja/skills/nixkits-check-updates.md](ja/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits （/） | [docs/ja/skills/nixkits-skills.md](ja/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS CLI （AI 模型向） | [docs/ja/skills/nixos-modern-cli.md](ja/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除 /etc/nixos 設定 Nix store 復元 | [docs/ja/skills/recover-nixos-config.md](ja/skills/recover-nixos-config.md) |
| translate-katalish | 英語翻訳（英単語→半角機械置換） | [docs/ja/skills/translate-katalish.md](ja/skills/translate-katalish.md) |
 | translate-pseudocn | [日本語](../README.ja.md) | [docs/ja/skills/translate-pseudocn.md](ja/skills/translate-pseudocn.md) | 
| write-maintenance-log | NixKits 仕様沿 MAINTENANCE.md 之作成（軟体更新 + 修正） | [docs/ja/skills/write-maintenance-log.md](ja/skills/write-maintenance-log.md) |
| write-project-docs | 任意之計画 NixKits 之多言語文書作成 | [docs/ja/skills/write-project-docs.md](ja/skills/write-project-docs.md) |

## 

- **狐莉 (之)** — 作成保守
- **小爪 (之)** — 設計開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (之)** — 硬体推論基盤 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 許諾

[MIT](../LICENSE)