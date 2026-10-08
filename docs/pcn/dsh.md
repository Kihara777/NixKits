# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | 偽中国語

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Node.js 応用（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版 | `0.2.0-rc.2` |
| 開発通道 | `dsh-alpha 0.2.1-alpha.1`（npm `alpha` dist-tag） |
| 許可 | MIT |
| 命令 | `dsh` |

## 版通道

NixKits 倣 ruyi 薄包装模式（本体定義 + 版/hash 上書包装）複数 dsh 版同時提供：

| 包 | 通道 | 版 | 説明 |
|---------|---------|---------|-------|
| `pkgs.dsh` | stable | `0.2.0-rc.2` | npm `latest` dist-tag、既定。**預設内容** 指定 rev 凍結 |
| `pkgs.dsh-alpha` | alpha | `0.2.1-alpha.1` | npm **`alpha`** dist-tag、0.2.x 線 最新 prerelease 追跡。**預設内容** repo HEAD 追随 |

```nix
# 本機 最新 prerelease 使用
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> **`dsh-alpha` 為何 `alpha` 追随**（2026-10-08 復帰）。npm 三 dist-tag 現在値 `alpha` = **`0.2.1-alpha.1`**、一方 `latest` = `next` = `0.2.0-rc.2` —— `alpha` 逆 `next` **追越**。2026-10-02 `next` 切替 理由「`alpha` = `0.1.7-alpha.2` 古 0.1.x 線所属、stable 未満」、**該前提 反転済**。`next` 追随継続 = 開発通道 `alpha` 未満 版 固定 同等。判定基準「何 tag 名 一層 prerelease 似」非、**何 tag 0.2.x 線 於 一層新版 指**：再確認毎 dist-tags 読直 両版 対照、`alpha` 先導 無 時 復帰 可。
>
> 両通道 **挙動差 二点**：① dsh 版（alpha 新、故 hash / `npmDepsHash` / vendored lock **各独立**——版異 間 stable lock 共用 不可）；② **預設内容**：stable 預設 `packages/dsh-nixos-shell-stable.nix` 指定 commit 凍結、alpha repo HEAD 追随（下文「模式」参照）。
>
> ⚠️ **0.2.0 預設格式 断層**、0.1.x 互換 無：目録型預設経路（`$DSH_HOME/.agent-presets/<id>/` + `agent.cordis.yml`）上流 削除済。更新前 下文「模式」與「dsh 0.2.0 於 預設格式之変化」両節 読 事。内蔵插件一覧 版 共 動、先 [changelog](https://github.com/deepseek-ai/deepseek-harness/releases) 確認。

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

常駐 web 服務実行 `nixkits.dsh` module 使用。dsh RCE 安全 loopback 唯（`127.0.0.1:8615`）監聽、lighttpd 反代対外端口 `8625` 公開（防火牆自動開放）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh 拒否非 loopback
    port = 8615;          # 内部 loopback 端口
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 対外端口
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

插件包経**安定掛載点**読込：activation script 毎回 switch/boot `/run/dsh/current`（dsh 本体與插件樹）與 `/run/dsh/nixos-shell`（sudo 実行脚本）符号連結翻當前世代 store 路（GC 安全：目標常當前 toplevel 閉包内、復帰自翻旧代路）。`dsh.service` 與 `nixkits-sudo@.service` 単元定義僅参照該安定路、故**插件包更新不変単元内容**——switch-to-configuration 不再起 dsh、不 stop/start sudo socket、活性化零中断在途工具呼出。

代価與配套：dsh 長駐進程、插件／預設包更新反映需明示再起——**先 `systemctl daemon-reload`、次 `systemctl restart dsh`**（`nixos_shell` 後者自動分離瞬時単元、呼出先於再起返）。restart 単独 時 前世代 pre-start 脚本 実行 有、其 工程 正 `cordis.patch.yml` `$DSH_HOME` 複製 段（預設根 該文件 記載）、症状「服務確 再起、預設 仍旧」。再起後 `$DSH_HOME/profiles/<profile>/cordis.patch.yml` store 路 翻新 確認。sudo 実行器接続毎生成、新連接自動新脚本、無需再起。

## NixKits 插件

倉庫内 dsh 向開発独立插件**本文書展開不**、各插件独立文書維持（mount 方式上文 `plugins.packages` 参照）：

| 插件 | 説明 | 文書 |
|------|------|------|
| dsh-nixos-shell | NixOS 場景能力統合：`nixos_shell` 実行器（PATH 注入 / `nix shell` 工具引導 / sudo 守護路由）+ `nixos_cli` 読取専用診断；NixOS模式 / 維護模式二 Agent 預設同梱 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量面板「用量 / 残高」切替：勘定残高、日 / 月 / 30 日内消耗図表與音声放送（音声 pack 形式指南含） | [dsh-api-balance.md](dsh-api-balance.md) |

## 模式

「模式」即 dsh 之 **Agent 預設**：各模式 = 一 session 形態、専用身份 prompt・工具面・prompt 節具備。插件同等級、各自独立文書持、相互影響無：

| 模式 | id | 説明 | 配布方式 | 文書 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初期化時 NixOS 宿主検証（非 NixOS 全実行拒否）；`nixos_shell` / `nixos_cli` 與開発 prompt 読込 | dsh-nixos-shell 包内、**profile patch 行** | [modes/nixos.md](modes/nixos.md) |
| 維護模式 | `maintenance` | NixOS模式派生；`write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` 技能與維護工作流注入 | dsh-nixos-shell 包内、**profile patch 行** | [modes/maintenance.md](modes/maintenance.md) |
| 新聞三要素模式 | `news-three-elements` | 極簡模式派生之読取専用創作模式：「新聞三要素」必到三人主人公、素材優先（接続不能時 唯拒否）、素材共創 検索後 書直（検索無 退稿）、online 技能包、開始時問答、簡体中文以外一律拒否 | **独立包** `dsh-preset-news-three-elements`、**profile patch 行 + 内容目録** | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` — NixOS模式
    maintenanceMode = true;   # id `maintenance` — 維護模式（NixOS模式派生）
    newsThreeElements = true; # id `news-three-elements` — 独立包
    # 預設内容 出処：既定 dsh 通道 従（stable → dsh-nixos-shell-stable、
    # 預設 指定 rev 凍結；alpha → dsh-nixos-shell、HEAD 追随）。通常 記述 不要。
    # plugins.packages 注入 @kihara777/dsh-nixos-shell 別系統 時 唯 整合。
    # package = pkgs.dsh-nixos-shell;
  };
}
```

> **0.2.0 以降、配布方式 唯一**：各模式 = 一本 `@deepseek-ai/dsh-agent-preset` patch 行（模組 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`差込）、插件行本文 該包 `preset.patch.yml` 従 **逐字** 取。0.1.x 二経路（`nixosMode`/`maintenanceMode` seed-once 目録 copy、`newsThreeElements` roster 追加 root）上流変更 共 消滅——`roots` 機構自体 不存在。内容目録 必要 新聞三要素模式 唯一：該插件 npm 包 非、預設同梱 file 故、模組 `$DSH_HOME/.agent-presets/news-three-elements/`組立（整体再構築、seed-once 非）、patch 行 相対経路 参照。各模式 挙動・組合構造・維護規則 上表文書参照。

