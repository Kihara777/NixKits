# NixKits

[中文](../README.md) | [English](README.en.md) | [日本語](README.ja.md)  | 偽中国語

NixKits — 軟体、修正、NixOS 部品、AI 符号化代理技能之蒐集。

## 追加

```nix
# 遠隔
inputs.nixkits.url = "github:Kihara777/NixKits";

# 局所
inputs.nixkits.url = "git+file:///path/to/NixKits";
```

## 軟体

平台対応 二種 分類：多数包 `lib.platforms.all` 宣言（平台制限 無）、上流二進 或 模組 制約 受 物（`codewhale`、`godot-ai`、`rea`）Linux 限定。構造支援 亦 包毎 異 — 各包文書 構築徽章 参照。

| 軟体 | 説明 | 文書 |
|---|------|------|
| blender-mcp | Blender 向 MCP 伺服器（自然言語操作） | [docs/pcn/blender-mcp.md](pcn/blender-mcp.md) |
| codewhale | DeepSeek V4 端末符号化代理 | [docs/pcn/codewhale.md](pcn/codewhale.md) |
| dsh | DeepSeek Harness（DSH）— 万物皆插件 | [docs/pcn/dsh.md](pcn/dsh.md) |
| dsh-alpha | DeepSeek Harness（DSH）— 開発通道（0.2.1-alpha.5） | [docs/pcn/dsh.md](pcn/dsh.md) |
| godot-ai | Godot 機関 MCP server 與 AI 工具 | [docs/pcn/godot-ai.md](pcn/godot-ai.md) |
| kitsfmt | Nix 整形器（AST 整序 + 最善慣行自動修正） | [docs/pcn/kitsfmt.md](pcn/kitsfmt.md) |
| opencode-telegram | OpenCode 向 Telegram Bot 依頼者 | [docs/pcn/opencode-telegram.md](pcn/opencode-telegram.md) |
| rea | 逆工程 CLI 與 MCP 服務器——依 agent 自応用挙動至原生二進制（静的解析不要外部機関） | [docs/pcn/rea.md](pcn/rea.md) |
| ruyi<br>ruyi-beta<br>ruyi-alpha | RuyiSDK 包管理器（RISC-V 開發工具）<br>stable 0.53.0 · beta 0.53.0-beta.20260917 · alpha 0.54.0-alpha.20260918 | [docs/pcn/ruyi.md](pcn/ruyi.md) |

## 插件

DeepSeek Harness（DSH）組件與軟体分開掲載（掛載方式 [docs/pcn/dsh.md](pcn/dsh.md)）：

