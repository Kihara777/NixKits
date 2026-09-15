# dsh-nixos-shell

[中文](../zh/dsh-nixos-shell.md) | [English](../en/dsh-nixos-shell.md) | [日本語](../ja/dsh-nixos-shell.md)  | 偽中国語

NixOS 場景能力 DeepSeek Harness（DSH）插件 — shell 実行・工具引導・sudo 守護路由・読取専用 NixOS 診断**単一插件統合**。機能要件 `nixos-modern-cli` 技能場景由来（宣言式不変 NixOS、極小 PATH、現代 CLI、系統維護、Nix store 路徑陷阱）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 種別 | DSH Host 插件（npm 包） |
| npm 名 | `@kihara777/dsh-nixos-shell` |
| 版 | `0.1.0` |
| 許可 | MIT |
| 要件 | 宿主 dsh 樹（`subprocess`/`timer`/`tools` 能力接点與 peer 依存） |
| 後継 | `dsh-nix-shell`（shell 工具 + sudo 守護）與 `dsh-skill-nixkits`（7 技能插件、廃止） |

## 工具

### nixos_shell — shell 実行器

| 參數 | 説明 |
|------|------|
| `command` | 実行 shell 命令（必填） |
| `tools` | 任意 POSIX 工具名列表、命令 `nix shell nixpkgs#<pkg>… --command` 経由実行。白名單：python3、python、grep、ls、cat、head、tail、wc、tr、sort、mkdir、rm、cp、mv、find、env、sed、bash、awk、git、curl、jq、ripgrep、rsync、htop、tree、unzip |
| `workdir` / `timeoutMs` / `env` | 作業目録 / 超時（設定上限）/ 追加環境変数（注入 NixOS PATH 合併） |
| `run_in_background` | `true` 時 dsh-jobs 後台任務登録 job id 即返（`job_output` 読取・`job_kill` 停止、無 client 側超時 — `sudo: true` 任務守護側請求毎上限）。`nixos-rebuild` 等長命令向 — 実行時間超工具結果喪失防。本地任務増分輸出対応；`sudo: true` 任務守護協議 v3 実行、`job_kill` 明示帯内取消行令守護殺子進程。**注意**：rebuild 活性化段 dsh service 再起（插件路徑焼込 service 単元）、進程内 job 記録清空 — rebuild 後 `nixos_cli op=generations` 検証完成。命令自體守護内継続完走（断絶絶不取消） |
| `sudo` / `justification` | sudo 守護套接字検出時有効：`sudo: true` 外部 root 実行器路由、`justification` 必填結果回顕 |

挙動：PATH 解決 `bash` 優先、失敗時 Nix store shell 路徑回退（内建工具 `spawn bash ENOENT` 修正）；全子進程完全 NixOS PATH 注入；輸出截断 + 溢出書類。

### nixos_cli — 読取専用 NixOS 診断

| op | 説明 |
|----|------|
| `capabilities` | nixos / nix-command / 解決 shell / sudo 守護検出、推奨 rebuild 命令與伝統→現代命令対照返 |
| `system-status` | `systemctl is-system-running` + 失敗単元一覧 |
| `generations` | 系統 profile 世代一覧（新→旧）。`limit` 既定 20・上限 200、現在世代與総数返 |
| `journal` | 指定 unit 日誌末尾（`unit` 必填、`*`/`%` 通配対応、末尾 `@` 自動 `*` 補全模板全實例対象。`lines` 既定 50 上限 500） |
| `audit-store-paths` | `~/.gitconfig`/`~/.bashrc`/`~/.zshrc`/`~/.profile` 内 `/nix/store/` 絶対路徑（gc 後無効化）走査、git 憑証助手形式検査修正規則提示 |

変更性維護（`nix store gc`、`nix store optimise`、rebuild）`nixos_shell` `sudo: true` 実行 — 昇格常明示 justification 付。

## 架構

```
nixos-shell 插件
├─ nixos_shell ── 本地: ctx.subprocess（PATH 注入 + 溢出/超時）
│                └─ sudo: Unix 套接字 → nixkits-sudo@.service（root、systemd 套接字活性化）
└─ nixos_cli ──── 読取専用本地実行（systemctl / nix-env / journalctl / 設定書類走査）
```