> **本 repo 配布 不 模式 展開側 二 有**：掌灯模式（`lampkeeper`、order 12）與 Ocean Spiral（`ocean-spiral`、order 14）。内容 出処 私有 repo（Kitsunome）、但 0.2.0 形態 上三 與 全同——patch 行一本 + `$DSH_HOME/.agent-presets/<id>/`組立 内容目録、錨 `new URL('../../.agent-presets/<id>/', baseUrl)`（**Ocean Spiral repo 入 2026-10-02**、以前 展開副本 唯一実体、repo 也 播種 也 無）。両者 一致性検査 亦 彼方：`develop/check-lampkeeper-derivation.py`、`develop/check-ocean-spiral-derivation.py`。

### dsh 0.2.0 於 預設格式之変化（2026-10-02 着地済）

dsh 0.2.0 Agent 預設 保持方式 再構築、**目録型預設経路 削除**：

| | 0.1.x（0.2.0 以降 使用 不） | 0.2.0（現在） |
|---|---|---|
| 預設形態 | `$DSH_HOME/.agent-presets/<id>/` 目録 | profile 利用者 patch 層（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）内 loader patch 一條 |
| 組合與 metadata | `agent.cordis.yml`（完全組合）+ `preset.yml`（`name` / `description`） | `@deepseek-ai/dsh-agent-preset` 行 `config.plugins`（插件行）+ `config.name` / `config.description` |
| 検出方法 | `@deepseek-ai/dsh-agent-presets`（複数形）root 走査 | Loader 樹 自身；複数形包 0.2.0 既不存在 |
| roster 並順 | 無 | `config.order`（内蔵 1–4 占有、預設間 一意必須） |
| 宿主要行 | `agent-presets`（複数形）與其 `roots` 表 | `agent-preset-registry`；`default` 該行 **必須 config**、settings 側 `selectedDefault` 唯 残 |

