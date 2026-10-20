# 逆向模式 (Agent 預設)

[中文](../../zh/modes/rea.md) | [English](../../en/modes/rea.md) | [日本語](../../ja/modes/rea.md)  | 偽中国語

> 维护模式 為 土台 之 逆工程 代理：维护模式 之**全能力** 上、REA（Reverse Engineer Anything）之 MCP 服務器 接続 本会話——工具名 `mcp__rea__*`、全量登録。

## 基本情報

| 項目 | 値 |
|------|-----|
| 模式 id | `rea` |
| 配布方法 | dsh-nixos-shell 包内 `presets/rea-mode/preset.patch.yml`、`@deepseek-ai/dsh-agent-preset` 之 patch 行 一 |
| 有効化 選択肢 | `nixkits.dsh.presets.reaMode = true` |
| 派生元 | [维护模式](maintenance.md)（組合 末尾 固定行 塊 追加） |
| 依存包 | `nixkits.dsh.presets.reaPackage`（既定 `pkgs.rea`） |
| 文書 | [rea.md](../rea.md)（包本体）、[dsh-nixos-shell.md](../dsh-nixos-shell.md)（本模式 配布 包） |

## 挙動

维护模式 全能力 上、**同梱 插件** `@kihara777/dsh-nixos-shell/rea-mcp` 一行 追加：

| 項目 | 値 |
|------|-----|
| 接続 時機 | `agent/session-start` —— **本預設 選択 会話 毎 一本**、会話 終了 切断 |
| 転送 | stdio JSON-RPC、`args: ['mcp']` |
| 実行 文件 | `$REA_BIN_PATH`（模組 `pkgs.rea` 之 `bin/rea` 輸出） |
| 工具名 | `mcp__rea__<原名>`、**該 agent 之 scope** 登録 |

結果 三：

- **全工具**：REA 之 207 個（6.7.0 之 `tools/list` 実測）全部 `mcp__rea__*` 登録、`inputSchema` **原様** 登録表 渡 —— 「JSON Schema → dsh 簡略 spec」変換 無。該種 変換器 壊 時 **正当 呼出 静 拒否** 為。工具表 長 乃 代償、本模式 「全部 欲」場面 向。
- **本模式 会話 只 持**：`rea-mcp` 自作 唯一 理由（下記）。
- **维护模式 機能 其 儘**：宿主 検証、`nixos_shell` / `nixos_cli`、文書・保守 記録 技能、四言語 約束。

### 為何 `@deepseek-ai/dsh-mcp-client` 不用

初版 乃 該 方式。2026-10-20 実 deployment 測 結果：

- 預設 乃 **eager activation** —— dsh 起動 4 秒後 `rea mcp` spawn、**其時 会話 一 無**；
- 工具 登録 root scope 落、**掌灯模式 会話** 亦 207 個 `mcp__rea__*` 背負（請求 header 31 + 207 = **238**）。

「模式」 意味 乃「選択 会話 只 持」、故 本層 自前 書：接続 與 登録 `agent.ctx` 束、会話 破棄 切。

## 前提

`pkgs.rea` 乃 NixKits overlay 由来（`nixpkgs.overlays = [ inputs.nixkits.overlays.default ]`）。overlay 無 場合 `presets.reaPackage` 明示——否 求値 乃「attribute 'rea' missing」 失敗。是 乃**明示的 失敗**、黙 飛 非。

`presets.reaMode = true` 時 模組 `REA_BIN_PATH` dsh 服務 輸出。故 預設 本文 中 **store 路径 一切 不出現**（本文 字節 単位 派生 可、Nix 無 機械 読 可 必要）。

## 既知 境界

[rea 包 文書](../rea.md) 同、此 繰返 無。誤読 容易 三：

| 事項 | 実際 |
|------|------|
| `rea doctor` 之 宿主 判定 | NixOS 上 `unsupported_host` 報告（上流 apt/dnf/pacman 系列 依 分配 識別）。**静的 解析 実測 通 可用**——是 乃 判定 而 非 実行 前提 |
| frida 動的 計装 | 本包 内 不可（離線 構築 + `--ignore-scripts`） |
| Hopper / Ghidra / IDA、JADX | 利用者 側 用意。JDK 與 `ps` 乃 `pkgs.rea` 同梱 |

## 検証状態

| 層 | 結果 |
|---|---|
| 預設 宣言 平台 受理 | ✅ `AgentPresetRegistry.mount()` OK |
| REA MCP 服務器 実際 起動 | ✅ deployment 後 dsh 起動 **4 秒** spawn（pid 実測、5 時間 以上 生存、dsh 與 8 本 pipe） |
| 207 個 工具 実際 模型 要求 届 | ✅ 会話 記録 之 `request/header` 内 `mcp__rea__*` **207** 個（工具 総数 238） |
| **本模式 会話 只 見** | ⏳ `rea-mcp` 変更 後 検証待、非 rea 会話 31 戻、rea 会話 238 應該 |

最初 二行 與 三行目 別 主張：過程 生存 乃 接続 生存 証拠 過、工具 要求 載 可否 請求 header 数 必要。
更 一 会話 載 與 本模式 会話 只 載 亦 別 主張、初版 正 該 処 失敗。

## 有効化

```nix
{
  nixkits.dsh = {
    # 預設 之 `@kihara777/dsh-nixos-shell/maintenance-skills` 行 乃 此 注入 無 解決 不能
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.maintenanceMode = true;   # 逆向模式 乃 维护模式 自 派生
    presets.reaMode = true;
  };
}
```

## 派生関係

逆向模式 之 組合 文件 = 维护模式 之 `plugins:` 本文 + **末尾 固定 `mcp-rea` 行 塊 追加**（注釈 含）。其 以外 差異 許 無。

```yaml
- id: mcp-rea
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: rea
    transport: stdio
    command: !!js "(process.env.REA_BIN_PATH || 'rea')"
    args: ['mcp']
    failOnStartupError: false
```

派生 鎖 乃**三段**：NixOS模式 → 维护模式 → 逆向模式。`develop/check-preset-derivation.py` 各段 字節 単位 照合、`nix flake check`（push 毎）組込。NixOS模式 変 而 维护模式 放置 乃 一段目 鳴、维护模式 変 而 本模式 放置 乃 二段目 鳴。追加 塊 自体 意図的 変 場合 脚本 之 `PATCH_REA_DELTA` 定数 更新。詳細 乃 `AGENTS.md` 之「预设」節。

## 実際 接続 確認

会話 中 `mcp__rea__*` 工具 有 無、或 設定 画面 中 `preset-rea` 行 之 `fiberPhase` 見。「設定 文件 書 有」乃「接続 成功」 非——激活 失敗 之 宣言 乃 roster 上 診断 付 残、黙 消 無。