sudo 守護 = systemd 套接字活性化 root 実行器（`nixkits-sudo-exec.js`、插件同梱）：接続毎 1 請求 JSON 協議（v3：client 請求 1 行写入連接開保持、守護首行即実行完了応答返終了；請求後一切輸入行 = 明示取消 — 子進程**進程組全体** SIGTERM、寛限後 SIGKILL。僅殺 shell 包装則管道写端継承孤児孫進程殘留守護応答不能故 — `job_kill` 帯内取消機構）。**断絶非取消**：rebuild 活性化段 dsh service 再起連接切断、断絶＝取消処理則 switch 活性化中途被殺部分活性化殘留、故対向消失時子進程分離態継続完走（守護側上限 6 時間、rebuild 命令自動用）。訪問制御套接字書類（dsh service 利用者所有、`0600`）。PATH 合併順：継承 env 先、明示 NixOS profile PATH 後（模版単元 systemd 既定 PATH 僅基礎 store 路徑）。

### rebuild / dsh 再起自動分離

`nixos_shell` 認識 `nixos-rebuild` / `nixos apply` / `systemctl restart dsh` 命令（`sudo: true`）自動包装 `systemd-run --collect` 瞬時単元（独立 cgroup）実行、呼出即返単元名（結果含 `detachedUnit`）。理由：経守護実行則命令引起 dsh 再起或 socket 停止連同呼出鏈自身殺（@ 實例與子進程同 cgroup、或 harness 進程即本呼出宿主）、活性化中途死 socket 不能自復、呼出結果亦失。分離実行則進程完走。進捗 `nixos_cli op=journal unit=nixkits-rebuild-<id>` 看、結果 `nixos_cli op=generations` 検証。

分離呼出結果**不聲稱構築成敗**：返 `detached: true` + `detachedUnit` + `note` 且 `exitCode` `null`（systemd-run 僅交接——交接成功非構築成功）。実結果一律 journal/generations 検証。

模組側「安定掛載点」（dsh.md 参照）配合：插件包更新不変 dsh/sudo 単元内容、普通 rebuild 不再起何物。插件更新明示 `systemctl restart dsh`（同自動分離）反映、sudo 実行器接続毎生成新連接自動新脚本。

sudo 套接字**呼出時**検証非 apply 時：rebuild 活性化中 socket 暫時消失、該窓啟動 session 不永久失 `sudo` 參數——socket 復後即可用。

## 使用

`nixkits.dsh` 模組宣言式安裝推奨（node_modules 注入 + 組合行生成）：

```nix
{
  nixkits.dsh = {
    sudo.enable = true;                 # sudo 守護配備與 NIXKITS_SUDO_SOCKET 注入
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

包同梱「NixOS模式」預設（`presets/nixos-mode/`、id `nixos`）：創造模式基盤、session 初期化時宿主 NixOS 検証——非 NixOS 全実行拒否工具守衛與拒否提示詞節登録、NixOS 開発指南提示詞節注入與本插件 2 工具（`nixos_shell` / `nixos_cli`）掛載。模組 `nixkits.dsh.presets.nixosMode = true` 一度限 seed `$DSH_HOME/.agent-presets/nixos`（利用者後続編集尊重）：

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

### persona 行（預設身份）

両預設 組合 `@deepseek-ai/dsh-persona` 行掛載、該 session 身份 prompt 提供（部署既定 persona 遮蔽）:

```yaml
- id: persona
  name: '@deepseek-ai/dsh-persona'
  config:
    prefix: |-
      …