**repo HEAD 新格式 唯 維護**：0.1.x `agent.cordis.yml` 三預設 全部 削除済、両格式 HEAD 併存 不——分岐 唯「取用点」。stable 通道 預設内容 `packages/dsh-nixos-shell-stable.nix` 指定 commit（`0175f85`、**両格式 併存 最後 commit**。0.1.x 利用者 rev 以 取）従 取、alpha 通道 HEAD 追随。凍結 意味「stable 更新 不」非、**更新時点 判定可能**：HEAD 上 預設変更 先 alpha 通道 実走、確認後 `pinnedRev` 一行 明示前進——HEAD 共 stable 通道 静 流込 無。

模組側（`modules/dsh.nix`）接線：

- 預設本文 模組 元々生成中 `cordis.patch.yml` **逐字** 差込（別機構 作 不・插件行 複製 不——複製 必 漂）；
- 読 物 `dsh-nixos-shell` 変体 `passthru.presetsSource`（stable 変体 `builtins.fetchTarball` 指定 rev 取 故、**評価期 原経路 読** 唯、import-from-derivation 無）；
- 通道判定 dsh 包 自身 宣言 `passthru.dshChannel` 従 取。故 通道交代 `nixkits.dsh.package` 一行 済、預設内容 追随；
- `nixkits.dsh.agentPresets.*` `- id: agent-preset-registry` patch 行 出 様 変更；旧 `settings."agent-presets"` **評価期 直接 error**——既 何 plugin 也 読 不、残 場合 宣言 既定預設 静 失 唯；
- 注意：注入 `@kihara777/dsh-nixos-shell` 與 `presets.package` **同一変体** 必須（預設本文 後者 従 来、技能根 実行時 前者 解決）。不一致 評価期 `lib.warn` 出。

**插件単位 config schema 差異**（両通道 産物 各插件包 `Config` schema 逐条比較、`0.1.6-alpha.2` → `0.2.0-rc.2`）：

| 插件行 | 変化 | 本預設 影響 |
|--------|------|----------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | 任意 `promoteOnTimeout` 追加（既定 `true`） | 本預設 **該 key 書 不**（決定：挙動 既定値 上流 追随）→ 0.2.0 以降、前面 bash timeout 到達時 **背景 job昇格**、殺 無 |
| `dsh-tool-workflow` | 任意 `enableRunInBackground` 追加（既定 `true`） | 未設定 → 背景能力 増 |
| `dsh-tool-ask-user` | 「Config 無」従 `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }`（既定 `legacy` / `120`） | 未設定 → 旧版 同挙動 |
| `dsh-compaction-basic` | 任意 `headroomTokens` 追加（`modelPolicies[]` 内 同名欄 共） | 未設定 → 調整項目 一 増 唯 |
| `dsh-tool-jobs` | `maxConsecutiveWakes` 残 但、schema 既定値 輸出 出 無 | 未設定 |
| `dsh-tool-fs-search` | **変化 無**：`sampleOverCapGlobResults` **必須 boolean**、0.1.6 以来 然 | 旧 file 既 `false` 持。新 file 其 侭 |
| 残 20 插件行 | schema 逐字同一 | 変更 不要 |

> 比較範囲 `dsh-tool-subagent` `backgroundMode` / `maxDepth` 合併型、`dsh-plan-mode` 自前 厳格 `{ section }` 検証（未知 key error）、本 repo `@kihara777/dsh-nixos-shell` 三行 含、何 変化 無。

> ⚠️ **今回 更新 日常挙動 変 新既定値 `promoteOnTimeout` 唯**（決定：**預設 書 不**、上流 追随）。効果：前面 bash 呼出 timeout 到達 也 殺 無 **背景 job昇格**、呼出側 job id 受取；`job_output` / `job_list` / `job_kill` timeout 後 収拾手段 化。旧挙動（timeout 即殺）必要 場合、預設 該行 `config.promoteOnTimeout = false` 明示——本 repo 意図的 此 釘 打 不、上流 既定値 進化 到達 様 為。

**旧 file 対 四必然差異**（無修正 copy 破損）：

1. **`baseUrl` 意味変化**。0.1.x 系 預設自身 目録、0.2.0 実測 **profile 目録**（`$DSH_HOME/profiles/<profile>/`）。旧 file 技能根 `new URL('skills/', baseUrl)` 記述、無修正移行 → `<profile>/skills/` 指、技能 **静黙消失**。本 repo 二預設 `baseUrl` 従 `@kihara777/dsh-nixos-shell` 包根 解析 `presets/<mode>/` 連結、私有 repo 二 `../../.agent-presets/<id>/` 逆算——両者 共 **存在 guard** 付、錨 誤 場 `broken` 化、「技能無」状態 退化 無。
2. metadata（旧 `preset.yml` `name` / `description`）`config.name` / `config.description` 移。
3. `config.order` 新 key。
4. **插件行 相対経路 錨 書換 必要**：相対指定子 `.` 開始 必須（loader 該形 name 唯 `baseUrl` 以 解決。**絶対経路 裸 package 名 扱  import 失敗**）。加 `baseUrl` profile 目録 化 故、`./plugins/x.js` → `../../.agent-presets/<id>/plugins/x.js`。副作用：預設同梱 plugin file 裸 package 名 以 `@deepseek-ai/*` peer import 場合、模組 `@deepseek-ai` 也 `$DSH_HOME/node_modules` 張 必要。無 場合 該行 `… never started` 報告 唯（下文「預設 掛載判定」参照）。

