# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | 偽中国語

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Node.js 応用（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.1-rc.2` |
| 開発通道 | `dsh-alpha 0.1.2-alpha.3`（npm `alpha` dist-tag） |
| 許可 | MIT |
| 命令 | `dsh` |

## 版本通道

NixKits 仿 ruyi 薄包装模式（本体定義 + 版本/hash 上書包装）複数 dsh 版本同時提供：

| 包 | 通道 | 版本 | 説明 |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.1.1-rc.2` | npm `latest` dist-tag、既定 |
| `pkgs.dsh-alpha` | alpha | `0.1.2-alpha.3` | npm `alpha` dist-tag、最新開発版追跡 |

```nix
# 本機最新開発版切替
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` 上流開発通道：内蔵拡張一覧版本毎変化（下文一覧 stable `0.1.1-rc.2` 対応。alpha 実行時実際読込基準）。更新前 [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) 確認推奨。

## 導入

```nix
# /etc/nixos/flake.nix — flake 入力追加与模組掛載
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # nixosConfigurations.<host>.modules 内:
  #   nixkits.nixosModules.dsh
}
```

```nix
# 模組設定（有効化時 dsh systemPackages 追加）
{ nixkits.dsh.enable = true; }
```

> **二進緩存**：flake `nixConfig` 緩存（`nixkits.cachix.org`）宣言済。初回構築時 Nix 有効化促。手動：`cachix use nixkits`。

## 使用

```bash
dsh --help
dsh web   # 瀏覧器 UI 起動
```

## 服務設定

常駐 web 服務実行 `nixkits.dsh` module 使用。dsh RCE 安全 loopback のみ（`127.0.0.1:8615`）監聽、lighttpd 反代对外端口 `8625` 公開（防火牆自動開放）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh 拒否非 loopback
    port = 8615;          # 内部 loopback 端口
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外端口
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

### 局域网訪問（trustedHosts + 起動 URL）

dsh ≥ 0.1.2-alpha web UI 入口 Host authority 基盤 session cookie 認証使用、反代**Host 書換停止**（書換場合後端見 authority 瀏覧器実際訪問先不一致、cookie 反代越一致不能常時 401）。局域网機器 `http://<host>:8625` 訪問場合当該 authority `trustedHosts` 列挙必要。dsh 表示 token 起動 URL 127.0.0.1 限定。`launchUrlFile` 設定時部品 dsh 起動時（ExecStartPost 起動出力捕捉）局域网機器向認証 URL 当該書類書込：

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # 局域网 authority
    launchUrlFile = "/run/dsh/launch-urls";             # 起動 URL 出力書類
  };
}
```

> token dsh 再起動毎 rotation。交換済 session cookie 有効期限迄有効。

### 免認証入口（autoAuth）

`reverseProxy.autoAuth` lighttpd mod_magnet（部品 `enableMagnet` 版 lighttpd 自動切替）以 session cookie 無 homepage 要求 302 現在 launch token 注入、局域网機器手動認証不要直達。**此開關 dsh 入口認証無効化（token 秘密不再）**——local network 完全可信場合限定有効化、否則反代端口到達可能任意機器完全 dsh 訪問（RCE 面含）得：

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> 注意：autoAuth network 層安全施策（隔離 LAN 等）訪問境界担当前提。

> **PATH**：部品 service 完全 NixOS PATH（`/run/current-system/sw/bin` 等）自動注入。無場合 systemd 既定 PATH bash 発見不能、内建 bash 工具 `spawn bash ENOENT` 失敗。

> **HOME**：service HOME 実行用户実家（`users.users.<user>.home`、無場合 dshHome 回退）指、代理用户自身工具環境継承——git/gh 憑証（`~/.config/gh`）、`~/.gitconfig`、npm/ssh 設定全 `$HOME` 解決。HOME dshHome 指向場合 git gh credential helper 憑証発見不能 push 失敗。

## 插件宣言管理

dsh 插件 `cordis.patch.yml` runtime hot reload（再起動不要）。`nixkits.dsh.plugins` 宣言 on/off 与設定：

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # 無効化
    settings."dsh-web-app" = { printUrl = false; };           # 設定覆写
    extraPatch = "...";  # 生片段（MCP insert 列表等）
  };
}
```

| 選項 | 説明 |
|------|------|
| `disabled` | 無効化 plugin entry id、`- id: <id> / disabled: true` 描画 |
| `settings` | plugin config 覆写（id → JSON、YAML flow style） |
| `packages` | 第三者插件包：dsh node_modules 注入 + 組合行生成（下記） |
| `extraPatch` | 生 cordis.patch.yml 片段（MCP server 等） |

