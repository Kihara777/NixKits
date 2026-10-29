# 狐莉模式 (Agent 預設)

[中文](../../zh/modes/foxli.md) | [English](../../en/modes/foxli.md) | [日本語](../../ja/modes/foxli.md)  | 偽中国語

> NixOS模式 派生 之「瑞士万能刀」預設：**日常保守・開発・逆工程 一体**。同時 **共同体 下放 能力 之 境界**——掌灯模式 此 派生、私有 適配層 只 追加。

## 基本情報

| 項目 | 値 |
|------|-----|
| 模式 id | `foxli` |
| 配布方法 | dsh-nixos-shell 包内 `presets/foxli-mode/preset.patch.yml`、`@deepseek-ai/dsh-agent-preset` 之 patch 行 一 |
| 有効化 選択肢 | `nixkits.dsh.presets.foxliMode = true` |
| 派生元 | [NixOS模式](nixos.md)（本文 + 固定 二 塊：**保守**・**逆工程**） |
| 依存包 | `nixkits.dsh.presets.reaPackage`（既定 `pkgs.rea`） |
| 文書 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)、[rea.md](../rea.md) |

## 三層 派生

```
NixOS模式（最小 NixOS 適配）
  └─ 狐莉模式（保守 + 開発 + 逆工程）   ← 本頁；共同体 境界 此 迄
       └─ 掌灯模式（Kitsunome 側：本頁 本文 + 私有 差分）
```

**為何 一 層 統合**：旧 保守模式 與 逆工程模式 各「NixOS + 一 塊」 形態。分離 状態 下流 二 回 派生、技能  LIST 二 本 維持 必要——而 **下流 副本 誰 見 無**（2026-10-21 三 技能 漏 発覚 原因 此）。

## 挙動

NixOS模式 全能力 上 **二 塊** 追加。

### 保守 塊

- **実行時 技能**：`maintenance-skills` 建構期 埋込 `skills/` 樹 自 `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates`、`upstream-audit`、`nixkits-package-upstream`、`agent-self-maintenance` 登録、`translate-*` 自動発見。
- **二層 保守 prompt**：`maintenance-workflow`（汎用、901）與 `maintenance-workflow-repo`（本 repo 約束、902）。判定 一言：**該規約 他 repo 亦 成立 可否？**

### 逆工程 塊

同梱 插件 `@kihara777/dsh-nixos-shell/rea-mcp`：

| 項目 | 値 |
|------|-----|
| 接続 時機 | `agent/session-start` —— **本預設 選択 会話 毎 一本**、終了 切断 |
| 転送 | stdio JSON-RPC、`args: ['mcp']` |
| 実行 文件 | `$REA_BIN_PATH`（模組 `pkgs.rea` 之 `bin/rea` 輸出） |
| 工具名 | `mcp__rea__<原名>`、**該 agent 之 scope** 登録 |

REA 之 207 個（6.8.0 之 `tools/list` 実測）全部 登録、`inputSchema` **原様** 渡 —— 「JSON Schema → dsh 簡略 spec」変換 無（壊 時 正当 呼出 静 拒否 為）。

**為何 `@deepseek-ai/dsh-mcp-client` 不用**：初版 該 方式。2026-10-20 実 deployment 実測：預設 **eager activation**（dsh 起動 4 秒後 `rea mcp` spawn、其時 会話 一 無）、工具 登録 root scope 落（**掌灯模式 会話** 亦 207 個 背負、請求 header 31 + 207 = **238**）。「模式」 意味 乃「選択 会話 只 持」、故 本層 自前 書。

## 前提

`pkgs.rea` 乃 NixKits overlay 由来。無 場合 `presets.reaPackage` 明示——求値 「attribute 'rea' missing」 明示 失敗。

`presets.foxliMode = true` 時 模組 `REA_BIN_PATH` dsh 服務 輸出、故 預設 本文 **store 路径 一切 不出現**。

## 検証状態

| 層 | 結果 |
|---|---|
| 預設 宣言 平台 受理 | ✅ `AgentPresetRegistry.mount()` OK |
| REA MCP 服務器 実際 起動 | ✅ dsh 起動 **4 秒** spawn（pid 実測、5 時間 以上 生存、8 本 pipe） |
| 207 個 工具 模型 要求 届 | ✅ 会話 記録 `request/header` 内 **207** 個（総数 238） |
| **本模式 会話 只 見** | ⏳ 会話 単位 `rea-mcp` 変更 後 検証待 |

## 有効化

```nix
{
  nixkits.dsh = {
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;
    presets.foxliMode = true;
  };
}
```

## 派生関係

組合 文件 = NixOS模式 之 `plugins:` 本文 + **固定 二 塊**（保守・逆工程、注釈 含）。其 以外 差異 許 無。`develop/check-preset-derivation.py` 字節 単位 照合、`nix flake check` 組込：

```python
PATCH_FOXLI_DELTA = PATCH_MAINTENANCE_DELTA + PATCH_REA_DELTA
```

**掌灯模式 之 派生 此 非**：Kitsunome 側 在、建構期 本頁 本文 読 私有 差分 追加。其 検査 向 側 repo 持。