#### 預設 掛載判定（真 載 可否 如何 知）

**「roster 内 存在」移行成功 非**：預設 載 不 時、0.2.0 `agentPresets/list` 各条目 `broken` 欄 返 唯——**該欄 無 即 上流 健全性判定 通過**。判定 実行可能：

```bash
# 臨時実例 手順：dsh 起動 → boot.log 従 token 取得 → cookie 交換 → RPC 呼出
curl -sS -b cookies -H 'content-type: application/json' \
  -d '{"type":"client-request","rpcId":"1","method":"agentPresets/list","payload":{"args":{}}}' \
  http://127.0.0.1:<port>/api/agentPresets/list
```

2026-10-02 着地検収（臨時 `DSH_HOME`、`dsh 0.2.0-rc.2`）：**9 条目**（内蔵 4 + `nixos` order 10 + `maintenance` 11 + `lampkeeper` 12 + `news-three-elements` 13 + `ocean-spiral` 14）**`broken` 全部 空**；三反証 何 也 **実 file 一箇所** 唯 変更：

| 反証 | 変更箇所（一箇所） | `agentPresets/list` 報告 `broken` |
|------|-----------------|-----------------------------------|
| 包名 | `tool-fs-search` 包名 不存在 `@deepseek-ai/dsh-tool-fs-searchX` | `tool-fs-search (@deepseek-ai/dsh-tool-fs-searchX): never started`（派生元 同一 5 預設 同時 報告） |
| 錨 | Ocean Spiral 技能根 `../../.agent-presets/ocean-spiral/` → `…ocean-spiral-typo/` | `skill-filesystem (…): ocean-spiral skill roots missing: <経路>` + `oceanspiral-scene (…): never started` |
| 組立 | `$DSH_HOME/node_modules` 内 `@deepseek-ai` link 一本 欠 | `lampkeeper-shell (../../.agent-presets/lampkeeper/components/lib/index.js): never started` |

最後 一行 **今回 着地 実際 修正 罠**：預設同梱 plugin file `$DSH_HOME/.agent-presets/<id>/…` 存在、裸 package 名 以 peer import 時 Node **file 所在目録** 従 上 `node_modules` 探。模組 以前 `@kihara777` 唯 張、故「dsh 再起動後 掌灯模式 broken 化」——両者 同一 `$DSH_HOME` 内 相互 踏。現在 `@kihara777` 與 `@deepseek-ai` 二本 張。

**persona 與 同梱技能（2026-10-02 着地後 之 修正）**：二箇所 之 陳腐化 記述 変更。両者 共 既 未決項 非。

- **persona**：新格式 file 之「預設 `$DSH_HOME/.agent-presets/<id>/` 目録 住」一句 0.2.0 之 正確 記述 変更——預設 = profile `cordis.patch.yml` 内 `@deepseek-ai/dsh-agent-preset` 条目 一本、**発見 担 者 該 一行 也**；預設 依然 自前 file `.agent-presets/<id>/` 下 置、profile 従 相対経路 参照 可能——本配備 之 一部 預設 正 此 様 插件 與 技能 同梱。此 書換 場合 **model 送 prompt** 変——挙動変更 該当 故、維護者 別途 批准 済。
- **同梱技能**：二預設 以前 `cordis-plugin-development` 與 `editing-cordis-compositions` 之 副本 **同梱**。0.2.0 此 二（加 `agent-experience` / `cordis-composition-reference`）`@deepseek-ai/dsh-agent-preset` 與 共 配布、但 此方 之 二 0.1.x 目録式 預設 模型 上 留——故 同名 二 並、内 一 **廃止 書方** 教（上流 之 新版 *"Nothing reads that directory any more"* 明言）。現在 二預設 之 `skill-filesystem` 行 **上流 其 直接 掛載** 形 変更（内蔵 `cordis` 預設 與 同一 式）、上流 無 `skills-nixos/`（NixOS 運用技能）唯 残。`develop/check-preset-derivation.py`「既 副本 同梱 不」 断言 化 釘付；同梱 之 二 今 也 stable 通道 釘付 rev 従 取用 可能（0.1.x 互換）。

### 会話格式 v4 之 消息来源 准入（2026-10-03 事故）

