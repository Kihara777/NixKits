# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | 偽中国語

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Node.js 応用（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版 | `0.1.5-rc.2` |
| 開発通道 | `dsh-alpha 0.1.6-alpha.2`（npm `alpha` dist-tag） |
| 許可 | MIT |
| 命令 | `dsh` |

## 版通道

NixKits 仿 ruyi 薄包装模式（本体定義 + 版/hash 上書包装）複数 dsh 版同時提供：

| 包 | 通道 | 版 | 説明 |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.1.5-rc.2` | npm `latest` dist-tag、既定 |
| `pkgs.dsh-alpha` | alpha | `0.1.6-alpha.2` | npm `alpha` dist-tag、最新開発版追跡 |

```nix
# 本機最新開発版切替
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> `dsh-alpha` 上流開発通道：内蔵拡張一覧版毎変化（下文一覧 stable `0.1.5-rc.2` 対応。alpha 実行時実際読込基準）。更新前 [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) 確認推奨。

## 導入

```nix
# /etc/nixos/flake.nix — flake 入力追加與模組掛載
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

常駐 web 服務実行 `nixkits.dsh` module 使用。dsh RCE 安全 loopback 唯（`127.0.0.1:8615`）監聽、lighttpd 反代对外端口 `8625` 公開（防火牆自動開放）：

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

> **HOME**：service HOME 実行利用者実家（`users.users.<user>.home`、無場合 dshHome 回退）指、代理利用者自身工具環境継承——git/gh 憑証（`~/.config/gh`）、`~/.gitconfig`、npm/ssh 設定全 `$HOME` 解決。HOME dshHome 指向場合 git gh credential helper 憑証発見不能 push 失敗。

## 插件宣言管理

dsh 插件 `cordis.patch.yml` runtime hot reload（再起動不要）。`nixkits.dsh.plugins` 宣言 on/off 與設定：

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

> **dsh ≥ 0.1.6-alpha.2 插件改名 硬失敗**：内建插件 `dsh-workflow-worker-thread` 於 0.1.6 `dsh-workflow-ptc` 改名（`id` 與 package 名同時変更、`config` 不変）、旧名 之行 対応先 既不存在。dsh ≤ alpha.1 解決不能 插件行 **黙 無視**——preset 其侭 読込、問題 痕跡 皆無。alpha.2 插件 resolver 此 **硬失敗** 変更、Agent preset 全体 mount 不能、session 作成時 `preset "…" failed to mount: row "…" names a plugin that cannot be resolved` 出 而已。dsh 更新 前 API 以 自己検査 可能：`agentPresets/list` 返 各 preset `broken` field 有（**此 field 無 場合 上流 健全性判定 通過、mount 可能**）。

### 插件更新與零再起活性化

插件包経**安定掛載点**読込：activation script 毎回 switch/boot `/run/dsh/current`（dsh 本体與插件樹）與 `/run/dsh/nixos-shell`（sudo 実行脚本）符号連結翻當前世代 store 路（GC 安全：目標常當前 toplevel 閉包内、回滚自翻旧代路）。`dsh.service` 與 `nixkits-sudo@.service` 単元定義僅参照該安定路、故**插件包更新不変単元内容**——switch-to-configuration 不再起 dsh、不 stop/start sudo socket、活性化零中断在途工具呼出。

代価與配套：dsh 長駐進程、插件／預設包更新反映需明示再起——**先 `systemctl daemon-reload`、次 `systemctl restart dsh`**（`nixos_shell` 後者自動分離瞬時単元、呼出先於再起返）。restart 単独 時 前世代 pre-start 脚本 実行 有、其 工程 正 `cordis.patch.yml` `$DSH_HOME` 複製 段（預設根 該文件 記載）、症状「服務確 再起、預設 仍旧」。再起後 `$DSH_HOME/profiles/<profile>/cordis.patch.yml` store 路 翻新 確認。sudo 実行器接続毎生成、新連接自動新脚本、無需再起。

## NixKits 插件

倉庫内 dsh 向開発独立插件**本文書展開不**、各插件独立文書維持（mount 方式上文 `plugins.packages` 参照）：

| 插件 | 説明 | 文書 |
|------|------|------|
| dsh-nixos-shell | NixOS 場景能力統合：`nixos_shell` 実行器（PATH 注入 / `nix shell` 工具引導 / sudo 守護路由）+ `nixos_cli` 読取専用診断；NixOS模式 / 維護模式二 Agent 預設同梱 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量面板「用量 / 余额」切替：帳戶残高、日 / 月 / 30 日内消耗図表與音声放送（音声 pack 形式指南含） | [dsh-api-balance.md](dsh-api-balance.md) |

## 模式

「模式」即 dsh 之 **Agent 預設**：各模式 = 一 session 形態、専用身份 prompt・工具面・prompt 節具備。插件同等級、各自独立文書持、相互影響無：

| 模式 | id | 説明 | 配布方式 | 文書 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時 NixOS 宿主検証（非 NixOS 全実行拒否）；`nixos_shell` / `nixos_cli` 與開発 prompt 読込 | dsh-nixos-shell 包内、seed-once | [modes/nixos.md](modes/nixos.md) |
| 維護模式 | `maintenance` | NixOS模式派生；`write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` 技能與維護工作流注入 | dsh-nixos-shell 包内、seed-once | [modes/maintenance.md](modes/maintenance.md) |
| 新聞三要素模式 | `news-three-elements` | 極簡模式派生之読取専用創作模式：「新聞三要素」必到三人主人公、素材優先（接続不能時 唯拒否）、素材共創 検索後 書直（検索無 退稿）、online 技能包、開始時問答、簡体中文以外一律拒否 | **独立包** `dsh-preset-news-three-elements`、roster 之預設 root 登録 | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` — NixOS模式
    maintenanceMode = true;   # id `maintenance` — 維護模式（NixOS模式派生）
    newsThreeElements = true; # id `news-three-elements` — 独立包、預設 root 登録
  };
}
```

> **二配布方式**：`nixosMode` / `maintenanceMode` dsh-nixos-shell 包 **seed-once** 方式 `$DSH_HOME/.agent-presets/<id>` copy（対象既存時 上書無、用戶後續編集尊重）；`newsThreeElements` **独立包** `dsh-preset-news-three-elements` 提供——模組 該 `share/dsh-agent-presets` `agent-presets` roster 之追加 root 登録、預設 store 直接読取、copy 無・書込無、更新即最新。各模式挙動・組合構造・維護規則 上表文書参照。

### dsh 0.2.0 於 預設格式之変化（準備段階）

dsh 0.2.0 Agent 預設 保持方式 再構築、**目録型預設経路 削除**：

| | 0.1.x（現行 deploy 使用中） | 0.2.0 |
|---|---|---|
| 預設形態 | `$DSH_HOME/.agent-presets/<id>/` 目録 | profile 用戶 patch 層（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）内 loader patch 一條 |
| 組合與 metadata | `agent.cordis.yml`（完全組合）+ `preset.yml`（`name` / `description`） | `@deepseek-ai/dsh-agent-preset` 行 `config.plugins`（插件行）+ `config.name` / `config.description` |
| 検出方法 | `@deepseek-ai/dsh-agent-presets`（複数形）root 走査 | Loader 樹 自身；複数形包 0.2.0 既不存在 |
| roster 並順 | 無 | `config.order`（内蔵預設 1–4 占有、預設間 一意必須） |

**現在状態：準備段階、未移行。** 本 repo 新格式 file `packages/dsh-nixos-shell/presets/{nixos-mode,maintenance-mode}/preset.patch.yml` 追加、旧 `agent.cordis.yml` / `preset.yml` 與 **二重併存**（0.1.x 経路 依然 旧 file 使用）；`develop/check-preset-derivation.py` 両経路 派生関係 同時検証。`modules/dsh.nix` 依然 0.1.x seed-once 方式 `$DSH_HOME/.agent-presets/<id>` copy、`packages/dsh.nix` 亦 `0.1.5-rc.2` 維持——**現時点 module／runtime 変更 一切 未着地**。各模式自体 説明 上表文書参照。

新格式 file 実機 `dsh 0.2.0-rc.2`（臨時 `DSH_HOME` + `agentPresets/list`）検証済：`nixos`（order 10）與 `maintenance`（order 11） `broken` 両者 空。一行 包名 不存在物 変更、或 `tool-fs-search` 必須項目 `sampleOverCapGlobResults` 削除 → 同一 entry 直 具体 `broken` 報告——判定基準自体 識別力 有。

旧 file 対 **三必然差異**（無修正 copy 破損）：

1. **`baseUrl` 意味変化**。0.1.x 系 預設自身 目録、0.2.0 系 実測 **profile 目録**（`$DSH_HOME/profiles/<profile>/`）。旧 file skills root `new URL('skills/', baseUrl)` 記述、無修正移行 → `<profile>/skills/` 指、技能 **静黙消失**；新 file `baseUrl` 従 `@kihara777/dsh-nixos-shell` 包 root 解析、`presets/<mode>/` 連結——解析失敗 全預設 `broken` 化、「技能無」状態 退化無。
2. metadata（旧 `preset.yml` `name` / `description`）`config.name` / `config.description` 移動。
3. `config.order` 新設。

**插件行毎 config schema 差異**（両経路 build 産物 各插件 `Config` schema 一行毎比較、`0.1.6-alpha.2` → `0.2.0-rc.2`）：

| 插件行 | 変化 | 本預設 影響 |
|--------|------|-------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | 任意項目 `promoteOnTimeout` 追加（既定 `true`） | 本預設 該 key 未設定 → 0.2.0 以降 foreground bash timeout 到達時 殺害無、**background job 昇格**。挙動変化、着地前 受入 或 明示固定 判断必要 |
| `dsh-tool-workflow` | 任意項目 `enableRunInBackground` 追加（既定 `true`） | 未設定 → background 能力 増加 |
| `dsh-tool-ask-user` | 「Config 無」 → `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }`（既定 `legacy` / `120`） | 未設定 → 旧版 同挙動 |
| `dsh-compaction-basic` | 任意項目 `headroomTokens` 追加（`modelPolicies[]` 内 同名 field 同時追加） | 未設定 → 調整項目 一個 増加 而已 |
| `dsh-tool-jobs` | `maxConsecutiveWakes` field 残存、schema 既定値出力 出現無 | 未設定 |
| `dsh-tool-fs-search` | **変化無**：`sampleOverCapGlobResults` **必須真偽値**、0.1.6 時点 既 如此 | 旧 file 既 `false` 持、新 file 同 引継 |
| 残 20 插件行 | schema 逐字同一 | 変更不要 |

> 比較対象：`dsh-tool-subagent` `backgroundMode` / `maxDepth` 合併型、`dsh-plan-mode` 自前実装 厳格 `{ section }` 検証（未知 key 即 error）、及 本 repo `@kihara777/dsh-nixos-shell` 三行 含、何 変化無。

**着地迄 残作業**（本 repo 未実施）：

- `modules/dsh.nix`：0.2.0 系 預設「目録 copy」非、「`$DSH_HOME/profiles/<profile>/cordis.patch.yml` patch entry 書込」也；
- 宿主面：0.1.x `agent-presets`（複数形）宿主行 及 該 settings namespace、0.2.0 内 `agent-preset-registry` 化——`default` 該行 **必須 config**（settings key 非）、settings 残存 `selectedDefault` 唯一（namespace 名 = 行 id）、`roots` 機構 全面消失（`settings.yaml` 内 既存 `agent-presets.default` 書換必要）；
- 独立包 `dsh-preset-news-three-elements` 亦 目録型預設、併 変換必要；
- 新格式 file persona 内「預設 `.agent-presets/<id>/` 居住」文言 0.2.0 成立無（file 内 `⚠️ 移行 TODO` comment 残置、意図的未修正——改変 場合 model 送信 prompt 変化 故）；
- 上表 挙動変化 既定値（`promoteOnTimeout` 等）一件毎 判断。

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

> **安全模型**：套接字書類 dsh service 用戶所有 `0600`（`SocketUser`/`SocketMode`）— 該用戶接続可、実質該用戶向免密 root 実行。用戶與代理挙動双方信頼可場合有効化。


## 插件清單

dsh 0.1.5-rc.2 内建插件 entry id（`nixkits.dsh.plugins.disabled` 有效値、`id -> 插件包`）：

> **清單生成方法**：`dsh --profile web --dump-default-config`（読取専用）輸出即 `id -> name` 形式；dsh 升級後再実行、以所装版輸出為准。本表対応 web profile 之 base + web-app patch 集。

```text
  agent -> @deepseek-ai/dsh-agent
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  agent-loop -> @deepseek-ai/dsh-agent-loop
  agent-presets -> @deepseek-ai/dsh-agent-presets
  api-remotes -> @deepseek-ai/dsh-api-remotes
  approval -> @deepseek-ai/dsh-user-approval
  attachment-local -> @deepseek-ai/dsh-attachment-local
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  client-hmr -> @deepseek-ai/dsh-client-hmr
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
  deepseek-llm-api-extensions -> @deepseek-ai/dsh-deepseek-llm-api-extensions
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  file-upload -> @deepseek-ai/dsh-client-file-upload
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  hmr -> @deepseek-ai/cordis-plugin-hmr
  jobs -> @deepseek-ai/dsh-jobs-local
  llm -> @deepseek-ai/dsh-llm
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  llm-retry -> @deepseek-ai/dsh-llm-retry
  locale -> @deepseek-ai/dsh-client-locale
  message-feedback -> @deepseek-ai/dsh-message-feedback
  modules -> @deepseek-ai/dsh-client-modules
  open-in-app -> @deepseek-ai/dsh-host-open-in-app
  permission -> @deepseek-ai/dsh-permission-presets
  plan-mode -> @deepseek-ai/dsh-plan-mode
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  plugin-package-inventory-deepseek -> @deepseek-ai/dsh-plugin-package-inventory-deepseek
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  resources -> @deepseek-ai/dsh-client-resources
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  session-controller -> @deepseek-ai/dsh-api-session-controller
  session -> @deepseek-ai/dsh-session
  session-log-deepseek -> @deepseek-ai/dsh-session-log-deepseek
  session-log-download -> @deepseek-ai/dsh-session-log-export
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  session-projection -> @deepseek-ai/dsh-session-projection
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-reference -> @deepseek-ai/dsh-session-reference
  session-stats -> @deepseek-ai/dsh-session-stats
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  session-turn-outline -> @deepseek-ai/dsh-session-turn-outline
  settings-controller -> @deepseek-ai/dsh-api-settings-controller
  settings -> @deepseek-ai/dsh-settings-file
  shell-env -> @deepseek-ai/dsh-shell-env
  skill-badge -> @deepseek-ai/dsh-skill-badge
  skill -> @deepseek-ai/dsh-skill
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  storage -> @deepseek-ai/dsh-storage
  storage-domain -> @deepseek-ai/dsh-storage-domain
  storage-json -> @deepseek-ai/dsh-storage-json
  subagent -> @deepseek-ai/dsh-subagent
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  subagent-model-selection-settings -> @deepseek-ai/dsh-tool-subagent/model-selection-settings
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
  tools -> @deepseek-ai/dsh-tools
  tool-skill -> @deepseek-ai/dsh-tool-skill
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-web -> @deepseek-ai/dsh-tool-web
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  typert -> @deepseek-ai/dsh-typert-registry
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  typert-loader -> @deepseek-ai/dsh-typert-loader
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-approval -> @deepseek-ai/dsh-client-ui-approval
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-chat -> @deepseek-ai/dsh-client-ui-chat
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
  ui-open-in-app -> @deepseek-ai/dsh-client-ui-open-in-app
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-schedule -> @deepseek-ai/dsh-client-ui-schedule
  ui-session -> @deepseek-ai/dsh-client-ui-session
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-sidebar-documentpreview -> @deepseek-ai/dsh-client-ui-sidebar-documentpreview
  ui-sidebar-files -> @deepseek-ai/dsh-client-ui-sidebar-files
  ui-sidebar-right -> @deepseek-ai/dsh-client-ui-sidebar-right
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
  web-fetch-http -> @deepseek-ai/dsh-web-fetch-http
  web-runtime -> @deepseek-ai/dsh-web-app
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  webserver -> @deepseek-ai/dsh-host-webserver
  web-startup -> @deepseek-ai/dsh-web-app/startup
  workflow-worker-thread -> @deepseek-ai/dsh-workflow-worker-thread
  workspace-controller -> @deepseek-ai/dsh-api-workspace-controller
  workspace -> @deepseek-ai/dsh-workspace
  workspace-files -> @deepseek-ai/dsh-api-workspace-files
