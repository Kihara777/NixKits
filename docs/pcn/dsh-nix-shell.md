# dsh-nix-shell

[中文](../zh/dsh-nix-shell.md) | [English](../en/dsh-nix-shell.md) | [日本語](../ja/dsh-nix-shell.md)  | 偽中国語

DeepSeek Harness（DSH）用 NixOS 対応 Shell 工具插件。NixOS 上 dsh 行程 PATH 常不含 bash（`/bin/bash` 不存在）、標準 bash 工具毎回 `spawn bash ENOENT` 失敗。本插件模型工具 `nix_shell` 登録：PATH 可解 bash 優先（健全環境普通 shell 工具退化）、失敗時 Nix store shell 路回退、各子行程 NixOS 完全 PATH 注入。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH 宿主插件（npm 包）|
| npm 名 | `@kihara777/dsh-nix-shell` |
| 版本 | `0.1.0` |
| 許可 | MIT |
| 工具名 | `nix_shell` |

## 架構

```
模型 ⇐ 工具登録（ctx.tools）⇐ 插件 ⇐ ctx.subprocess ⇐ bash -c <command>
                                      ⇑ ctx.timer（期限）
```

- 宿主専用插件：能力接点（`subprocess`/`timer`/`tools`）消費、服務不提供 — `tool-bash` 同様組合裸置可
- peer（`cordis`/`dsh-subprocess`/`dsh-timer`）宿主 dsh 樹提供（生態慣例一致）
- **沙箱実行策略不適用** — 標準沙箱 bash 工具起動不能宿主向橋渡。部品 PATH 修正（[dsh](dsh.md) 参照）展開後標準工具優先

## 設定

| 項目 | 既定 | 説明 |
|------|------|------|
| `toolName` | `nix_shell` | 登録工具名 |
| `shellPath` | `/run/current-system/sw/bin/bash` | PATH 解失敗時回退 shell |
| `pathEnv` | NixOS 布局 | 子行程注入 PATH（`$USER` 展開対応）|
| `defaultTimeoutMs` | `300000` | 既定超時 |
| `maxTimeoutMs` | `3600000` | 超時上限 |
| `stdoutMaxBytes` / `stdoutSpillMaxBytes` | 2 MiB / 16 MiB | 記憶上限與全量落盤上限 |
| `graceMs` | `5000` | 終止猶予 |

## 使用

`nixkits.dsh.plugins.packages` 宣言式安裝（node_modules 注入 + 組合行生成）：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nix-shell;
    id = "tool-nix-shell";
    name = "@kihara777/dsh-nix-shell";
  }];
}
```

手動組合行（npm 包 dsh 可解時）：

```yaml
- id: tool-nix-shell
  name: '@kihara777/dsh-nix-shell'
```

工具呼出：

```
nix_shell(command = "nix flake check", workdir = "/path/to/flake")
```