dsh 0.2.0 **会話格式 v4** 導入。此 **各消息 之 `source`** 一条 之 准入判据 課：

> 対象 客体 在、`kind` 非空、且 **字面量 `"plugin"` 等 不**。

字面量 `"plugin"` 與 同级 `plugin: "<名>"` **v3 時代** 之 插件来源形状 也（0.1.6 時代 之 内蔵插件
如 書、其 丸写 之 第三者 插件 亦 同様）。v4 於、**預設 插件 斯 様 消息 一 会話 書込 瞬間 准入
拒否**。症状 session 全体「本機実行失敗」、error 唯 一句：

```text
format v4 message requires a producer-owned source kind
```

2026-10-03 実測：掌灯模式 之 `journal-catchup` **新規 session 開始毎** 注意書 一件 steer。故
0.2.0-rc.2 上 新規 session 作成毎 崩、session file 消息 一件 亦 残 不（header・三件 之 政策
event・唯 `session/end-seed`）——維護者 会話 続 為 系統 巻戻 之外 無。同一形状 本 repo 之
新聞三要素 預設 之 二 插件（`news-language.js` / `news-material.js`）亦 在、同期 修正 不 場合
次回 配備 同様 崩。

| 帰属 | v3 形状（v4 拒否） | v4 形状 |
|---|---|---|
| 插件来源 | `{ kind: "plugin", plugin: "<名>", form: "notice", … }` | `{ kind: "plugin:<名>", form: "notice", … }` |
| 同名 producer | `{ kind: "plugin", plugin: "user-approval" }` | `{ kind: "user-approval", … }` |
| 人 | `{ kind: "user" }` | 不変 |

判据 `nix flake check` 之 `session-sources` 項 固定 済（`develop/check-session-sources.py`）：
本 repo 預設 插件 `kind: "plugin"` 出現 場合 失敗。`plugin:` 接頭辞 此処 創作 非——v4 移行表
於「同名 非 插件」与 名（`plugin:` + 完全 插件名）、履歴 会話 移行後 取 形状 與 一致。

> **巻戻 代価**：v4 会話 **旧版 読 不**（0.1.6 JSONL 永続化 未知 format version 読 時点 拒否、
> 降格読 不）。故「0.2.0 上 後 巻戻」以前 会話 一切 開 不——**昇格 前** 插件 来源形状 修正 事。
> 巻戻 逃道 考 不 事。

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

> **安全模型**：套接字書類 dsh service 利用者所有 `0600`（`SocketUser`/`SocketMode`）— 該利用者接続可、実質該利用者向免密 root 実行。利用者與代理挙動双方信頼可場合有効化。


## 插件清單

dsh 0.2.0-rc.2 内建插件 entry id（`nixkits.dsh.plugins.disabled` 有效値、`id -> 插件包`）：

> **清單生成方法**：`dsh --profile web --dump-default-config`（読取専用）輸出即 `id -> name` 形式；dsh 升級後再実行、以所装版輸出為准。本表対応 web profile 之 base + web-app patch 集。
>
> ⚠️ **alpha 通道（`0.2.1-alpha.1`）比 本表 多 二 行**：`schedule -> @deepseek-ai/dsh-schedule` 與 `ui-schedule -> @deepseek-ai/dsh-client-ui-schedule`（2026-10-08、同一 命令 対 alpha 成果物 実行 実測、183 → 185）。**此 二 行 不 可 写 入 stable 配備**——stable `0.2.0-rc.2` 無 此 二 行、而 dsh ≥ 0.1.6-alpha.2 対 解決不能 之 plugin 行 視為 **硬失敗**（全 預設 不能 掛載、見 上文 改名 注意）。

