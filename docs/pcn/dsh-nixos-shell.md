# dsh-nixos-shell

[中文](../zh/dsh-nixos-shell.md) | [English](../en/dsh-nixos-shell.md) | [日本語](../ja/dsh-nixos-shell.md)  | 偽中国語

NixOS 場景能力 DeepSeek Harness（DSH）插件 — shell 実行・工具引導・sudo 守護路由・読取専用 NixOS 診断**単一插件統合**。機能要件 `nixos-modern-cli` 技能場景由来（宣言式不変 NixOS、極小 PATH、現代 CLI、系統維護、Nix store 路徑陷阱）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH Host 插件（npm 包） |
| npm 名 | `@kihara777/dsh-nixos-shell` |
| 版本 | `0.1.0` |
| 許可 | MIT |
| 要件 | 宿主 dsh 樹（`subprocess`/`timer`/`tools` 能力接点与 peer 依存） |
| 後継 | `dsh-nix-shell`（shell 工具 + sudo 守護）与 `dsh-skill-nixkits`（7 技能插件、廃止） |

## 工具

### nixos_shell — shell 実行器

| 參數 | 説明 |
|------|------|
| `command` | 実行 shell 命令（必填） |
| `tools` | 任意 POSIX 工具名列表、命令 `nix shell nixpkgs#<pkg>… --command` 経由実行（python3、grep、sed、awk、git、jq、ripgrep 等） |
| `workdir` / `timeoutMs` / `env` | 作業目録 / 超時（設定上限）/ 追加環境変数（注入 NixOS PATH 合併） |
| `sudo` / `justification` | sudo 守護套接字検出時有効：`sudo: true` 外部 root 実行器路由、`justification` 必填結果回顕 |

挙動：PATH 解決 `bash` 優先、失敗時 Nix store shell 路徑回退（内建工具 `spawn bash ENOENT` 修正）；全子進程完全 NixOS PATH 注入；輸出截断 + 溢出文件。

### nixos_cli — 読取専用 NixOS 診断

| op | 説明 |
|----|------|
| `capabilities` | nixos-cli / nix-command / 解決 shell / sudo 守護検出、推奨 rebuild 命令与伝統→現代命令対照返 |
| `system-status` | `systemctl is-system-running` + 失敗単元一覧 |
| `generations` | 系統 profile 世代一覧（`/nix/var/nix/profiles/system`） |
| `journal` | 指定 unit 日誌末尾（`unit` 必填、`lines` 既定 50 上限 500） |
| `audit-store-paths` | `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` 内 `/nix/store/` 絶対路徑（gc 後無効化）走査、git 憑証助手形式検査修正規則提示 |

変更性維護（`nix store gc`、`nix store optimise`、rebuild）`nixos_shell` `sudo: true` 実行 — 昇格常明示 justification 付。

## 架構

```
nixos-shell 插件
├─ nixos_shell ── 本地: ctx.subprocess（PATH 注入 + 溢出/超時）
│                └─ sudo: Unix 套接字 → nixkits-sudo@.service（root、systemd 套接字活性化）
└─ nixos_cli ──── 読取専用本地実行（systemctl / nix-env / journalctl / 設定文件走査）
```

sudo 守護 = systemd 套接字活性化 root 実行器（`nixkits-sudo-exec.js`、插件同梱）：接続毎 1 請求、JSON 協議、訪問制御套接字文件（dsh service 用户所有、`0600`）。PATH 合併順：継承 env 先、明示 NixOS profile PATH 後（模版単元 systemd 既定 PATH 僅基礎 store 路徑）。

## 使用

`nixkits.dsh` 模組宣言式安裝推奨（node_modules 注入 + 組合行生成）：

```nix
{
  nixkits.dsh = {
    sudo.enable = true;                 # sudo 守護配備与 NIXKITS_SUDO_SOCKET 注入
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
  };
}
```

工具呼出：

```
nixos_shell(command = "nix flake check", tools = ["git" "jq"])

# 変更性維護：sudo 守護経由 root 実行
nixos_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")

nixos_cli(op = "capabilities")
nixos_cli(op = "journal", unit = "dsh", lines = 30)
nixos_cli(op = "audit-store-paths")
```