```

## 設定宣言構成

dsh 設定菜單項目 `$DSH_HOME/settings.yaml`（書類备份、hot reload）格納。`nixkits.dsh.settings` 宣言構成（namespace → section）：

```nix
{
  nixkits.dsh.settings = {
    "web-search-deepseek" = {
      model = "deepseek-flash";
      maxTokens = 8192;
    };
    "llm-deepseek" = {
      timeout = 10000;
    };
  };
}
```

- namespace 設定 UI 節対応（`web-search-deepseek`、`llm-deepseek`、`ui-onboarding` 等）
- 値 JSON 互換資料（string/number/boolean/list/object）必須
- JSON（合法 YAML）描画、hot reload；空 `{}` 或欠落 schema 既定値 fallback


### 声明設定可能 host namespace

`nixkits.dsh.settings` **host 側 `settings.installSection` / `settings.register` 経由登録済** namespace 唯一書込可——此等値 `$DSH_HOME/settings.yaml` 格納、瀏覽器間一致。`0.1.6-alpha.2` 内蔵登録 全 **15** namespace 與字段（插件源碼之 `z.object({...})` / `Schema.object({...})` 自 逐一 実測抽出）：

| namespace | 字段 | 説明 |
|-----------|-----------|------|
| `agent-default-model` | `provider`、`model`、`reasoningEffort`（`off`/`low`/`high`/`max`） | 新規会話 既定模型 |
| `agent-loop` | `maxParallelToolCalls`（整数 ≥1、既定 10） | 単輪 並列道具呼出 上限 |
| `agent-presets` | `default`（預設 id；schema 既定値 無、組合行 `standard` 受止）、`modeSelectionEnabled`（真偽値、基線 true） | Agent 預設 與 切替入口 |
| `llm-deepseek` | `protocol`、`apiKeyEnv`、`baseURL`、`thinking`、`reasoningEffort`、`maxTokens`、`defaultContextWindow`、`streamIdleTimeoutMs`、`models`、`retryPolicy`、他 文件/画像 byte 予算 | 原生 DeepSeek adapter |
| `llm-pi-ai` | `providers`（辞書：route → provider profile） | pi-ai adapter 之 provider route 表（本機 llama-local route 在此） |
| `locale` | `preference`（BCP 47；内蔵 `zh`/`en`） | 界面言語 |
| `permission` | `defaultPreset`（**必須**；値 為 presets 表 之 key 名） | 権限預設 |
| `shell` | `cwd`（**既定値無**）、`timeoutMs`、`maxTimeoutMs`、`maxOutputBytes`、`maxSpillBytes`、`graceMs` | 本地 shell 実行器 制限（Linux 為 bash-local、win32 為 pwsh-local 且 `pwshPath` 増） |
| `subagent` | `maxDepth`（整数 ≥0、既定 1）、`maxActiveSubagents`（整数 ≥1、既定 8） | 副 agent 深 與 同時実行 上限 |
| `subagent-model-selection` | `enabled`（真偽値、既定 false）、`allowedModels`（`{provider, model}` 配列） | 副 agent 模型選択 |
| `ui-chat` | `transcriptView`（`normal`/`compact`） | 会話記録 表示密度 |
| `ui-conversation` | `busyEnter`（`queue`/`steer`） | busy 時 Enter 動作 |
| `ui-onboarding` | `welcomeNoticeVersion` | 引導手順 状態（dsh 自 書込） |
| `ui-theme` | `preference`（`light`/`dark`/`system`）、`fontSize`（12–17） | 外観與主題 |
| `web-search-deepseek` | `apiKey`（secret）、`apiKeyEnv`、`baseURL`、`model`（既定 `deepseek-v4-flash`）、`apiVersion`、`maxTokens`（≥1、既定 4096）、`maxUses`（≥1、既定 5） | 聯網検索 backend |

> ⚠️ 本表 曾 `0.1.5-rc.2` 基準 転記、其中 **5 行 実測 不一致**、故 2026-09-23 逐項照合 修正：
> `locale` 之字段 `language` 非、`preference`；`ui-theme` 唯 `preference`/`fontSize`
> （`dark`/`light`/`body` 字段 無——`dark`/`light` 為 `preference` 之**値**）；
> `shell` 之 `dshHome` 字段 不存在、実際 実行器 之制限 6 項；`subagent-model-selection`
> 之頂層 `enabled`/`allowedModels`（`provider`/`model` 為**配列要素**之字段）；
> `agent-default-model` 唯 `provider`/`model` 必須、`reasoningEffort` 省略可能。
>
> **判據**：本表 插件源碼読取 以外 得 不能。「合理外観」之字段名 皆 記憶之産物 可能性 有——
> 次回 dsh 昇級時 再実測 願。本表 増分推測 重 不可。

> ⚠️ **2026-10-02 第二回 照合（`0.1.6-alpha.2`）**：項目数 12 自 **15** 訂正——旧表
> **host namespace 三個 見落**：`llm-deepseek`、`llm-pi-ai`、`subagent`（前二者 模型 adapter
> 登録、最後者 `@deepseek-ai/dsh-subagent` 登録。旧 grep 唯 `installSection` 呼出箇所 見、
> 此等 取落）。同照合 旧判断 一個 覆：「`shell` 之 `cwd` 既定値 無 ⇒ 部分宣言 不可」**誤**——
> schemastery 中 `.required()` 不書 字段 元 任意（実測：`z.object({cwd: z.string()})({})` 通過）、
> 欠落 `missing required value` 化 唯 `.required()` 付 場合。
>
> 照合口径：install tree 全体 `grep -rn 'settings\.installSection(\|settings\.register('`
> 之**呼出箇所** 正 為（`@deepseek-ai/dsh-settings` 自身 與 其読者 `dsh-tool-cordis` 此 API 之
> **実装**、namespace 登録側 非）。

> **設定 menu 存儲層境界**：非 設定 UI 全項目 皆 `nixkits.dsh.settings` 宣言設定 可能。**dsh-api-balance 界面 / 語音設定**（語音提醒、底部統計条横 scroll、Enter 改行 + Shift+Enter 送信交換、mobile 会話切替時 keyboard 抑止、TTS backend）為**瀏覽器 localStorage 状態**（毎瀏覽器独立、既定 ON、UI 内切替）、`settings.installSection` 系統**不経由**——故 `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` 此等 上書**不**。此類「毎瀏覽器設定」当該插件 `⚙ 設定` panel 内 実施、或 device 別 独立瀏覽器 用意。

### 構造化選項與脱出艙之役割分担

上表 15 namespace 皆 `nixkits.dsh.settings.<namespace>` 自 直接書込 可能——即 **無型脱出艙**。其代価 二種 有、**一種 静黙、一種 有声**：

- **字段名 誤記 → 完全 静黙**。schemastery 之 `z.object` 為**開放**：未知 key 原様 保持、本当 書 之字段 依然 schema 既定値 食。実測（`0.1.6-alpha.2`）：`schema({ maxParallelToolCall: 4 })` 得 `{ maxParallelToolCalls: 10, maxParallelToolCall: 4 }`——評価時 誤 無、実行時 誤 無、日誌 亦 無、**唯 値 不 有効**。
- **型 誤 / 値 範囲外 → 有声、但 日誌 内 唯**。dsh 該 section 拒否：起動時 当該 namespace 登録 自体 失敗、実行中 hot reload 時 `settings: keeping last good "<ns>" after invalid stored section` 之 warn 出 且 直前 良値 保持。

故 本 module 其中 13 個 向 **構造化選項** 提供（Nix 側 上流 schema 写取、上述 二類 誤 評価時 誤 化）：

| 選項 | 書込 namespace | 対応插件 |
|------|------------------|----------|
| `nixkits.dsh.defaultModel` | `agent-default-model` | `@deepseek-ai/dsh-agent-default-model` |
| `nixkits.dsh.agentLoop` | `agent-loop` | `@deepseek-ai/dsh-agent-loop` |
| `nixkits.dsh.subagentModelSelection` | `subagent-model-selection` | `@deepseek-ai/dsh-tool-subagent` |
| `nixkits.dsh.permission` | `permission` | `@deepseek-ai/dsh-permission-presets` |
| `nixkits.dsh.agentPresets` | `agent-presets` | `@deepseek-ai/dsh-agent-presets` |
| `nixkits.dsh.subagent` | `subagent` | `@deepseek-ai/dsh-subagent` |
| `nixkits.dsh.shell` | `shell` | `@deepseek-ai/dsh-bash-local` / `dsh-pwsh-local`（namespace `@deepseek-ai/dsh-shell` 属） |
| `nixkits.dsh.webSearchDeepSeek` | `web-search-deepseek` | `@deepseek-ai/dsh-web-search-deepseek` |
| `nixkits.dsh.llmDeepSeek` | `llm-deepseek` | `@deepseek-ai/dsh-llm-deepseek` |
| `nixkits.dsh.locale` | `locale` | `@deepseek-ai/dsh-client-locale` |
| `nixkits.dsh.ui.theme` | `ui-theme` | `@deepseek-ai/dsh-client-ui-theme` |
| `nixkits.dsh.ui.chat` | `ui-chat` | `@deepseek-ai/dsh-client-ui-chat` |
| `nixkits.dsh.ui.conversation` | `ui-conversation` | `@deepseek-ai/dsh-client-ui-conversation` |

**三者 意味 一貫**：選項 既定 `enable = false`（settings.yaml 不書込、当該 namespace schema 既定 fallback）；`enable = true` 時 子選項 従 当該 section 生成；**`nixkits.dsh.settings.<同名 namespace>` 常 優先**、構造化選項生成値 勝。

残 二 namespace **意図的 構造化選項 不與**、理由 各自 異：

- `ui-onboarding`：純 client 側 引導状態（`welcomeNoticeVersion` 為 用者 引導 終了時 dsh 自身 書込）。宣言的 書 正当用途 無、書 時 外部 指定 版本号 従 引導 `replay` 或 `skip` 唯一——用者 点 進 可 状態、Nix 定 可 状態 非。
- `llm-pi-ai`：字段 為 `providers` 辞書（route → provider profile）、且 profile **深層 嵌套**（`models` 目録、`modelOverrides`、`compat`、`thinkingBudgets`、`retryPolicy` 等）、其中 `api` 之列挙 内蔵 pi-ai 協議登録簿 `supportedProtocols()` 由来——**pi-ai version 随 動 開放集合**、型化 即「設定可能 外観、実際 新協議 拒」之形 腐。本機 既 更適 落点 有：`nixkits.dsh.plugins.settings."llm-pi-ai".providers`（組合行 config、上之「插件宣言式管理」節 参照）。

字段 書込 方針（何 具体 既定値 持、何 `null` 以 「不宣言」 表）：

- schema 既定値 有、且 内蔵 組合行 config 之 一致 → 具体 既定値 無条件 書込、不宣言 場合 與 意味 同等；
- schema 既定値 無（deploy / adapter / process 環境 定）、或 組合基線 schema 既定 自 **逸脱** → `null` 以 「不宣言」 表、描画時 削除。

二番目 潔癖 非：`shell` 之 `timeoutMs` 即 実例——schema 既定 120000、但 内蔵 `bash-sandbox` 行 **60000** 設定。「enable 即 全量書込」 然 也、`shell.enable = true` 60000 静黙 120000 変——即 本 module 防 為 存在 之 静黙 値 改。故 `nixkits.dsh.shell.timeoutMs = null`（既定）60000 保持、明示 120000 書 時 唯一 上流既定 復。同様 `web-search-deepseek.baseURL` 與 `llm-deepseek.baseURL` `null` 残留：未指定時 `$DEEPSEEK_SEARCH_BASE_URL` / `$DEEPSEEK_BASE_URL` fallback、literal 書込 環境変数 遮蔽。

又 `web-search-deepseek.apiKey` 意図的 写取 不：`role("secret")` 持 故、settings.yaml 書 時 API key `/nix/store`（世界可読）落。鍵 `apiKeyEnv` 與 systemd `LoadCredential` 経由。

`shell` 構造化選項 不提供：其 `cwd` **既定値 持 不**、部分宣言 検証 risk 伴（上流 schema 当該字段 存在 要求）、脱出艙 委 方 安全。

```nix
{
  nixkits.dsh = {
    # 新規会話 既定模型
    defaultModel = {
      enable = true;
      provider = "deepseek-official";
      model = "deepseek-flash";  # 三 目録 全部 存在、且 各目録 image modality 宣言 唯一 之 id
      reasoningEffort = "max";
    };
    # 単輪 並列道具呼出 上限
    agentLoop = { enable = true; maxParallelToolCalls = 10; };
    # 副 agent 選択可能模型 許可清單（enable 当該機能 之 enabled 同時 開）
    subagentModelSelection = {
      enable = true;
      allowedModels = [
        { provider = "deepseek-official"; model = "deepseek-flash"; }
      ];
    };
    # 新規会話 既定 権限預設（値 組合行 presets 表 由来）
    permission = { enable = true; defaultPreset = "danger-full-access"; };
    # 新規会話 既定  mount 之 Agent 預設
    agentPresets = { enable = true; default = "lampkeeper"; };
    # 副 agent 深 與 同時実行 上限
    subagent = { enable = true; maxDepth = 2; maxActiveSubagents = 12; };
    # 本地 shell 実行器：変 欲 字段 唯 書。未指定 組合基線 自重（timeoutMs 基線 60000）
    shell = { enable = true; timeoutMs = 300000; maxTimeoutMs = 1800000; };
    # 聯網検索 backend
    webSearchDeepSeek = { enable = true; model = "deepseek-flash"; maxTokens = 8192; };
    # 原生 DeepSeek adapter：思考 與 stream idle timeout
    llmDeepSeek = {
      enable = true;
      thinking = "enabled";
      reasoningEffort = "high";
      streamIdleTimeoutMs = 3600000;  # 分塊間隔 timeout、総所要時間 非
    };
    # 界面言語 中国語 固定；未設定 時 各瀏覽器 之 Accept-Language 従
    locale = { enable = true; preference = "zh"; };
    ui = {
      theme = { enable = true; preference = "dark"; fontSize = 14; };
      chat = { enable = true; transcriptView = "compact"; };
      conversation = { enable = true; busyEnter = "queue"; };
    };
  };
}
```


### 默認模型（defaultModel）

`nixkits.dsh.defaultModel` 新規 session 默認模型向構造化声明 option（`@deepseek-ai/dsh-agent-default-model` 経由 `settings."agent-default-model"` 書込）。默認 `enable = false`（不注入）；`enable = true` 時下記 sub option 生成、**明示 `nixkits.dsh.settings."agent-default-model"` 常優先**：

```nix
{
  nixkits.dsh.defaultModel = {
    enable = true;
    provider = "deepseek-official";  # 默認
    model = "deepseek-flash";        # 默認
    reasoningEffort = "off";         # 默認
  };
}
```

#### 模型目録 dsh 版 追随

`deepseek-official` route 之 模型目録 adapter **内蔵**（`dsh-llm-deepseek` 之 `DEFAULT_MODELS`）、設定書類 自 読取 無。故 dsh 版 毎 変化：

| dsh 版 | 目録 之 項目 | 内 image modality 宣言 者 |
|--------|-------------|--------------------------|
| stable `0.1.5-rc.2`、alpha `0.1.6-alpha.1` | `deepseek-flash`、`deepseek-v4-flash`、`deepseek-v4-pro`、`deepseek-v4-flash-vision-exp` | `deepseek-flash`、`deepseek-v4-flash-vision-exp` |
| alpha `0.1.6-alpha.2` | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |

`deepseek-flash` 三 目録 **全部 存在**、且 **各目録 image modality 宣言** 唯一 之 id —— 此 模块 既定値 選択 理由。他 画像対応 id `deepseek-v4-flash-vision-exp` 古 二 目録 限 存在、上流 2026-09-10 廃止 為、既定値 使用 不可。

上流 2026-09-10 DeepSeek-V4.1-Flash 公開時、V4 Flash 與 V4 Flash Vision Exp 廃止、模型名 `deepseek-flash`（画像理解 備）與 `deepseek-v4-pro` 収束。旧 id 互換 為 引続 呼出 可能、但 処理 V4.1-Flash 行、Flash 料金 課金（[模型 與 価格](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/) 脚注 参照）。

> ⚠️ **目録 無 id 「名 異 之 同物」 非**：dsh 未収録 id **文本専用**模型 扱（`modelInfo` `inputModalities: ["text"]` fallback）。其結果 二 経路 分、**片方 鳴、片方 無言**：
>
> - **新規添付 画像 其場 拒否**：`session/prompt` 之 添付准入 同 `inputModalities` 読、`MODEL_DOES_NOT_SUPPORT_IMAGES` 投。UI 上 画像 不支持 旨 表示。
> - **履歴 既存 画像 無言 破棄**：送信前 `projectImagesForTextModel` 文本記述 置換 —— 誤謬 不出、模型 画像 未見。
>
> 既定値 選択時 目録 存在 id 選択 事。此 判定 dsh 版 毎 変化 —— 同 設定 更新後「画像 見」自「画像 拒」往 転 可能。

#### reasoningEffort 段階與 cost

| reasoningEffort | 動作 | 開銷 |
|-----------------|------|------|
| `off` | non-thinking：思考連鎖無、`thinking:disabled` 映射 | **最省**（reasoning token 無）、延遲最小；**FIM 補全僅此段対応** |
| `low` | 思考開・最小力度 | off 稍高（少量 reasoning token） |
| `high` | 默認段（dsh-llm-deepseek adapter 默認 high）、品質/速度均衡 | 出力含推論 segment、token 比率増 |
| `max` | 最高力思考、品質最強 | **最高額**（出力 token 比率最大） |

> `off` → `thinking:disabled` 為 FIM（Fill-In-The-Middle 補全）有効化前提（DeepSeek FIM「非思考 mode 限対応」）。上流 [FIM 補全 API](https://api-docs.deepseek.com/api/create-completion/) 於 `model` 取得可能 値 僅 `deepseek-flash` 與 `deepseek-v4-pro` 二 者、両者 共「非思考 mode 限対応」。
