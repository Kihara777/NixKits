# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md)  | 偽中国語

NixKits — 軟体、修正、NixOS 部品、AI 符号化代理技能之蒐集。

## 追加

```nix
# 遠隔
inputs.nixkits.url = "github:Kihara777/NixKits";

# 局所
inputs.nixkits.url = "~/NixKits";
```

## 軟体

全包既定 nixpkgs 平台対応（`lib.platforms.linux`）。一部包構造支援上流影響 — 各包文書構築徽章参照。

| 軟体 | 説明 | 文書 |
|---|------|------|
| blender-mcp | Blender 向 MCP 伺服器（自然言語操作） | [docs/pcn/blender-mcp.md](pcn/blender-mcp.md) |
| codewhale | DeepSeek V4 端末符号化代理 | [docs/pcn/codewhale.md](pcn/codewhale.md) |
| dsh | DeepSeek Harness（DSH）— 万物皆插件 | [docs/pcn/dsh.md](pcn/dsh.md) |
| dsh-nixos-shell | DSH 向 NixOS 操作統合插件（shell 実行、工具引導、sudo 守護路由、NixOS 診断） | [docs/pcn/dsh-nixos-shell.md](pcn/dsh-nixos-shell.md) |
| godot-ai | Godot 引擎 MCP server 与 AI 工具 | [docs/pcn/godot-ai.md](pcn/godot-ai.md) |
| kitsfmt | Nix 整形器（AST 整序 + 最善慣行自動修正） | [docs/pcn/kitsfmt.md](pcn/kitsfmt.md) |
| mcp-searxng | SearXNG 向 MCP 伺服器 | [docs/pcn/mcp-searxng.md](pcn/mcp-searxng.md) |
| obs-bilibili-stream | OBS Bilibili 配信拡張 | [docs/pcn/obs-bilibili-stream.md](pcn/obs-bilibili-stream.md) |
| opencode-telegram | OpenCode 向 Telegram Bot 依頼者 | [docs/pcn/opencode-telegram.md](pcn/opencode-telegram.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK 包管理器（RISC-V 開發工具）<br>stable 0.51.0 · beta 0.51.0-beta.20260714 · alpha 0.52.0-alpha.20260714 | [docs/pcn/ruyi.md](docs/pcn/ruyi.md) |


## 開発

`nix develop` 以即利用可能。先登録追加：

```bash
nix registry add nixkits github:Kihara777/NixKits
```

| 環境 | 命令 | 文書 |
|------|------|------|
| opencode | `nix develop nixkits#opencode` | [pcn/opencode-devshell.md](pcn/opencode-devshell.md) |
| ruyi | `nix develop nixkits#ruyi` | [pcn/ruyi-devshell.md](pcn/ruyi-devshell.md) |
| ruyi-beta | `nix develop nixkits#ruyi-beta` |  |
| ruyi-alpha | `nix develop nixkits#ruyi-alpha` | |

## 修正

独立上乗。`default` 未含：

| 修正 | 説明 | 文書 |
|------|------|------|
| llama-cpp-rocm | 上流最新版追跡 ROCm 加速 | [docs/pcn/llama-cpp-rocm.md](pcn/llama-cpp-rocm.md) |
| rcc-fix | asusctl 2-in-1 機器体験修正 | [docs/pcn/rcc-fix.md](pcn/rcc-fix.md) |
| comfyui-rocm | ComfyUI ROCm 機能修正提供 | [docs/pcn/comfyui-rocm.md](pcn/comfyui-rocm.md) |
| efl-cross-fix | efl 交叉编译符号生成道具不足修正 | [docs/pcn/efl-cross-fix.md](pcn/efl-cross-fix.md) |
| codewhale-sudo | overlay — codewhale v0.9.8 sudo 机能复元（ptrace 拦截器） | [docs/pcn/codewhale-sudo.md](pcn/codewhale-sudo.md) |
| breeze-black | Plasma 6 高対比 Breeze Black 障碍支援主題 | [docs/pcn/breeze-black.md](pcn/breeze-black.md) |

> ⚠️ 補丁全為 overlay、修改上流 nixpkgs 軟件包而非独立構建、不在二進制緩存中。動態追跡版本項目（如 llama-cpp-rocm）其 hash 随上流發布変化、無法緩存固定。

> ⚠️ 修正上乗、上流 nixpkgs 包変更、独立構築非。故二進緩衝未含。動的版追跡計画（llama-cpp-rocm 等）摘要毎上流版変化、緩衝固定不可。

## 技能

AI 符号化代理向：

> 本計画技能主中国語利用者及中国開源模型対象。全 SKILL.md 中国語記述。

| 技能 | 説明 | 文書 |
|------|------|------|
> ⚠️ **Claude Code** nixkits-skills 導入対象削除。利用者資料基国籍推論実装、安全境界越。参照 [nixkits-skills 文書](pcn/skills/nixkits-skills.md)。
| nixkits-check-updates | 上流更新確認自動更新 | [docs/pcn/skills/nixkits-check-updates.md](pcn/skills/nixkits-check-updates.md) |
| nixkits-skills | NixKits 技能導入器（局所/線上） | [docs/pcn/skills/nixkits-skills.md](pcn/skills/nixkits-skills.md) |
| nixos-modern-cli | NixOS 現代 CLI 手引（AI 模型向） | [docs/pcn/skills/nixos-modern-cli.md](pcn/skills/nixos-modern-cli.md) |
| recover-nixos-config | 削除済 /etc/nixos 設定 Nix store 自復元 | [docs/pcn/skills/recover-nixos-config.md](pcn/skills/recover-nixos-config.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/pcn/skills/translate-pseudocn.md](pcn/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様沿 MAINTENANCE.md 条目作成（軟体更新 + 誤修正） | [docs/pcn/skills/write-maintenance-log.md](pcn/skills/write-maintenance-log.md) |
| write-project-docs | 任意計画 NixKits 式多言語文書作成 | [docs/pcn/skills/write-project-docs.md](pcn/skills/write-project-docs.md) |

## 銘記

- **狐莉 (Kitsunori)** — 作成及保守
- **小爪 (Kitsunome)** — 設計・開発 feat. DeepSeek V4 Pro (Max)
- **小小爪 (Kitsunome)** — 硬体推論基盤 feat. llama-cpp-rocm: Qwen3.6-27B-MTP (UD-Q4_K_XL) · Qwen3.6-35B-A3B-MTP (UD-Q4_K_XL) · Qwen3.5-122B-A10B-MTP (UD-Q4_K_XL) · Qwen3-Coder-Next (UD-Q4_K_XL) · MiniMax-M2.7 (UD-Q2_K_XL)

## 許諾

[MIT](../LICENSE)