| 插件 | 説明 | 文書 |
|------|------|------|
| dsh-nixos-shell | NixOS 操作統合（shell 実行、工具引導、sudo 守護路由、NixOS 診断） | [docs/pcn/dsh-nixos-shell.md](pcn/dsh-nixos-shell.md) |
| dsh-api-balance | API 用量残高——webui 用量圓環（送信按鈕左）添加「用量 / 残高」標籤切替、残高・当日 / 当月 / 30 日消耗與図表表示。platform token 預設本機瀏覽器登録状態自動掃描取得（手動連接回退）。**独立[repo](https://github.com/Kihara777/dsh-api-balance) 移転 済。本 repo 宣言的 install 用 薄 wrapper package 保持** | [docs/pcn/dsh-api-balance.md](pcn/dsh-api-balance.md) |

## 模式

Agent 預設（session 形態）插件同等級、各自独立文書持：

| 模式 | id | 説明 | 配布方式 | 文書 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時 NixOS 宿主検証（非 NixOS 全請求拒否）；`nixos_shell`/`nixos_cli` 與 NixOS 開発 prompt 読込 | dsh-nixos-shell 包内、patch 行 | [docs/pcn/modes/nixos.md](pcn/modes/nixos.md) |
| 狐莉模式 | `foxli` | NixOS模式 派生；**共同体 下放 能力 之 境界**——保守／文書／更新確認／上流貢献／自己保守 各技能 與 二層 保守 prompt 注入、`rea-mcp` 経由 REA 之 MCP 服務器 本会話 接続（約 207 個 `mcp__rea__*`、本会話 只 可視） | dsh-nixos-shell 包内、patch 行 | [docs/pcn/modes/foxli.md](pcn/modes/foxli.md) |
| 新聞三要素模式 | `news-three-elements` | 極簡模式派生之**読取専用**創作模式：「新聞三要素」必到三人主人公、素材優先（接続不能時 唯拒否）、素材共創 検索後 書直（検索無 退稿）、技能包 online 取得、開始時問答三択、簡体中文以外一律拒否 | **独立包** `dsh-preset-news-three-elements` | [docs/pcn/modes/news-three-elements.md](pcn/modes/news-three-elements.md) |

> 前二（NixOS模式 / 狐莉模式）dsh-nixos-shell 包 同梱、`nixkits.dsh.presets.nixosMode` / `.foxliMode` 各 `preset.patch.yml` patch 行 為 profile 之 `cordis.patch.yml` 併合（dsh 0.2.0 以降 **目録 copy 無**）；新聞三要素模式 独立包 `dsh-preset-news-three-elements` 配布、`nixkits.dsh.presets.newsThreeElements` 該 `share/dsh-agent-presets/news-three-elements` `$DSH_HOME/.agent-presets/` 組立、該 patch 行 相対路径 解決 供。詳細 [docs/pcn/dsh.md](pcn/dsh.md) 「模式」節参照。

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
| rcc-fix | asusctl 2-in-1 機器体験修正 | [docs/pcn/rcc-fix.md](pcn/rcc-fix.md) |
| asusd-pd-profile | 供電種別 依 平台段階選択（USB-C PD 與 原生 AC 区別） | [docs/pcn/asusd-pd-profile.md](pcn/asusd-pd-profile.md) |
| asusd-thermal-guard | 温度監視：過熱時 段階降格、冷卻後 復帰 | [docs/pcn/asusd-thermal-guard.md](pcn/asusd-thermal-guard.md) |
| comfyui | ComfyUI 之 ROCm 統合（GFX override / 機器権限 / 内核参數） | [docs/pcn/comfyui.md](pcn/comfyui.md) |
| efl-cross-fix | efl 交叉编訳符号生成道具不足修正 | [docs/pcn/efl-cross-fix.md](pcn/efl-cross-fix.md) |
| codewhale-sudo | overlay — codewhale v0.9.0 以降 阻止 sudo 机能 復元（ptrace 傍受） | [docs/pcn/codewhale-sudo.md](pcn/codewhale-sudo.md) |
| breeze-black | Plasma 6 高対比 Breeze Black 障碍支援主題 | [docs/pcn/breeze-black.md](pcn/breeze-black.md) |

> ⚠️ 補丁全為 overlay、修改上流 nixpkgs 軟件包而非独立構建、不在二進制緩存中。


## 技能

AI 符号化代理向：

> 本計画技能主中国語利用者及中国開源模型対象。全 SKILL.md 中国語記述。

| 技能 | 説明 | 文書 |
|------|------|------|
> ⚠️ **Claude Code** nixkits-skills 導入対象削除。利用者資料基国籍推論実装、安全境界越。参照 [nixkits-skills 文書](pcn/skills/nixkits-skills.md)。
| news-three-elements | 本物通信社報道形式 露風速報捏造——「報道三要素」必到三人主人公 巴蘭尼科夫・尤丁采夫・布亜諾夫 指（遊技機構要素 + 素材優先拒否服務） | [docs/pcn/skills/news-three-elements.md](pcn/skills/news-three-elements.md) |
| nix-flake-update-check | **汎用**：任意 nix flake 倉庫 的 上流更新確認 自動更新（builder 別 hash flow / flake.lock / 修正内蔵版 / nixpkgs 漂移 罠） | [docs/pcn/skills/nix-flake-update-check.md](pcn/skills/nix-flake-update-check.md) |
| nixkits-check-updates | NixKits 更新適配層：四言語文書、插件一覧、保守記録、過去 事故教訓（nix-flake-update-check 依存） | [docs/pcn/skills/nixkits-check-updates.md](pcn/skills/nixkits-check-updates.md) |
| nixkits-package-upstream | NixKits 上流貢献適配層：13 包 実現可能性台帳、許諾缺口処置、四言語同期（upstream-audit 依存） | [docs/pcn/skills/nixkits-package-upstream.md](pcn/skills/nixkits-package-upstream.md) |
| nixkits-skills | NixKits 技能導入器（局所/線上） | [docs/pcn/skills/nixkits-skills.md](pcn/skills/nixkits-skills.md) |
| upstream-audit | **汎用**：自前梱包軟体 上流 nixpkgs 提出（評価 → 監査 → dry-run → 実施。AI 貢献政策 by-name 要求 含） | [docs/pcn/skills/upstream-audit.md](pcn/skills/upstream-audit.md) |
| nixos-modern-cli | NixOS 現代 CLI 手引（AI 模型向） | [docs/pcn/skills/nixos-modern-cli.md](pcn/skills/nixos-modern-cli.md) |
| agent-self-maintenance | Agent 自己保守 五 仕組：日記 gate、開始時 照合、事実検査、自己観察、自己検査受領書 | [docs/pcn/skills/agent-self-maintenance.md](pcn/skills/agent-self-maintenance.md) |
| nix-packaging | 零 從 package 化：四層 受入、来源別 分岐、hash 二段階、本 repo 約束 與 罠 | [docs/pcn/skills/nix-packaging.md](pcn/skills/nix-packaging.md) |
| recover-nixos-config | 削除済 /etc/nixos 設定 Nix store 自復元 | [docs/pcn/skills/recover-nixos-config.md](pcn/skills/recover-nixos-config.md) |
| translate-pseudocn | 偽中国語翻訳（日本語→仮名除去＋語順変換） | [docs/pcn/skills/translate-pseudocn.md](pcn/skills/translate-pseudocn.md) |
| write-maintenance-log | NixKits 仕様沿 MAINTENANCE.md 条目作成（軟体更新 + 誤修正） | [docs/pcn/skills/write-maintenance-log.md](pcn/skills/write-maintenance-log.md) |
| write-project-docs | 任意計画 NixKits 式多言語文書作成 | [docs/pcn/skills/write-project-docs.md](pcn/skills/write-project-docs.md) |
| nixos-specialisation-tuning | NixOS specialisation 面設計、統一記憶域機器 llama.cpp 最適化 | [docs/pcn/skills/nixos-specialisation-tuning.md](pcn/skills/nixos-specialisation-tuning.md) |

## 銘記

- **狐莉 (Kitsunori)** — 作成及保守
- **小爪 (Kitsunome)** — 設計・開発 feat. DeepSeek V4.1 Flash
- **小小爪 (Kitsunome)** — 硬体推論基盤 feat. llama-cpp-rocm: DeepSeek-V4-Flash-Vision-Exp (UD-IQ3_S)

> [!NOTE]
> 关于 DeepSeek Harness (DSH) 生态 —— 小爪与小小爪使用 dsh-nixos-shell 插件，以及 NixOS模式 / 狐莉模式 Agent 预设武装了自己☆

## 許諾

[MIT](../LICENSE)

安全政策（**評価済 外部報告一覧** 含——解決済 誤検出 再受理 不）[`SECURITY.md`](../SECURITY.md) 参照。