### 第三者插件包

`plugins.packages` 第三者 npm 插件包 dsh node_modules 樹注入（組合行 install root 自包名解決、包実目録存在必要 — 符号連結 Node realpath 插件自身 store 路戻、peer 解決壊）、生成 cordis.patch.yml 組合行自動登録：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nixos-shell;           # NixKits 包（npm 構築）
    id = "nixos-shell";                   # cordis.patch.yml entry id
    name = "@kihara777/dsh-nixos-shell";  # 行参照 npm 包名
  }];
}
```

> **dsh ≥ 0.1.2-alpha 插件互換性**：`ctx.connection.rpc.intercept` shared RPC channel interceptor 排他（1 channel 1 個限定、再登録 throw）、`/api` 内建 typert-gateway 既占有。RPC 方法提供第三者插件宜用精確 fetch route（`ctx.connection.fetch.register` `/api/<plugin>/<method>` 等登録、`{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` RPC envelope 契約自前実装）——channel interceptor 奪取時内建 interceptor 押退、全 llm/session 等 RPC 404。插件 `@deepseek-ai/dsh-tools` 等 peer 依存宿主 dsh 通道一致必要。

### 插件更新与零再起活性化

插件包経**安定掛載点**読込：activation script 毎回 switch/boot `/run/dsh/current`（dsh 本体与插件樹）与 `/run/dsh/nixos-shell`（sudo 実行脚本）符号連結翻當前世代 store 路（GC 安全：目標常當前 toplevel 閉包内、回滚自翻旧代路）。`dsh.service` 与 `nixkits-sudo@.service` 単元定義僅参照該安定路、故**插件包更新不変単元内容**——switch-to-configuration 不再起 dsh、不 stop/start sudo socket、活性化零中断在途工具呼出。

代価与配套：dsh 長駐進程、插件更新反映需明示 `systemctl restart dsh`（`nixos_shell` 該命令自動分離瞬時単元、呼出先於再起返）。sudo 実行器接続毎生成、新連接自動新脚本、無需再起。

## NixKits 插件

倉庫内 dsh 向開発独立插件**本文書展開不**、各插件独立文書維持（mount 方式上文 `plugins.packages` 参照）：

| 插件 | 説明 | 文書 |
|------|------|------|
| dsh-nixos-shell | NixOS 場景能力統合：`nixos_shell` 実行器（PATH 注入 / `nix shell` 工具引導 / sudo 守護路由）+ `nixos_cli` 読取専用診断；NixOS模式 / 維護模式二 Agent 預設同梱 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量面板「用量 / 余额」切替：帳戶残高、日 / 月 / 30 日内消耗図表与音声放送（音声 pack 形式指南含） | [dsh-api-balance.md](dsh-api-balance.md) |

## Agent 預設

`nixkits.dsh.presets` dsh-nixos-shell package 同梱 Agent 預設 **seed-once** 方式 `$DSH_HOME/.agent-presets/<id>` 書込（対象不存在時限定 copy、用戶後續編輯尊重）：

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;       # id `nixos` — NixOS模式
    maintenanceMode = true; # id `maintenance` — 維護模式（NixOS模式派生）
  };
}
```

| 預設 | 説明 |
|------|------|
| NixOS模式（id `nixos`） | 初期化時 NixOS 宿主検証（非 NixOS 理由明示全請求拒否）；`nixos_shell` / `nixos_cli` 与 NixOS 高效開発 prompt 読込 |
| 維護模式（id `maintenance`） | NixOS模式 base；`write-project-docs` / `write-maintenance-log` / `translate-*` 技能（build 期嵌入倉庫 `skills/` tree、新 session 常最新）与倉庫維護工作流 prompt 注入 |

預設詳細動作、組合構造与派生維持規則 [dsh-nixos-shell.md](dsh-nixos-shell.md) 参照。

## sudo 守護

dsh 沙箱内 `sudo` setuid 喪失、代理昇格不能（例：`nixos-rebuild`）。`sudo.enable` systemd **套接字激活型 root 実行器**（`nixkits-sudo@.service`、接続毎 `nixkits-sudo-exec` 実行）配備、dsh service `NIXKITS_SUDO_SOCKET` 注入。nixos-shell 插件初期化時該套接字検出、存在時 `sudo` 參數有効化請求路由：

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # 既定
  };
}
```

> **安全模型**：套接字文件 dsh service 用戶所有 `0600`（`SocketUser`/`SocketMode`）— 該用戶接続可、実質該用戶向免密 root 実行。用戶与代理挙動双方信頼可場合有効化。


## 插件清單

dsh 0.1.1-rc.2 内建插件 entry id（`nixkits.dsh.plugins.disabled` 有效値、`id -> 插件包`）：

> **清單生成方法**：`dsh --profile web --dump-default-config`（読取専用）輸出即 `id -> name` 形式；dsh 升級後再実行、以所装版本輸出為准。表中 `headless-runner` / `headless-startup` 二行来自 headless profile 組合、非 web profile 之 base + web-app patch 集。

```text
  agent -> @deepseek-ai/dsh-agent
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  agent-loop -> @deepseek-ai/dsh-agent-loop
  agent-presets -> @deepseek-ai/dsh-agent-presets
  api-gateway -> @deepseek-ai/dsh-host-apiproxy
  api-remotes -> @deepseek-ai/dsh-api-remotes
  approval -> @deepseek-ai/dsh-user-approval
  attachment-local -> @deepseek-ai/dsh-attachment-local
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  client-hmr -> @deepseek-ai/dsh-client-hmr
  client-runtime -> @deepseek-ai/dsh-client-runtime
  code-runtime -> @deepseek-ai/dsh-code-runtime-worker-thread
  command-compact -> @deepseek-ai/dsh-command-compact
  command-feedback -> @deepseek-ai/dsh-command-feedback
  command-goal -> @deepseek-ai/dsh-command-goal
  commands -> @deepseek-ai/dsh-commands
  compaction-basic -> @deepseek-ai/dsh-compaction-basic
  connection -> @deepseek-ai/dsh-client-connection
  cordis-client-runner -> @deepseek-ai/dsh-cordis-client-runner
  cordis-host-runner -> @deepseek-ai/dsh-cordis-host-runner
  credentials -> @deepseek-ai/dsh-credentials-local
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  headless-runner -> @deepseek-ai/dsh-headless
  headless-startup -> @deepseek-ai/dsh-headless/startup
  hmr -> @deepseek-ai/cordis-plugin-hmr
  jobs -> @deepseek-ai/dsh-jobs-local
  llm -> @deepseek-ai/dsh-llm
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  llm-retry -> @deepseek-ai/dsh-llm-retry
  locale -> @deepseek-ai/dsh-client-locale
  message-feedback -> @deepseek-ai/dsh-message-feedback
  modules -> @deepseek-ai/dsh-client-modules
  permission -> @deepseek-ai/dsh-permission-presets
  plan-mode -> @deepseek-ai/dsh-plan-mode
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  session -> @deepseek-ai/dsh-session
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  session-log-download -> @deepseek-ai/dsh-session-log-export
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  session-projection -> @deepseek-ai/dsh-session-projection
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-reference -> @deepseek-ai/dsh-session-reference
  session-stats -> @deepseek-ai/dsh-session-stats
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  settings -> @deepseek-ai/dsh-settings-file
  shell-env -> @deepseek-ai/dsh-shell-env
  skill -> @deepseek-ai/dsh-skill
  skill-badge -> @deepseek-ai/dsh-skill-badge
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  storage -> @deepseek-ai/dsh-storage
  storage-domain -> @deepseek-ai/dsh-storage-domain
  storage-json -> @deepseek-ai/dsh-storage-json
  subagent -> @deepseek-ai/dsh-subagent
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  subagent-spawn-in-process -> @deepseek-ai/dsh-subagent-spawn-in-process
  subprocess -> @deepseek-ai/dsh-subprocess-local
  system-prompt -> @deepseek-ai/dsh-system-prompt
  timeout-policy -> @deepseek-ai/dsh-tool-call-timeout-policy
  timer -> @deepseek-ai/cordis-plugin-timer
  token-meter -> @deepseek-ai/dsh-token-meter
  tool-bash -> @deepseek-ai/dsh-tool-bash
  tool-fs -> @deepseek-ai/dsh-tool-fs
  tool-fs-search -> @deepseek-ai/dsh-tool-fs-search
  tool-goal -> @deepseek-ai/dsh-tool-goal
  tool-jobs -> @deepseek-ai/dsh-tool-jobs
  tool-pwsh -> @deepseek-ai/dsh-tool-pwsh
  tool-ralph -> @deepseek-ai/dsh-tool-ralph
  tool-result-pruner -> @deepseek-ai/dsh-compaction-tool-result-pruner
  tool-skill -> @deepseek-ai/dsh-tool-skill
  tool-str-replace-editor -> @deepseek-ai/dsh-tool-str-replace-editor
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-subagent-report -> @deepseek-ai/dsh-tool-subagent-report
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-web -> @deepseek-ai/dsh-tool-web
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  tools -> @deepseek-ai/dsh-tools
  typert -> @deepseek-ai/dsh-typert-registry
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  typert-loader -> @deepseek-ai/dsh-typert-loader
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-commands -> @deepseek-ai/dsh-client-ui-commands
  ui-conversation -> @deepseek-ai/dsh-client-ui-conversation
  ui-cordis -> @deepseek-ai/dsh-client-ui-cordis
  ui-deliverables -> @deepseek-ai/dsh-client-ui-deliverables
  ui-goal -> @deepseek-ai/dsh-client-ui-goal
  ui-input-trigger -> @deepseek-ai/dsh-client-ui-input-trigger
  ui-jobs -> @deepseek-ai/dsh-client-ui-jobs
  ui-layout -> @deepseek-ai/dsh-client-ui-layout
  ui-message-feedback -> @deepseek-ai/dsh-client-ui-message-feedback
  ui-model-selection -> @deepseek-ai/dsh-client-ui-model-selection
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-skill -> @deepseek-ai/dsh-client-ui-skill
  ui-subagent -> @deepseek-ai/dsh-client-ui-subagent
  ui-theme -> @deepseek-ai/dsh-client-ui-theme
  ui-tool -> @deepseek-ai/dsh-client-ui-tool
  ui-trajectory -> @deepseek-ai/dsh-client-ui-trajectory
  ui-user-questions -> @deepseek-ai/dsh-client-ui-user-questions
  ui-workflow-run -> @deepseek-ai/dsh-client-ui-workflow-run
  ui-workspace -> @deepseek-ai/dsh-client-ui-workspace
  user-questions -> @deepseek-ai/dsh-user-questions
  web -> @deepseek-ai/dsh-web
  web-runtime -> @deepseek-ai/dsh-web-app
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  web-startup -> @deepseek-ai/dsh-web-app/startup
  webserver -> @deepseek-ai/dsh-host-webserver
  workflow-worker-thread -> @deepseek-ai/dsh-workflow-worker-thread
  workspace -> @deepseek-ai/dsh-workspace
