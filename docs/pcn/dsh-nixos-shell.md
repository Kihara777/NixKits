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
| `tools` | 任意 POSIX 工具名列表、命令 `nix shell nixpkgs#<pkg>… --command` 経由実行。白名單：python3、python、grep、ls、cat、head、tail、wc、tr、sort、mkdir、rm、cp、mv、find、env、sed、bash、awk、git、curl、jq、ripgrep、rsync、htop、tree、unzip |
| `workdir` / `timeoutMs` / `env` | 作業目録 / 超時（設定上限）/ 追加環境変数（注入 NixOS PATH 合併） |
| `run_in_background` | `true` 時 dsh-jobs 後台任務登録 job id 即返（`job_output` 読取・`job_kill` 停止、無 client 側超時 — `sudo: true` 任務守護側請求毎上限）。`nixos-rebuild` 等長命令向 — 実行時間超工具結果喪失防。本地任務増分輸出対応；`sudo: true` 任務守護協議 v3 実行、`job_kill` 明示帯内取消行令守護殺子進程。**注意**：rebuild 活性化段 dsh service 再起（插件路徑焼込 service 単元）、進程内 job 記録清空 — rebuild 後 `nixos_cli op=generations` 検証完成。命令自體守護内継続完走（断絶絶不取消） |
| `sudo` / `justification` | sudo 守護套接字検出時有効：`sudo: true` 外部 root 実行器路由、`justification` 必填結果回顕 |

挙動：PATH 解決 `bash` 優先、失敗時 Nix store shell 路徑回退（内建工具 `spawn bash ENOENT` 修正）；全子進程完全 NixOS PATH 注入；輸出截断 + 溢出文件。

### nixos_cli — 読取専用 NixOS 診断

| op | 説明 |
|----|------|
| `capabilities` | nixos / nix-command / 解決 shell / sudo 守護検出、推奨 rebuild 命令与伝統→現代命令対照返 |
| `system-status` | `systemctl is-system-running` + 失敗単元一覧 |
| `generations` | 系統 profile 世代一覧（新→旧）。`limit` 既定 20・上限 200、現在世代与総数返 |
| `journal` | 指定 unit 日誌末尾（`unit` 必填、`*`/`%` 通配対応、末尾 `@` 自動 `*` 補全模板全實例対象。`lines` 既定 50 上限 500） |
| `audit-store-paths` | `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` 内 `/nix/store/` 絶対路徑（gc 後無効化）走査、git 憑証助手形式検査修正規則提示 |

変更性維護（`nix store gc`、`nix store optimise`、rebuild）`nixos_shell` `sudo: true` 実行 — 昇格常明示 justification 付。

## 架構

```
nixos-shell 插件
├─ nixos_shell ── 本地: ctx.subprocess（PATH 注入 + 溢出/超時）
│                └─ sudo: Unix 套接字 → nixkits-sudo@.service（root、systemd 套接字活性化）
└─ nixos_cli ──── 読取専用本地実行（systemctl / nix-env / journalctl / 設定文件走査）
```

sudo 守護 = systemd 套接字活性化 root 実行器（`nixkits-sudo-exec.js`、插件同梱）：接続毎 1 請求 JSON 協議（v3：client 請求 1 行写入連接開保持、守護首行即実行完了応答返終了；請求後一切輸入行 = 明示取消 — 子進程**進程組全体** SIGTERM、寛限後 SIGKILL。僅殺 shell 包装則管道写端継承孤児孫進程殘留守護応答不能故 — `job_kill` 帯内取消機構）。**断絶非取消**：rebuild 活性化段 dsh service 再起連接切断、断絶＝取消処理則 switch 活性化中途被殺部分活性化殘留、故対向消失時子進程分離態継続完走（守護側上限 6 時間、rebuild 命令自動用）。訪問制御套接字文件（dsh service 用户所有、`0600`）。PATH 合併順：継承 env 先、明示 NixOS profile PATH 後（模版単元 systemd 既定 PATH 僅基礎 store 路徑）。

### rebuild 自動分離

`nixos_shell` 認識 `nixos-rebuild` / `nixos apply` 命令（`sudo: true`）自動包装 `systemd-run --collect` 瞬時単元（独立 cgroup）実行、呼出即返単元名（結果含 `detachedUnit`）。理由：活性化段 switch-to-configuration 再起 dsh.service **且** stop/start nixkits-sudo.socket（模版変更 → socket 再起新連接用新守護）。rebuild 経守護実行則 socket 停止連同 switch 進程自身殺（@ 實例与子進程同 cgroup）、活性化中途死 socket 不能自復。分離実行則活性化完走 socket 自復。進捗 `nixos_cli op=journal unit=nixkits-rebuild-<id>` 看、結果 `nixos_cli op=generations` 検証。

sudo 套接字**呼出時**検証非 apply 時：rebuild 活性化中 socket 暫時消失、該窓啟動 session 不永久失 `sudo` 參數——socket 復後即可用。

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

## Agent 預設

包同梱「NixOS模式」預設（`presets/nixos-mode/`、id `nixos`）：創造模式基盤、session 初期化時宿主 NixOS 検証——非 NixOS 全実行拒否工具守衛与拒否提示詞節登録、NixOS 開発指南提示詞節注入与本插件 2 工具（`nixos_shell` / `nixos_cli`）掛載。模組 `nixkits.dsh.presets.nixosMode = true` 一度限 seed `$DSH_HOME/.agent-presets/nixos`（用户後続編集尊重）：

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

門控 = 包内子路 `@kihara777/dsh-nixos-shell/nixos-gate`、預設組合内掛載、全局 session 無影響。

### 維護模式預設

包同梱「維護模式」預設（`presets/maintenance-mode/`、id `maintenance`）：NixOS模式基盤、追加 `maintenance-skills` 入口掛載——初期化時構築期嵌入倉庫 `skills/` 樹（単一來源、新規 session 常最新）自 runtime 技能 `write-project-docs`、`write-maintenance-log`、全 `translate-*` 言語拡張（apply 時自動発見）登録、倉庫維護工作流提示詞節（分割提交、push 後維護日誌、文書同期、汎化）注入。模組 `nixkits.dsh.presets.maintenanceMode = true` 一度限 seed `$DSH_HOME/.agent-presets/maintenance`。
