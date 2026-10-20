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

维护模式 之 全能力 上 `@deepseek-ai/dsh-mcp-client` 之 行 一 追加：

| 項目 | 値 |
|------|-----|
| `serverName` | `rea` |
| `transport` | `stdio` |
| `command` | `$REA_BIN_PATH`（模組 `pkgs.rea` 之 `bin/rea` 為 輸出） |
| `args` | `['mcp']` |
| `failOnStartupError` | `false` |

結果 三：

- **全工具**：`mcp-rea` 行 REA 之 MCP 工具 全量 `mcp__rea__*` 為 登録。REA 服務器側 `tools/list` 実測 **207 個**（**「行 書 有」與「会話 実際 該 207 個 有」乃 別 主張**——下「検証状態」参照）。`dsh-mcp-client` 無 許可表 或 濾過 選択肢（README 與 config 字段表 確認済）、「一部 之 只」選 唯一 方法 乃 此 行 張 無 事——本模式 乃「全部 欲」場面 向、**工具表 長 乃 代償 而 非 欠陥**。
- **维护模式 之 機能 其 儘**：宿主 検証、`nixos_shell` / `nixos_cli`、文書 與 保守 記録 技能、四言語 約束 事 全 残。解析 結果 倉庫 戻 時、作業手順 既 在。
- **REA 落 而 預設 壊 無**：`failOnStartupError: false`。REA 起動 不能 而 维护模式 他 機能 使用 可、欠 乃 `mcp__rea__*` 之 群 只（記録 接続 失敗 残）。

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
| 預設 宣言 平台 受理 | ✅ `AgentPresetRegistry.mount()` OK 報告（一時 `DSH_HOME`、34 行 插件） |
| 包 解決 與 插件 読込 | ✅ 同 実行 確認——`@kihara777` 行 全 解決 可 |
| **MCP 接続 與 工具 登録** | ⚠️ **未検証**：`dsh headless` 単発任務 中 agent 自訂 預設 選択 無、故 預設 插件 有効化 無（実測：掛載後 `rea mcp` 子過程 **0**、模型 請求 本文 亦 `mcp__rea__*` 無）。本層 検証 須 **実際 逆向模式 選択** 会話 工具表 見 他 無。 |

此 区別 記 価値 有：**「mount() 成功」乃「該 預設 使用 agent 存在」 非**。
`mount()` 証明 乃 宣言 正当、包 解決 可能、平台 受理 迄。persona・工具・MCP 接続 会話 有効 証明 無。

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