```

## 設定宣言構成

dsh 設定菜單項目 `$DSH_HOME/settings.yaml`（文件备份、hot reload）格納。`nixkits.dsh.settings` 宣言構成（namespace → section）：

```nix
{
  nixkits.dsh.settings = {
    "web-search-deepseek" = {
      model = "deepseek-v4-flash";
      maxTokens = 8192;
    };
    "llm-deepseek" = {
      timeout = 10000;
    };
  };
}
```

- namespace 設定 UI セクション対応（`web-search-deepseek`、`llm-deepseek`、`ui-onboarding` 等）
- 値 JSON 互換データ（string/number/boolean/list/object）必須
- JSON（合法 YAML）描画、hot reload；空 `{}` 或欠落 schema 既定値 fallback


### 声明配置可能 host namespace

`nixkits.dsh.settings` **host 側 `settings.register` 登録済** namespace 唯一書込可——此等数値 `$DSH_HOME/settings.yaml` 配置、瀏覽器間一致。DSH 0.1.2-alpha 内建登録 namespace 与字段：

| namespace | 字段 | 説明 |
|-----------|------|------|
| `locale` | `language` 等 | 界面言語 |
| `ui-theme` | `dark`/`light`/`system`/`fontSize`/`preference`/`body` 等 | 外観与主題 |
| `ui-chat` | `transcriptView` 等 | 会話視図 |
| `ui-conversation` | `busyEnter`（`queue`/`steer`） | busy 時 Enter 動作 |
| `ui-onboarding` | — | 引導 step 状態 |
| `agent-presets` | — | Agent preset |

> **設置 menu 存儲層境界**：非設置 UI 全項目都能 `nixkits.dsh.settings` 声明配置。**dsh-api-balance 界面 / 語音設定**（語音提醒、底部統計条横 scroll、Enter 改行 + Shift+Enter 送信交換、mobile 会話切替時 keyboard 抑止、TTS backend）為**瀏覽器 localStorage 状態**（毎瀏覽器独立、既定有効、UI 内切替）——`settings.register` 系統**不経由**、故 `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` 此等**不覆盖**。此類「毎瀏覽器偏好」当該插件 `⚙ 設定` panel 内配置、或 device 別独立瀏覽器。