```text
  tool-plugin-manager -> @deepseek-ai/dsh-plugin-manager/tools
  plugin-manager -> @deepseek-ai/dsh-plugin-manager
  timer -> @deepseek-ai/cordis-plugin-timer
  hmr -> @deepseek-ai/dsh-hmr
  llm -> @deepseek-ai/dsh-llm
  deepseek-llm-api-extensions -> @deepseek-ai/dsh-deepseek-llm-api-extensions
  session -> @deepseek-ai/dsh-session
  session-log-deepseek -> @deepseek-ai/dsh-session-log-deepseek
  typert -> @deepseek-ai/dsh-typert-registry
  typert-loader -> @deepseek-ai/dsh-typert-loader
  typert-gateway -> @deepseek-ai/dsh-api-gateway
  session-title -> @deepseek-ai/dsh-session-title
  session-title-llm -> @deepseek-ai/dsh-session-title-first-prompt-llm
  user-questions -> @deepseek-ai/dsh-user-questions
  agent -> @deepseek-ai/dsh-agent
  plugin-package-inventory-deepseek -> @deepseek-ai/dsh-plugin-package-inventory-deepseek
  agent-default-model -> @deepseek-ai/dsh-agent-default-model
  jobs -> @deepseek-ai/dsh-jobs-local
  llm-retry -> @deepseek-ai/dsh-llm-retry
  config-editor -> @deepseek-ai/dsh-config-editor
  settings -> @deepseek-ai/dsh-settings
  authorization -> @deepseek-ai/dsh-authorization
  deepseek-account -> @deepseek-ai/dsh-deepseek-account-platform
  credentials -> @deepseek-ai/dsh-credentials-local
  llm-pi-ai -> @deepseek-ai/dsh-llm-pi-ai
  session-persistence-jsonl -> @deepseek-ai/dsh-session-persistence-jsonl
  attachment-local -> @deepseek-ai/dsh-attachment-local
  session-query-sqlite -> @deepseek-ai/dsh-session-query-sqlite
  session-projection -> @deepseek-ai/dsh-session-projection
  storage -> @deepseek-ai/dsh-storage
  storage-json -> @deepseek-ai/dsh-storage-json
  storage-domain -> @deepseek-ai/dsh-storage-domain
  session-projection-cache -> @deepseek-ai/dsh-session-projection-cache
  otel -> @deepseek-ai/dsh-otel
  session-telemetry-otel -> @deepseek-ai/dsh-session-telemetry-otel
  subprocess -> @deepseek-ai/dsh-subprocess-local
  sandbox -> @deepseek-ai/dsh-sandbox-local
  sandbox-policy -> @deepseek-ai/dsh-sandbox-policy
  bash-sandbox -> @deepseek-ai/dsh-bash-sandbox
  pwsh-sandbox -> @deepseek-ai/dsh-pwsh-sandbox
  approval -> @deepseek-ai/dsh-user-approval
  permission -> @deepseek-ai/dsh-permission-presets
  shell-env -> @deepseek-ai/dsh-shell-env
  tool-bash -> @deepseek-ai/dsh-tool-bash
  tool-pwsh -> @deepseek-ai/dsh-tool-pwsh
  tool-jobs -> @deepseek-ai/dsh-tool-jobs
  fs-observation-policy -> @deepseek-ai/dsh-fs-observation-policy
  tool-fs -> @deepseek-ai/dsh-tool-fs
  tool-fs-search -> @deepseek-ai/dsh-tool-fs-search
  agent-instructions -> @deepseek-ai/dsh-agent-instructions
  skill -> @deepseek-ai/dsh-skill
  skill-filesystem -> @deepseek-ai/dsh-skill-filesystem
  skill-badge -> @deepseek-ai/dsh-skill-badge
  tool-skill -> @deepseek-ai/dsh-tool-skill
  commands -> @deepseek-ai/dsh-commands
  command-feedback -> @deepseek-ai/dsh-command-feedback
  goal -> @deepseek-ai/dsh-goal
  goal-round-driver -> @deepseek-ai/dsh-goal-round-driver
  command-goal -> @deepseek-ai/dsh-command-goal
  plan-mode -> @deepseek-ai/dsh-plan-mode
  token-meter -> @deepseek-ai/dsh-token-meter
  compaction-basic -> @deepseek-ai/dsh-compaction-basic
  command-compact -> @deepseek-ai/dsh-command-compact
  subagent -> @deepseek-ai/dsh-subagent
  subagent-spawn-in-process -> @deepseek-ai/dsh-subagent-spawn-in-process
  subagent-fork-in-process -> @deepseek-ai/dsh-subagent-fork-in-process
  tool-subagent-control -> @deepseek-ai/dsh-tool-subagent-control
  tool-subagent-list-agents -> @deepseek-ai/dsh-tool-subagent-control/list-agents
  tool-subagent -> @deepseek-ai/dsh-tool-subagent
  tool-subagent-fork -> @deepseek-ai/dsh-tool-subagent
  ptc-runtime -> @deepseek-ai/dsh-ptc-runtime-node
  workflow-ptc -> @deepseek-ai/dsh-workflow-ptc
  tool-workflow -> @deepseek-ai/dsh-tool-workflow
  timeout-policy -> @deepseek-ai/dsh-tool-call-timeout-policy
  spill-local -> @deepseek-ai/dsh-spill-local
  spill-policy -> @deepseek-ai/dsh-spill-policy
  session-checkpoint-policy -> @deepseek-ai/dsh-session-checkpoint-policy
  tool-result-pruner -> @deepseek-ai/dsh-compaction-tool-result-pruner
  image-offload -> @deepseek-ai/dsh-compaction-image-offload
  tool-todo -> @deepseek-ai/dsh-tool-todo
  tool-goal -> @deepseek-ai/dsh-tool-goal
  tool-ralph -> @deepseek-ai/dsh-tool-ralph
  repeat-tool-reminder -> @deepseek-ai/dsh-repeat-tool-reminder
  web -> @deepseek-ai/dsh-web
  web-search-deepseek -> @deepseek-ai/dsh-web-search-deepseek
  web-fetch-http -> @deepseek-ai/dsh-web-fetch-http
  tool-web -> @deepseek-ai/dsh-tool-web
  mcp-resources -> @deepseek-ai/dsh-mcp-resources
  tools -> @deepseek-ai/dsh-tools
  system-prompt -> @deepseek-ai/dsh-system-prompt
  agent-loop -> @deepseek-ai/dsh-agent-loop
  fs-sandbox -> @deepseek-ai/dsh-fs-sandbox
  llm-deepseek -> @deepseek-ai/dsh-llm-deepseek-api-key
  llm-deepseek-account -> @deepseek-ai/dsh-llm-deepseek-account
  desktop-product-telemetry -> @deepseek-ai/dsh-host-product-telemetry-otel
  product-analytics -> @deepseek-ai/dsh-client-product-analytics
  subagent-model-selection-settings -> @deepseek-ai/dsh-tool-subagent/model-selection-settings
  message-feedback -> @deepseek-ai/dsh-message-feedback
  session-log-download -> @deepseek-ai/dsh-session-log-export
  open-in-app -> @deepseek-ai/dsh-host-open-in-app
  ui-open-in-app -> @deepseek-ai/dsh-client-ui-open-in-app
  workspace -> @deepseek-ai/dsh-workspace
  session-reference -> @deepseek-ai/dsh-session-reference
  file-reference-local -> @deepseek-ai/dsh-file-reference-local
  session-stats -> @deepseek-ai/dsh-session-stats
  session-turn-outline -> @deepseek-ai/dsh-session-turn-outline
  directory-picker -> @deepseek-ai/dsh-host-directory-picker-auto
  plugin-inventory -> @deepseek-ai/dsh-host-plugin-inventory
  session-controller -> @deepseek-ai/dsh-api-session-controller
  job-controller -> @deepseek-ai/dsh-api-job-controller
  terminal-controller -> @deepseek-ai/dsh-api-terminal-controller
  workspace-files -> @deepseek-ai/dsh-api-workspace-files
  ui-settings-account -> @deepseek-ai/dsh-client-ui-settings-account
  account-controller -> @deepseek-ai/dsh-api-account-controller
  settings-controller -> @deepseek-ai/dsh-api-settings-controller
  workspace-controller -> @deepseek-ai/dsh-api-workspace-controller
  cordis-host-runner -> @deepseek-ai/dsh-cordis-host-runner
  cordis-inspect-providers -> @deepseek-ai/dsh-tool-cordis/host
  web-startup -> @deepseek-ai/dsh-web-app/startup
  webserver -> @deepseek-ai/dsh-host-webserver
  web-runtime -> @deepseek-ai/dsh-web-app
  client-hmr -> @deepseek-ai/dsh-client-hmr
  modules -> @deepseek-ai/dsh-client-modules
  connection -> @deepseek-ai/dsh-client-connection
  file-upload -> @deepseek-ai/dsh-client-file-upload
  api-remotes -> @deepseek-ai/dsh-api-remotes
  cordis-client-runner -> @deepseek-ai/dsh-cordis-client-runner
  ui-theme -> @deepseek-ai/dsh-client-ui-theme
  locale -> @deepseek-ai/dsh-client-locale
  shortcuts -> @deepseek-ai/dsh-client-shortcuts
  ui-shortcuts -> @deepseek-ai/dsh-client-ui-shortcuts
  ui-layout -> @deepseek-ai/dsh-client-ui-layout
  ui-renderer -> @deepseek-ai/dsh-client-ui-renderer
  ui-session -> @deepseek-ai/dsh-client-ui-session
  resources -> @deepseek-ai/dsh-client-resources
  ui-sidebar -> @deepseek-ai/dsh-client-ui-sidebar
  ui-sidebar-right -> @deepseek-ai/dsh-client-ui-sidebar-right
  office-to-pdf -> @deepseek-ai/dsh-office-to-pdf
  ui-sidebar-documentpreview -> @deepseek-ai/dsh-client-ui-sidebar-documentpreview
  ui-sidebar-browser -> @deepseek-ai/dsh-client-ui-sidebar-browser
  ui-sidebar-terminal -> @deepseek-ai/dsh-client-ui-sidebar-terminal
  ui-sidebar-files -> @deepseek-ai/dsh-client-ui-sidebar-files
  ui-settings -> @deepseek-ai/dsh-client-ui-settings
  ui-settings-general -> @deepseek-ai/dsh-client-ui-settings-general
  ui-settings-models -> @deepseek-ai/dsh-client-ui-settings-models
  ui-plugin-manager -> @deepseek-ai/dsh-client-ui-plugin-manager
  ui-settings-plugin-inventory -> @deepseek-ai/dsh-client-ui-settings-plugin-inventory
  ui-conversation -> @deepseek-ai/dsh-client-ui-conversation
  ui-approval -> @deepseek-ai/dsh-client-ui-approval
  ui-chat -> @deepseek-ai/dsh-client-ui-chat
  ui-brand-official -> @deepseek-ai/dsh-client-ui-brand-official
  ui-attachment -> @deepseek-ai/dsh-client-ui-attachment
  ui-tool -> @deepseek-ai/dsh-client-ui-tool
  ui-cordis -> @deepseek-ai/dsh-client-ui-cordis
  ui-deliverables -> @deepseek-ai/dsh-client-ui-deliverables
  workspace-changes -> @deepseek-ai/dsh-workspace-changes
  ui-workspace -> @deepseek-ai/dsh-client-ui-workspace
  ui-workflow-run -> @deepseek-ai/dsh-client-ui-workflow-run
  ui-input-trigger -> @deepseek-ai/dsh-client-ui-input-trigger
  ui-commands -> @deepseek-ai/dsh-client-ui-commands
  ui-skill -> @deepseek-ai/dsh-client-ui-skill
  ui-subagent -> @deepseek-ai/dsh-client-ui-subagent
  ui-reference -> @deepseek-ai/dsh-client-ui-reference
  ui-jobs -> @deepseek-ai/dsh-client-ui-jobs
  ui-goal -> @deepseek-ai/dsh-client-ui-goal
  ui-message-feedback -> @deepseek-ai/dsh-client-ui-message-feedback
  ui-model-selection -> @deepseek-ai/dsh-client-ui-model-selection
  ui-permission -> @deepseek-ai/dsh-client-ui-permission-presets
  ui-agent-preset -> @deepseek-ai/dsh-client-ui-agent-preset
  ui-settings-session-log -> @deepseek-ai/dsh-client-ui-settings-session-log
  ui-settings-plugins -> @deepseek-ai/dsh-client-ui-settings-plugins
  ui-settings-shell -> @deepseek-ai/dsh-client-ui-settings-shell
  ui-settings-agent-loop -> @deepseek-ai/dsh-client-ui-settings-agent-loop
  ui-settings-subagent -> @deepseek-ai/dsh-client-ui-settings-subagent
  ui-settings-web-search -> @deepseek-ai/dsh-client-ui-settings-web-search
  ui-plan -> @deepseek-ai/dsh-client-ui-plan
  ui-user-questions -> @deepseek-ai/dsh-client-ui-user-questions
  ui-trajectory -> @deepseek-ai/dsh-client-ui-trajectory
  agent-preset-registry -> @deepseek-ai/dsh-agent-preset-registry
  preset-standard -> @deepseek-ai/dsh-agent-preset
  preset-ptc -> @deepseek-ai/dsh-agent-preset
  preset-minimal -> @deepseek-ai/dsh-agent-preset
  preset-cordis -> @deepseek-ai/dsh-agent-preset
```