```

| 字段 | 型 | 既定値 | 説明 |
|------|------|--------|------|
| `prefix` | string | —（**必須**） | 身份 prompt 前置。欠落時 plugin 読込失敗（`$.prefix missing required value`） |
| `suffix` | string | `""` | 実行時 context 之後 付加之後置 |
| `complete` | boolean | `false` | `true` 時 persona 完全 prompt、実行時 context 付加無 |
| `includeRuntimeContext` | boolean | `true` | 実行時 context（model、作業 directory 等）付加可否 |

> **升級注意**：`prefix` dsh 0.1.5-alpha.2 以降**必須**（従前字段名 `text`）。preset 依然 `text` 記述時、persona plugin 読込失敗 **session 生成経路全体巻込**——`session/create` 失敗後、設定画面・llm 提供方一覧・session 履歴 全読込不可、前端 `llm/listProviders failed: Failed to fetch` 與 `commands/list` 無限再試現。**該症状「model 設定画面 error」與根本原因同一、network 或 reverse proxy 問題 誤診不可**（localhost 與 LAN 同受限、根本原因 server 側 session 生成、非入口認証）。dsh 升級後 preset 内各 plugin 行 config schema 検証必須。

### 維護模式預設

包同梱「維護模式」預設（`presets/maintenance-mode/`、id `maintenance`）：NixOS模式基盤、追加 `maintenance-skills` 入口掛載——初期化時構築期嵌入倉庫 `skills/` 樹（単一來源、新規 session 常最新）自 runtime 技能 `write-project-docs`、`write-maintenance-log`、`nixkits-check-updates`、全 `translate-*` 言語拡張（apply 時自動発見）登録、倉庫維護工作流提示詞節（分割提交、push 後維護日誌、文書同期、汎化）注入。模組 `nixkits.dsh.presets.maintenanceMode = true` 一度限 seed `$DSH_HOME/.agent-presets/maintenance`。

**派生関係**：維護模式組合書類 = NixOS模式組合末尾追加固定 `maintenance-skills` 行塊、両預設 `skills/` 目録逐書類一致——`develop/check-preset-derivation.py` 掛入 `nix flake check` 強制執行（NixOS模式変更後必須同步維護模式、見倉庫 AGENTS.md「预设」節）。

### 新聞三要素模式預設

**TASS、Meduza、iStories 綜合電** —— 匿名条件 倉庫維護者一名 本日、暗号名 `news-three-elements` 之預設（`presets/news-three-elements/`）同梱確認：**極簡模式派生**、**読取専用**——書込系呼出 一律「休暇中」回答、修繕費 守衛 立替 依。session 初期化毎 倉庫 `skills/news-three-elements/` 技能包全体 online 取得（失敗時 0/30/120 秒再試、以後 6 時間毎再確認）、開始時三択提示、簡体中文以外 請求 一切受理無。消息筋 依、三択以外之自由入力 何記 一律「不予置評」。注目 模組 `nixkits.dsh.presets.newsThreeElements = true` 以 `$DSH_HOME/.agent-presets/news-three-elements` 一度限 seed。締切時点 模組 同選項 関「不予置評」、然 既 下設定例 出現。

| 行 | 役割 |
|------|------|
| `persona`（`complete: true`） | 唯一 prompt 源：読取専用境界、開始三択暗号表、素材共同創作、簡体中文以外與其他全請求拒否 |
| `tool-fs` / `tool-fs-search` / `tool-web` / `tool-skill` / `tool-ask-user` | 読取専用 surface：`read`、`read_image`、`glob`、`grep`、`web_search`、`web_fetch`、`skill`、`ask_user_question` |
| `news-skill` | session 起動時技能包全体 online 取得（5 書類、8 秒上限）。先 局所最新副本（cache 優先、無時同梱 snapshot）登録、取得成功後差替；失敗時 0/30/120 秒再試、以後 6 時間毎再確認 |
| `news-opening` | session 初期化完了後三択提示、選択 `agent.followup()` 経由本 session 最初 user message 化 |
| `news-language` | `agent/pre-step` 以非簡体中文（漢字無 / 仮名 / 諺文）検出、拒否指示注入 |
| `readonly-gate` | 既定拒否実行 guard：許可一覧外一律拒否、`write` / `edit` 含 |

本倉庫 engineering desk 通報 依、記録価値有之設計制約三：**読取専用 `tools.restrict()` 非、実行 guard 以担保**——制限 狭義 継承物（global 層與祖先層）唯濾過、同一預設兄弟行登録物 効無。`dsh-tool-fs` 必 `read`/`read_image` 與 `write`/`edit` 同時登録、故書込側 実行境界 以外拒否不能。**簡体字與繁体字判読 model 委譲**（同一規則 persona 保持）——plugin 硬検出 判読不要之「漢字無 / 仮名 / 諺文」唯、中国語話者 誤拒否無。**預設同梱 plugin 相対行名**（`./plugins/*.js`）且依存 Node 組込 module 唯——組合 `baseUrl` 即預設目録、目録毎 `$DSH_HOME` 複製後 依然解決可能。
