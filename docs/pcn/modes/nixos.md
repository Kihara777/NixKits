# NixOS模式（Agent 預設）

[中文](../../zh/modes/nixos.md) | [English](../../en/modes/nixos.md) | [日本語](../../ja/modes/nixos.md)  | 偽中国語

> 創造模式基盤之 NixOS 専用代理：session 初期化時宿主検証（非 NixOS 全実行拒否）、`nixos_shell` / `nixos_cli` 與 NixOS 効率開発 prompt 読込。

## 基本情報

| 項目 | 値 |
|------|-----|
| 模式 id | `nixos` |
| 配布方式 | dsh-nixos-shell 包内 `presets/nixos-mode/`、seed-once 方式 `$DSH_HOME/.agent-presets/nixos` copy |
| 有効化選項 | `nixkits.dsh.presets.nixosMode = true` |
| 派生元 | 創造模式（dsh 同梱 `cordis` 預設） |
| 文書 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（本模式配布之包） |

## 動作

- **宿主検証**：`nixos-gate` apply 時 `/etc/NIXOS` 與 `/etc/os-release` 読取；非 NixOS 則全実行拒否工具 guard 登録、拒否 prompt 節（他模式切替要求）注入——NixOS 未導入機器 安全掛載可能。
- **工具**：`nixos_shell`（PATH 注入 / `nix shell` 工具引導 / sudo 守護路由）與 `nixos_cli`（読取専用診断：capabilities / system-status / generations / journal / audit-store-paths）。
- **prompt**：NixOS 効率開発指南（宣言式系統之本質、包管理、路徑陷阱）。
- **技能**（5 個）：預設自身 的 `cordis-plugin-development`、`editing-cordis-compositions`、加 倉庫 `skills/` 樹 自 建構期 subset `skills-nixos/` 経由 登録 的 `nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning`。
- **組合**：創造模式完全工具面 + `persona` 行（`complete: true`）+ `nixos-gate` + `nixos-shell` 二行。

## persona 行（預設身份）

組合 `@deepseek-ai/dsh-persona` 行掛載、該 session 身份 prompt 付與（配備既定 persona 遮蔽）：

| 字段 | 型 | 既定値 | 説明 |
|------|------|--------|------|
| `prefix` | string | —（**必須**） | 身份 prompt 前置。欠落時 plugin 読込失敗（`$.prefix missing required value`） |
| `suffix` | string | `""` | 実行時 context 之後 付加之後置 |
| `complete` | boolean | `false` | `true` 時 persona 完全 prompt、実行時 context 付加無 |
| `includeRuntimeContext` | boolean | `true` | 実行時 context（model、作業目録 等）付加可否 |

> **升級注意**：`prefix` dsh 0.1.5-alpha.2 以降**必須**（従前字段名 `text`）。預設依然 `text` 記述時、persona plugin 読込失敗 **session 生成経路全体巻込**——`session/create` 失敗後、設定画面・llm 提供方一覧・session 履歴 全読込不可、前端 `llm/listProviders failed: Failed to fetch` 與 `commands/list` 無限再試現。**該症状「model 設定画面 error」與根本原因同一、network 或 reverse proxy 問題 誤診不可**；dsh 升級後 預設内各 plugin 行 config schema 検証必須。

## 導入

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
  };
}
```

rebuild 後、session 之模式選択器「NixOS模式」選択即可。

## 注意

- **seed-once**：`$DSH_HOME/.agent-presets/nixos` 不存在場合限定 copy；以後該目録 用戶所有（模組書込権限開放）、倉庫更新 上書無。
- 門控入口 包内子路 `@kihara777/dsh-nixos-shell/nixos-gate`、預設組合内限定掛載、全局 session 無影響。