## 設定宣言構成

dsh 設定菜單項目 `$DSH_HOME/settings.yaml`（書類備份、hot reload）格納。`nixkits.dsh.settings` 宣言構成（namespace → section）：

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
| `agent-preset-registry` | `selectedDefault`（預設 id、`.volatile()`——settings 側 唯 此；行 config `default` **必須 行 config**、settings 欄 非） | Agent 預設 登録表。**0.1.x `agent-presets`（複数形）行 與 其 `roots` 機構 0.2.0 不存在**；既定預設 本行 `config.default` 宣言、残留 旧 key 誰 也 読 不——本模組 残留 評価期 error 化 |
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
| `nixkits.dsh.agentPresets` | **既 settings namespace 非**：`agent-preset-registry` 行 `config.default`（行 config）出。settings 側 `selectedDefault` 書 場合 脱出艙 `settings."agent-preset-registry".selectedDefault` | `agent-preset-registry` 行 = `@deepseek-ai/dsh-agent-preset-registry`（0.2.0 以降；0.1.x 複数形 `@deepseek-ai/dsh-agent-presets` 既 不存在） |
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
| **両通道**（stable `0.2.0-rc.2`、alpha `0.2.1-alpha.1`） | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |

`deepseek-flash` 三 目録 **全部 存在**、且 **各目録 image modality 宣言** 唯一 之 id —— 此 模塊 既定値 選択 理由。他 画像対応 id `deepseek-v4-flash-vision-exp` 古 二 目録 限 存在、上流 2026-09-10 廃止 為、既定値 使用 不可。

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
