# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md) | [Katalish](README.katalish.md) | Pseudo-Chinese

NixKits — 軟件補丁NixOS 模塊AI 技能合集

## 追加

```nix
# 
inputs.nix-kits.url = "github:Kihara777/NixKits";

# 
inputs.nix-kits.url = "/home/kix/NixKits";
```

## 軟件

`lib.platforms.linux` 対応 — nixpkgs 自動追従

|軟件|説明|文檔|
|---|------|------|
|codewhale|DeepSeek V4 端末|[docs/zh/codewhale.md](codewhale.md)|
|kitsfmt|Nix 格式化器AST + 自動修正|[docs/zh/kitsfmt.md](kitsfmt.md)|
|mcp-searxng|SearXNG 向 MCP 服務器|[docs/zh/mcp-searxng.md](mcp-searxng.md)|
|obs-bilibili-stream|OBS Bilibili 配信插件|[docs/zh/obs-bilibili-stream.md](obs-bilibili-stream.md)|
|opencode-telegram|OpenCode 向 Telegram Bot 客户端|[docs/zh/opencode-telegram.md](opencode-telegram.md)|
|ruyi|RuyiSDK 軟件包管理器RISC-V 開発工具|[docs/zh/ruyi.md](ruyi.md)|
|comfyui-strix-halo|AMD Strix Halo (gfx1151/RDNA3.5) ComfyUI ROCm 支持|[docs/zh/comfyui-strix-halo.md](comfyui-strix-halo.md)|

## 開発

`nix develop` 即利用可能註冊表追加：

```bash
nix registry add nix-kits github:Kihara777/NixKits
```

|軟件包|`nix develop`|
|-----------|---------------|
|ruyi|`nix develop nix-kits#ruyi`|

## 補丁

覆蓋層`default` 含：

|補丁|説明|文檔|
|------|------|------|
|llama-cpp-rocm|上流最新發佈追跡 ROCm 加速|[docs/zh/llama-cpp-rocm.md](llama-cpp-rocm.md)|
|rcc-fix|asusctl 2-in-1 設備体験修正|[docs/zh/rcc-fix.md](rcc-fix.md)|
|ruyi-nixos-compat|ruyi NixOS 運行時互換性ELF interpreter + GCC 子修正|[docs/zh/ruyi-nixos-compat.md](ruyi-nixos-compat.md)|
|mihomo-alpha|Prerelease-Alpha 追跡版工具|[docs/zh/mihomo-alpha.md](mihomo-alpha.md)|

## 技能

AI 向：

> 本項目技能主中国語中国対象 SKILL.md 中国語記述

|技能|説明|文檔|
|------|------|------|
|nixkits-check-updates|上流更新自動更新|[docs/zh/skills/nixkits-check-updates.md](skills/nixkits-check-updates.md)|
|nixkits-skills|NixKits 技能安裝器/|[docs/zh/skills/nixkits-skills.md](skills/nixkits-skills.md)|
|nixos-modern-cli|NixOS CLI 指南AI 向|[docs/zh/skills/nixos-modern-cli.md](skills/nixos-modern-cli.md)|
|recover-nixos-config|削除 /etc/nixos 設定 Nix store 復元|[docs/zh/skills/recover-nixos-config.md](skills/recover-nixos-config.md)|
|translate-katalish|英語翻訳英単語→半角機械置換|[docs/zh/skills/translate-katalish.md](skills/translate-katalish.md)|
|translate-pseudocn|偽中国語翻訳日本語→仮名除去＋語順変換|[docs/zh/skills/translate-pseudocn.md](skills/translate-pseudocn.md)|
|write-maintenance-log|NixKits 仕様沿 MAINTENANCE.md 作成軟件更新 + 修正|[docs/zh/skills/write-maintenance-log.md](skills/write-maintenance-log.md)|
|write-project-docs|任意項目 NixKits 多言語文檔作成|[docs/zh/skills/write-project-docs.md](skills/write-project-docs.md)|

## 作者

- **狐莉 ()** — 作成保守
- **小爪 ()** — 設計開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 ()** — 推論基礎設施 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 許可

[MIT](../LICENSE)