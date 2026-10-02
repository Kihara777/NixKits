# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.2.0-rc.2` |
| 开发通道 | `dsh-alpha 0.2.0-rc.2`（npm `next` dist-tag） |
| 许可 | MIT |
| 命令 | `dsh` |

## 版本通道

NixKits 仿 ruyi 的薄包装模式（主定义 + 版本/hash 覆盖包装）同时提供多个 dsh 版本：

| 包 | 通道 | 版本 | 说明 |
|----|------|------|------|
| `pkgs.dsh` | stable | `0.2.0-rc.2` | npm `latest` dist-tag，默认；**预设内容**冻结在钉住的 rev |
| `pkgs.dsh-alpha` | alpha | `0.2.0-rc.2` | npm **`next`** dist-tag，跟踪 0.2.x 线的最新预发布；**预设内容**跟仓库 HEAD |

```nix
# 本机改用最新预发布版本
{ nixkits.dsh.package = pkgs.dsh-alpha; }
```

> **`dsh-alpha` 为什么跟 `next` 而不跟 `alpha`**（2026-10-02 改）。npm 上三个 dist-tag 的当前值是
> `latest` = `next` = `0.2.0-rc.2`，而 `alpha` = **`0.1.7-alpha.2`**——`alpha` 挂在 0.1.x 旧线上，
> 比 stable **低**。继续跟 `alpha` 等于把开发通道钉在一条已经落后的线上（本仓升级前正是如此：
> stable 钉 0.1.5-rc.2、alpha 钉 0.1.6-alpha.2，两个通道都得跨 0.1.x → 0.2.x 这条线）。
> 改跟 `next` 的语义是「0.2.x 线的最新预发布」：今天与 stable 同为 0.2.0-rc.2；将来
> `npm publish --tag next` 出 0.2.1-alpha.x 时自然跟上，不必再改判据。
>
> 两个通道今天的**唯一行为差异不在 dsh 版本上，而在预设内容**：stable 的预设冻结在
> `packages/dsh-nixos-shell-stable.nix` 钉住的 commit，alpha 的预设跟仓库 HEAD（见下文「模式」）。
>
> ⚠️ **0.2.0 是一次预设格式断层**，与 0.1.x 不兼容：0.1.x 的目录式预设通道
> （`$DSH_HOME/.agent-presets/<id>/` + `agent.cordis.yml`）已被上游删除。升级前请先读下文
> 「模式」与「预设格式在 dsh 0.2.0 的变化」两节。内置插件清单随版本变化，升级前建议查看
> [changelog](https://github.com/deepseek-ai/deepseek-harness/releases)。

## 安装

```nix
# /etc/nixos/flake.nix — 引入 flake 并挂载模块
{
  inputs.nixkits.url = "github:Kihara777/NixKits";
  # nixosConfigurations.<host>.modules 中:
  #   nixkits.nixosModules.dsh
}
```

```nix
# 模块配置（启用后同时把 dsh 加入 systemPackages）
{ nixkits.dsh.enable = true; }
```

> **二进制缓存**：flake 已通过 `nixConfig` 声明缓存（`nixkits.cachix.org`），首次构建时 Nix 自动提示启用；手动启用：`cachix use nixkits`。

## 使用

```bash
dsh --help
dsh web   # 启动浏览器 UI
```

## 服务配置

作为常驻 web 服务运行，使用 `nixkits.dsh` 模块。dsh 出于 RCE 安全只监听 loopback（`127.0.0.1:8615`），通过 lighttpd 反向代理暴露到对外端口 `8625`（自动开放防火墙）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh 拒绝非 loopback
    port = 8615;          # 内部 loopback 端口
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外端口
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

### 局域网访问（trustedHosts + 启动 URL）

dsh ≥ 0.1.2-alpha 的 web UI 入口用基于 Host authority 的 session cookie 认证，反代**不再重写 Host**（重写会让后端看到的 authority 与浏览器实际访问的不一致，cookie 无法跨反代匹配，表现为永远 401）。局域网设备通过 `http://<host>:8625` 访问时，其 authority 必须列入 `trustedHosts`。dsh 打印的 token 启动 URL 仅限 127.0.0.1，`launchUrlFile` 让模块在 dsh 启动时（ExecStartPost 捕获启动输出）把局域网设备的认证 URL 写入指定文件：

```nix
{
  nixkits.dsh = {
    trustedHosts = [ "harukax.lan" "192.168.31.241" ];  # 局域网 authority
    launchUrlFile = "/run/dsh/launch-urls";             # 启动 URL 输出文件
  };
}
```

> token 每次 dsh 重启轮换；换取到的 session cookie 在到期前持续有效。

### 免认证入口（autoAuth）

`reverseProxy.autoAuth` 用 lighttpd mod_magnet（模块自动换用 `enableMagnet` 编译的 lighttpd）在无 session cookie 的首页请求上 302 注入当前 launch token，局域网设备免手动认证一步直达。**该开关禁用 dsh 的入口认证（token 不再是秘密）**——仅当本地局域网完全可信时启用，否则任何能到达反代端口的设备都能获得完整 dsh 访问（含 RCE 面）：

```nix
{ nixkits.dsh.reverseProxy.autoAuth = true; }
```

> 注意：autoAuth 假定由网络层安全方案（如隔离的 LAN）负责访问边界。

> **PATH**：模块自动为服务注入 NixOS 完整 PATH（`/run/current-system/sw/bin` 等）。没有它，systemd 默认 PATH 找不到 bash，内置 bash 工具会报 `spawn bash ENOENT`。

> **HOME**：服务 HOME 指向运行用户的真实家目录（`users.users.<user>.home`，缺省回退 dshHome），代理因此继承用户自身的工具上下文——git/gh 凭据（`~/.config/gh`）、`~/.gitconfig`、npm/ssh 配置全部按 `$HOME` 解析。若把 HOME 指向 dshHome，git 的 gh credential helper 会找不到凭据导致推送失败。

## 插件声明式管理

dsh 的插件通过 `cordis.patch.yml` 运行时热加载（无需重启）。`nixkits.dsh.plugins` 提供声明式启停与配置：

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # 禁用插件
    settings."dsh-web-app" = { printUrl = false; };           # 配置覆盖
    extraPatch = "...";  # 手写片段（如 MCP 服务 insert 列表）
  };
}
```

| 选项 | 说明 |
|------|------|
| `disabled` | 禁用的插件 entry id，渲染为 `- id: <id> / disabled: true` |
| `settings` | 插件 config 覆盖（id → JSON，YAML flow style） |
| `packages` | 第三方插件包：注入 dsh 的 node_modules 并生成组合行（见下文） |
| `extraPatch` | 手写 cordis.patch.yml 片段（如 MCP 服务） |

### 第三方插件包

`plugins.packages` 把第三方 npm 插件包注入 dsh 的 node_modules 树（组合行按包名解析，必须以真实目录存在——符号链接会被 Node realpath 回插件自身的 store 路径，导致 peer 依赖无法命中 dsh 树），并自动在生成的 cordis.patch.yml 中注册组合行：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nixos-shell;           # NixKits 包（npm 构建）
    id = "nixos-shell";                   # cordis.patch.yml entry id
    name = "@kihara777/dsh-nixos-shell";  # 组合行引用的 npm 包名
  }];
}
```

> **dsh ≥ 0.1.2-alpha 插件兼容**：`ctx.connection.rpc.intercept` 的 shared RPC channel interceptor 互斥（每 channel 仅一个，重复注册直接 throw），`/api` 已被内置 typert-gateway 占用。第三方插件提供 RPC 方法请改用精确 fetch route（`ctx.connection.fetch.register` 注册如 `/api/<plugin>/<method>`，自行实现 `{ rpcId, method, payload }` → `{ type: "server-response", rpcId, result }` 的 RPC envelope 约定），避免顶掉内置 interceptor 导致所有 llm/session 等 RPC 404。插件依赖的 `@deepseek-ai/dsh-tools` 等 peer 版本需与宿主 dsh 通道对齐。

> **dsh ≥ 0.1.6-alpha.2 插件改名会硬失败**：内置插件 `dsh-workflow-worker-thread` 在 0.1.6 改名为 `dsh-workflow-ptc`（`id` 与包名同时变，`config` 不变），旧名的组合行已无对应包目录。dsh ≤ alpha.1 对无法解析的插件行**静默忽略**——预设照常加载、问题不留任何痕迹；alpha.2 的插件解析器把它变成**硬失败**，整份 Agent 预设挂不起来，只在建会话时报 `preset "…" failed to mount: row "…" names a plugin that cannot be resolved`。升级 dsh 前可先用 API 自检：`agentPresets/list` 返回的每条预设都带 `broken` 字段（**无该字段即通过上游健康判定，可挂载**）。

### 插件更新与零重启激活

插件包通过**稳定挂载点**加载：activation script 在每次 switch/boot 把 `/run/dsh/current`（dsh 含插件树）与 `/run/dsh/nixos-shell`（sudo 守护脚本）符号链接翻到当前代的 store 路径（GC 安全：目标始终处于当前 toplevel 闭包内，回滚自动翻回旧代路径）。`dsh.service` 与 `nixkits-sudo@.service` 的单元定义只引用这些稳定路径，因此**插件包更新不再改变 unit 内容**——switch-to-configuration 既不重启 dsh、也不 stop/start sudo socket，激活阶段对在途工具调用零中断。

代价与配套：dsh 是长驻进程，插件／预设包更新后需显式重启才生效——**先 `systemctl daemon-reload`，再 `systemctl restart dsh`**（`nixos_shell` 会把后者自动分离到瞬态单元，调用先于重启返回）。只 restart 有时仍执行上一代的 pre-start 脚本，而它正是把 `cordis.patch.yml` 拷进 `$DSH_HOME` 的那一步（预设根写在那份文件里），症状是「服务确实重启了、预设还是旧的」；重启后核对 `$DSH_HOME/profiles/<profile>/cordis.patch.yml` 里的 store 路径已翻新。sudo 守护按连接生成，新连接自动使用新脚本，无需任何重启。

## NixKits 插件

仓库内为 dsh 开发的独立插件**不在本文档展开**，各自维护独立文档（挂载方式见上文 `plugins.packages`）：

| 插件 | 说明 | 文档 |
|------|------|------|
| dsh-nixos-shell | NixOS 场景能力整合：`nixos_shell` 执行器（PATH 注入 / `nix shell` 工具引导 / sudo 守护路由）+ `nixos_cli` 只读诊断；随包分发 NixOS模式 / 维护模式两个 Agent 预设 | [dsh-nixos-shell.md](dsh-nixos-shell.md) |
| dsh-api-balance | webui 用量面板「用量 / 余额」切换：账户余额、日 / 月 / 30 日消耗图表与语音播报（含语音包格式指南） | [dsh-api-balance.md](dsh-api-balance.md) |

## 模式

「模式」是 dsh 的 **Agent 预设**：每个模式就是一个会话形态，自带身份提示词、工具面与提示词节。它们与插件同级、各自独立文档，互不影响：

| 模式 | id | 说明 | 分发方式 | 文档 |
|------|-----|------|---------|------|
| NixOS模式 | `nixos` | 初始化校验 NixOS 宿主（非 NixOS 拒绝一切执行）；加载 `nixos_shell` / `nixos_cli` 与开发提示词 | dsh-nixos-shell 包内，**profile patch 行** | [modes/nixos.md](modes/nixos.md) |
| 维护模式 | `maintenance` | 派生自 NixOS模式；注入 `write-project-docs` / `write-maintenance-log` / `nix-flake-update-check` / `nixkits-check-updates` / `translate-*` 技能与维护工作流 | dsh-nixos-shell 包内，**profile patch 行** | [modes/maintenance.md](modes/maintenance.md) |
| 新闻三要素模式 | `news-three-elements` | 派生自极简模式的只读创作模式：「新闻三要素」= 三位必须到齐的主角；素材优先（接不回来才拒）、素材共创先检索再改写（无检索即退稿）、在线技能包、开场问答、非简体中文一律拒绝 | **独立包** `dsh-preset-news-three-elements`，**profile patch 行 + 内容目录** | [modes/news-three-elements.md](modes/news-three-elements.md) |

```nix
{
  nixkits.dsh.presets = {
    nixosMode = true;         # id `nixos` —— NixOS模式
    maintenanceMode = true;   # id `maintenance` —— 维护模式（派生自 NixOS模式）
    newsThreeElements = true; # id `news-three-elements` —— 独立包
    # 预设内容来源：默认按 dsh 通道二选一（stable → dsh-nixos-shell-stable，
    # 预设冻结在钉住的 rev；alpha → dsh-nixos-shell，跟 HEAD）。一般不用手写，
    # 只有当 plugins.packages 注入的 @kihara777/dsh-nixos-shell 与它不同源时才需要对齐。
    # package = pkgs.dsh-nixos-shell;
  };
}
```

> **0.2.0 起只剩一种分发方式**：每个模式 = 一条 `@deepseek-ai/dsh-agent-preset` patch 行
> （模块并进 `$DSH_HOME/profiles/<profile>/cordis.patch.yml`），插件行正文**逐字**取自该包里的
> `preset.patch.yml`。0.1.x 的两种旧路（`nixosMode`/`maintenanceMode` 的 seed-once 目录复制、
> `newsThreeElements` 的额外 roster root）都已随上游删除——`roots` 机制整体不存在了。
> 新闻三要素模式是唯一仍需内容目录的：它的插件是预设自带的文件（不是 npm 包），模块把它组装到
> `$DSH_HOME/.agent-presets/news-three-elements/`（整体重建、非 seed-once），patch 行以相对
> 路径引用。各模式的行为、组合结构与维护规则见上表文档。

> **部署侧还有两个不随本仓分发的模式**：掌灯模式（`lampkeeper`，order 12）与 Ocean Spiral
> （`ocean-spiral`，order 14）。它们的内容源在私有仓（Kitsunome），但 0.2.0 的形态与上面三个
> 完全一样——一条 patch 行 + 一份组装到 `$DSH_HOME/.agent-presets/<id>/` 的内容目录，锚点写作
> `new URL('../../.agent-presets/<id>/', baseUrl)`（**Ocean Spiral 2026-10-02 才搬进仓库**，
> 在那之前它只有一份部署副本、没有仓库也没有播种）。它们的一致性检查也在那边：
> `develop/check-lampkeeper-derivation.py`、`develop/check-ocean-spiral-derivation.py`。

### 预设格式在 dsh 0.2.0 的变化（2026-10-02 已落地）

dsh 0.2.0 重构了 Agent 预设的承载方式，**目录式预设通道被删除**：

| | 0.1.x（0.2.0 起不再走） | 0.2.0（当前） |
|---|---|---|
| 预设形态 | `$DSH_HOME/.agent-presets/<id>/` 目录 | profile 用户 patch 层（`$DSH_HOME/profiles/<profile>/cordis.patch.yml`）里的一条 loader patch 条目 |
| 组合与元数据 | `agent.cordis.yml`（完整组合）+ `preset.yml`（`name` / `description`） | `@deepseek-ai/dsh-agent-preset` 行的 `config.plugins`（插件行）+ `config.name` / `config.description` |
| 发现方式 | `@deepseek-ai/dsh-agent-presets`（复数）扫 root | Loader 树本身；复数包在 0.2.0 **已不存在** |
| roster 排序 | 无 | `config.order`（内置预设占 1–4，跨预设必须唯一） |
| 宿主行 | `agent-presets`（复数），带 `roots` 表 | `agent-preset-registry`；`default` 是该行的**必填 config**，settings 里只剩 `selectedDefault` |

**仓库 HEAD 只维护新格式**：0.1.x 的 `agent.cordis.yml` 已从三个预设处删除，两套格式不并存于
HEAD，只在「取用点」分叉——stable 通道的预设内容取自
`packages/dsh-nixos-shell-stable.nix` 钉住的 commit（`0175f85`，**两套格式并存的最后一个提交**，
0.1.x 的使用者按 rev 取用），alpha 通道跟 HEAD。冻结的意义不是「stable 不更新」，而是**更新时机
可判**：HEAD 上改预设先经 alpha 通道实跑，确认无碍后把 `pinnedRev` 往前挪一格即可，是一次显式的
单行编辑，而不是随 HEAD 悄悄漂进稳定通道。

模块侧（`modules/dsh.nix`）怎么接线：

- 预设正文**逐字并进**模块本来就在生成的那份 `cordis.patch.yml`（不另建机制、不复制插件行——
  复制出来的副本一定会漂）；
- 读的是 `dsh-nixos-shell` 变体的 `passthru.presetsSource`（stable 变体用 `builtins.fetchTarball`
  取钉住的 rev，故是**求值期读源路径**，没有 import-from-derivation）；
- 通道判定取自 dsh 包自己声明的 `passthru.dshChannel`，所以「换通道」只需换
  `nixkits.dsh.package` 一行，预设内容跟着走；
- `nixkits.dsh.agentPresets.*` 改为下发 `- id: agent-preset-registry` 补丁行；**旧的
  `settings."agent-presets"` 直接报错**——它不会被任何插件读取，留着只会静默丢掉默认预设；
- 提示：注入的 `@kihara777/dsh-nixos-shell` 与 `presets.package` 必须是**同一个变体**（预设行的
  正文来自后者，技能根在运行期解析到前者），不一致时求值期会打一条 `lib.warn`。

**逐个插件的 config schema 差异**（用两个通道产物里各插件包的 `Config` schema 逐条比对，
`0.1.6-alpha.2` → `0.2.0-rc.2`）：

| 插件行 | 变化 | 对本预设的影响 |
|--------|------|----------------|
| `dsh-tool-bash` / `dsh-tool-pwsh` | 新增可选 `promoteOnTimeout`（默认 `true`） | 本预设**不写该键**（决定：行为默认值跟随上游）→ 0.2.0 起前台 bash 命中超时会**提升为后台任务**而不是被杀掉 |
| `dsh-tool-workflow` | 新增可选 `enableRunInBackground`（默认 `true`） | 未设该键 → 多出后台能力 |
| `dsh-tool-ask-user` | 由"无 Config"变为 `{ mode?: "legacy" \| "timed", timeout?: -1 \| number }`（默认 `legacy` / `120`） | 未设该键 → 行为与旧版一致 |
| `dsh-compaction-basic` | 新增可选 `headroomTokens`（`modelPolicies[]` 同名字段一并新增） | 未设该键 → 只多一个可调项 |
| `dsh-tool-jobs` | `maxConsecutiveWakes` 字段保留，但不再出现在 schema 默认值输出里 | 未设该键 |
| `dsh-tool-fs-search` | **无变化**：`sampleOverCapGlobResults` 为**必填布尔**，自 0.1.6 起即如此 | 旧文件已带 `false`，新文件照搬 |
| 其余 20 个插件行 | schema 逐字相同 | 无需改动 |

> `dsh-tool-subagent` 的 `backgroundMode` / `maxDepth` 联合类型、`dsh-plan-mode` 自实现的严格
> `{ section }` 校验（未知键即报错）、以及本仓 `@kihara777/dsh-nixos-shell` 的三行都在比对范围内，
> 均无变化。

> ⚠️ **`promoteOnTimeout` 是本次升级里唯一会改变日常行为的新默认值**（决策：**不写进预设**，
> 跟随上游）。它的效果是：前台 bash 调用命中超时后不再被杀掉，而是**提升为后台任务**继续跑，
> 调用方拿到一个 job id；`job_output` / `job_list` / `job_kill` 因此成为超时后的收尾手段。
> 需要旧行为（超时即杀）时，在预设里给该行显式写 `config.promoteOnTimeout = false`——
> 本仓刻意不做这个钉子，好让上游的默认值演进能到得了我们。

**新格式相对旧文件的四处必要差异**（照抄会出错）：

1. **`baseUrl` 语义变了**。0.1.x 里它是预设自己的目录，0.2.0 实测是 **profile 目录**
   （`$DSH_HOME/profiles/<profile>/`）。旧文件把 skills 根写作 `new URL('skills/', baseUrl)`，
   原样搬过去会指向 `<profile>/skills/`，技能**静默消失**；本仓两个预设改为从 `baseUrl` 解析
   `@kihara777/dsh-nixos-shell` 包根再拼 `presets/<mode>/`，私有仓的两个预设改为反推
   `../../.agent-presets/<id>/`——两处都带**存在性守卫**，指错即 `broken`，不会退化成"没有技能"。
2. 元数据（原 `preset.yml` 的 `name` / `description`）搬进 `config.name` / `config.description`。
3. 新增 `config.order`。
4. **插件行的相对路径要改锚**：相对说明符必须以 `.` 开头（loader 只把这种 name 按 `baseUrl`
   解析，**绝对路径会被当裸包名 import 而失败**），再加上 `baseUrl` 变成了 profile 目录，
   于是 `./plugins/x.js` 要写成 `../../.agent-presets/<id>/plugins/x.js`。副作用：预设自带的
   插件文件若按裸包名 import `@deepseek-ai/*` 的 peer，模块必须把 `@deepseek-ai` 也链进
   `$DSH_HOME/node_modules`，否则那一行只会报一句 `… never started`（详见下文「预设的挂载判据」）。

#### 预设的挂载判据（怎么知道它真的挂上了）

**「roster 里有它」不等于迁移成功**：预设挂不上时，0.2.0 只在 `agentPresets/list` 的每条条目上
给出 `broken` 字段——**无该字段即通过上游健康判定**。判据是可执行的：

```bash
# 一次性实例的做法：起 dsh → 抓 boot.log 里的 token → 换 cookie → 调 RPC
curl -sS -b cookies -H 'content-type: application/json' \
  -d '{"type":"client-request","rpcId":"1","method":"agentPresets/list","payload":{"args":{}}}' \
  http://127.0.0.1:<port>/api/agentPresets/list
```

2026-10-02 的落地验收（一次性 `DSH_HOME`，`dsh 0.2.0-rc.2`）：**9 条**（4 个内置 + `nixos`
order 10 + `maintenance` 11 + `lampkeeper` 12 + `news-three-elements` 13 + `ocean-spiral` 14）
**`broken` 全空**；三条反证都改**真文件里的一处**：

| 反证 | 改了什么（一处） | `agentPresets/list` 报出的 `broken` |
|------|-----------------|-----------------------------------|
| 包名 | `tool-fs-search` 的包名改成不存在的 `@deepseek-ai/dsh-tool-fs-searchX` | `tool-fs-search (@deepseek-ai/dsh-tool-fs-searchX): never started`（5 条预设同时报——它们都派生自同一份行） |
| 锚点 | Ocean Spiral 的技能根 `../../.agent-presets/ocean-spiral/` → `…ocean-spiral-typo/` | `skill-filesystem (…): ocean-spiral skill roots missing: <路径>` + `oceanspiral-scene (…): never started` |
| 组装 | `$DSH_HOME/node_modules` 里少链一条 `@deepseek-ai` | `lampkeeper-shell (../../.agent-presets/lampkeeper/components/lib/index.js): never started` |

最后一条是这次落地**真的修掉的一个坑**：预设自带的插件文件在 `$DSH_HOME/.agent-presets/<id>/…`
下，按裸包名 import peer 时 Node 从**文件所在目录**向上找 `node_modules`；模块此前只链
`@kihara777`，于是「重启 dsh 之后掌灯模式变 broken」——而两者在同一个 `$DSH_HOME` 下互相踩。
现在模块同时链 `@kihara777` 与 `@deepseek-ai` 两条。

**未决项（刻意未改）**：新格式文件里 persona 那句"预设住在 `$DSH_HOME/.agent-presets/<id>/` 目录"
在 0.2.0 已不成立（目录式**发现**通道被删；只有若干预设的**内容**仍组装在那里）。改写它会改变
**送进模型的提示词**，属行为变更，不在本次落地批准范围内——文件内留了
`⚠️ 未决项（2026-10-02 落地阶段刻意未改）` 注释，等维护者单独决定。

## sudo 守护

dsh 沙箱中 `sudo` 的 setuid 被剥离，代理无法提权（如 `nixos-rebuild`）。`sudo.enable` 部署一个 systemd **套接字激活的 root 执行器**（`nixkits-sudo@.service`，每连接运行一次 `nixkits-sudo-exec`），并向 dsh 服务注入 `NIXKITS_SUDO_SOCKET`。nixos-shell 插件初始化时探测该套接字，存在即启用 `sudo` 参数并路由请求：

```nix
{
  nixkits.dsh.sudo = {
    enable = true;
    socketPath = "/run/nixkits-sudo.sock";  # 默认
  };
}
```

> **安全模型**：套接字文件归 dsh 服务用户所有且 `0600`（`SocketUser`/`SocketMode`），仅该用户可连接——等价于为该用户提供免密 root 执行入口，请仅在信任该用户与代理行为的前提下开启。

## 插件清单

dsh 0.2.0-rc.2 的内置插件 entry id（`nixkits.dsh.plugins.disabled` 的可用值，`id -> 插件包`）：

> **清单生成方法**：`dsh --profile web --dump-default-config`（只读）输出即 `id -> name` 格式；升级 dsh 后用它重新生成本表，以所装版本的输出为准。本表对应 web profile 的 base + web-app 补丁集。

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

## 设置声明式配置

dsh 的设置菜单选项通过 `$DSH_HOME/settings.yaml` 文件备份 + 热加载。`nixkits.dsh.settings` 提供声明式配置（namespace → section）：

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

- namespace 对应设置 UI 的分区（如 `web-search-deepseek`、`llm-deepseek`、`ui-onboarding`）
- 值必须是 JSON 兼容数据（string/number/boolean/list/object）
- 生成 JSON（合法 YAML），dsh 热加载；空 `{}` 或缺失回退到 schema 默认值

### 可声明式配置的宿主 namespace

`nixkits.dsh.settings` 只能写入**宿主侧已通过 `settings.installSection` / `settings.register` 注册**的命名空间——这些值存 `$DSH_HOME/settings.yaml`，跨浏览器一致。下表 **15 个** namespace 及字段逐个从插件源码的 `z.object({...})` / `Schema.object({...})` 实测提取（**基线 `0.1.6-alpha.2`**）：

> ⚠️ **2026-10-02 迁移到 `0.2.0-rc.2` 时只逐项复核了与预设/权限相关的一行**
> （`agent-presets` → `agent-preset-registry`）；**其余 14 行尚未在 0.2.0 上全量重测**。
> 升级到 0.2.0 之后要动某个 namespace 前，请照下面的判据在**所装版本**上重跑一遍再改配置——
> 不要把这张表当成 0.2.0 的实测结果。

| namespace | 字段 | 说明 |
|-----------|------|------|
| `agent-default-model` | `provider`、`model`、`reasoningEffort`（`off`/`low`/`high`/`max`） | 新会话默认模型 |
| `agent-loop` | `maxParallelToolCalls`（整数 ≥1，默认 10） | 单轮并行工具调用上限 |
| `agent-preset-registry` | `selectedDefault`（预设 id，`.volatile()`——settings 侧只有它；行配置里的 `default` 是**必填行 config**、不是 settings 字段） | Agent 预设注册表。**0.1.x 的 `agent-presets`（复数）行与它整个 `roots` 机制在 0.2.0 已不存在**，默认预设改由本行的 `config.default` 声明；旧键留在 settings.yaml 里不会被任何插件读取，本模块对残留直接报错 |
| `llm-deepseek` | `protocol`、`apiKeyEnv`、`baseURL`、`thinking`、`reasoningEffort`、`maxTokens`、`defaultContextWindow`、`streamIdleTimeoutMs`、`models`、`retryPolicy`、文件/图片字节预算若干 | 原生 DeepSeek 适配器 |
| `llm-pi-ai` | `providers`（字典：路由 → 提供商 profile） | pi-ai 适配器的提供商路由表（本机 llama-local 路由在此） |
| `locale` | `preference`（BCP 47；内置 `zh`/`en`） | 界面语言 |
| `permission` | `defaultPreset`（**必填**；取值是 presets 表的键名） | 权限预设 |
| `shell` | `cwd`（**无默认值**）、`timeoutMs`、`maxTimeoutMs`、`maxOutputBytes`、`maxSpillBytes`、`graceMs` | 本地 shell 执行器限制（Linux 走 bash-local，win32 走 pwsh-local 且多一个 `pwshPath`） |
| `subagent` | `maxDepth`（整数 ≥0，默认 1）、`maxActiveSubagents`（整数 ≥1，默认 8） | 子代理深度与并发上限 |
| `subagent-model-selection` | `enabled`（布尔，默认 false）、`allowedModels`（`{provider, model}` 数组） | 子代理模型选择 |
| `ui-chat` | `transcriptView`（`normal`/`compact`） | 会话记录展示密度 |
| `ui-conversation` | `busyEnter`（`queue`/`steer`） | 忙碌时 Enter 行为 |
| `ui-onboarding` | `welcomeNoticeVersion` | 引导步骤状态（dsh 自写） |
| `ui-theme` | `preference`（`light`/`dark`/`system`）、`fontSize`（12–17） | 外观与主题 |
| `web-search-deepseek` | `apiKey`（secret）、`apiKeyEnv`、`baseURL`、`model`（默认 `deepseek-v4-flash`）、`apiVersion`、`maxTokens`（≥1，默认 4096）、`maxUses`（≥1，默认 5） | 联网搜索后端 |

> ⚠️ 本表曾按 `0.1.5-rc.2` 抄录，其中 **5 行与实测不符**，已于 2026-09-23 逐项核对修正：
> `locale` 的字段是 `preference` 而非 `language`；`ui-theme` 只有 `preference`/`fontSize`
> （无 `dark`/`light`/`body` 字段——`dark`/`light` 是 `preference` 的**取值**）；
> `shell` 不存在 `dshHome` 字段，实际是执行器限制六项；`subagent-model-selection`
> 的顶层是 `enabled`/`allowedModels`（`provider`/`model` 是**数组元素**的字段）；
> `agent-default-model` 仅 `provider`/`model` 必填，`reasoningEffort` 可省略。
>
> **判据**：该表只能靠读插件源码得出，任何"看起来合理"的字段名都可能是记忆的产物——
> 下次升级 dsh 时请重新实测，不要在此表上做增量猜测。

> ⚠️ **2026-10-02 第二次核对（`0.1.6-alpha.2`）**：条目数由 12 更正为 **15** —— 旧表
> **漏了三个宿主 namespace**：`llm-deepseek`、`llm-pi-ai`、`subagent`（前两者由
> 模型适配器注册、第三者由 `@deepseek-ai/dsh-subagent` 注册，旧的 grep 只覆盖了
> `installSection` 的调用点而漏看了它们）。同次核对还推翻了一条旧判断：
> 「`shell` 的 `cwd` 无默认值 ⇒ 不能部分声明」**是错的**——schemastery 里没写
> `.required()` 的字段本来就是可选的（实测 `z.object({cwd: z.string()})({})` 通过），
> 只有 `.required()` 才会让缺字段报 `missing required value`。
>
> 核对口径：以整仓 `grep -rn 'settings\.installSection(\|settings\.register('` 的
> **调用点**为准（`@deepseek-ai/dsh-settings` 自身与其读者 `dsh-tool-cordis` 是这套
> API 的**实现**，不注册 namespace）。

> **设置菜单的存储层边界**：并非设置 UI 里每一项都能用 `nixkits.dsh.settings` 声明式配置。**dsh-api-balance 的界面 / 语音设置**（语音提醒、底部统计条横向滚动、回车换行 + Shift+回车发送、移动端会话切换不弹键盘、TTS 后端）是**浏览器 localStorage 状态**（每浏览器独立、默认开启、UI 内切换），**不经过** `settings.installSection` 系统，因此 `$DSH_HOME/settings.yaml` / `nixkits.dsh.settings` **不会**覆盖它们。这类"每浏览器偏好"请在该插件的 `⚙ 设置` 面板内配置，或按设备部署独立浏览器。

### 结构化选项与逃生舱的分工

上表 15 个 namespace 都能经 `nixkits.dsh.settings.<namespace>` 直接写入——那是**无类型逃生舱**。它的代价分两种，**一种静默、一种响**：

- **字段名拼错 → 完全静默**。schemastery 的 `z.object` 是**开放**的：未知键被原样保留，而它本该写的那个字段照旧吃 schema 默认值。实测（`0.1.6-alpha.2`）`schema({ maxParallelToolCall: 4 })` 得到 `{ maxParallelToolCalls: 10, maxParallelToolCall: 4 }` —— 求值期不报错、运行期不报错、日志里也没有，**只有值没生效**。
- **类型错 / 取值越界 → 会响，但只在日志里**。dsh 拒绝该段：启动时让该 namespace 的注册直接失败，运行期热加载则打 `settings: keeping last good "<ns>" after invalid stored section` 的 warn 并保留上一份好值。

故本模块为其中 13 个提供了**结构化选项**（Nix 侧镜像上游 schema，把上述两类错误都变成求值期报错）：

| 选项 | 写入的 namespace | 对应插件 |
|------|------------------|----------|
| `nixkits.dsh.defaultModel` | `agent-default-model` | `@deepseek-ai/dsh-agent-default-model` |
| `nixkits.dsh.agentLoop` | `agent-loop` | `@deepseek-ai/dsh-agent-loop` |
| `nixkits.dsh.subagentModelSelection` | `subagent-model-selection` | `@deepseek-ai/dsh-tool-subagent` |
| `nixkits.dsh.permission` | `permission` | `@deepseek-ai/dsh-permission-presets` |
| `nixkits.dsh.agentPresets` | **不再是 settings namespace**：下发 `agent-preset-registry` 行的 `config.default`（行配置）。要写 settings 侧的 `selectedDefault` 走逃生舱 `settings."agent-preset-registry".selectedDefault` | `agent-preset-registry` 行 = `@deepseek-ai/dsh-agent-preset-registry`（0.2.0 起；0.1.x 的 `@deepseek-ai/dsh-agent-presets` 复数包已不存在） |
| `nixkits.dsh.subagent` | `subagent` | `@deepseek-ai/dsh-subagent` |
| `nixkits.dsh.shell` | `shell` | `@deepseek-ai/dsh-bash-local` / `dsh-pwsh-local`（namespace 归 `@deepseek-ai/dsh-shell`） |
| `nixkits.dsh.webSearchDeepSeek` | `web-search-deepseek` | `@deepseek-ai/dsh-web-search-deepseek` |
| `nixkits.dsh.llmDeepSeek` | `llm-deepseek` | `@deepseek-ai/dsh-llm-deepseek` |
| `nixkits.dsh.locale` | `locale` | `@deepseek-ai/dsh-client-locale` |
| `nixkits.dsh.ui.theme` | `ui-theme` | `@deepseek-ai/dsh-client-ui-theme` |
| `nixkits.dsh.ui.chat` | `ui-chat` | `@deepseek-ai/dsh-client-ui-chat` |
| `nixkits.dsh.ui.conversation` | `ui-conversation` | `@deepseek-ai/dsh-client-ui-conversation` |

**三者语义一致**：选项默认 `enable = false`（不写入 settings.yaml，该 namespace 回落 schema 默认）；`enable = true` 时按子选项生成该段；**`nixkits.dsh.settings.<同名 namespace>` 始终优先**于结构化选项生成的值。

剩下的两个 namespace **刻意不做结构化选项**，理由各自不同：

- `ui-onboarding`：纯客户端引导状态（`welcomeNoticeVersion` 由 dsh 在用户走完引导时自己写入）。声明式写它没有正当用途，写进去只会让引导流程按一个外部指定的版本号回放或跳过——属于"该由用户点、不该由 Nix 定"的状态。
- `llm-pi-ai`：字段是 `providers` 字典（路由 → 提供商 profile），而 profile 是**深层嵌套**的（`models` 目录、`modelOverrides`、`compat`、`thinkingBudgets`、`retryPolicy`…），其中 `api` 的枚举来自内置 pi-ai 协议注册表 `supportedProtocols()` —— **是一个随 pi-ai 版本漂移的开放集合**，类型化会立刻腐化成"看起来能配、实际拒绝新协议"。它在本机也已有更合适的落点：`nixkits.dsh.plugins.settings."llm-pi-ai".providers`（组合行 config，见上方「插件声明式管理」章节）。

关于字段的写入策略（哪些字段有具体默认值、哪些以 `null` 表示"不声明"）：

- schema 有默认值、且内置组合行 config 与之一致 → 用具体默认值无条件写入，语义与不声明等价；
- schema 无默认值（由部署/适配器/进程环境决定），或组合基线**已偏离** schema 默认 → 用 `null` 表示不声明，渲染时剔除。

第二条不是洁癖：`shell` 的 `timeoutMs` 就是实例——schema 默认 120000，而内置 `bash-sandbox` 行把它配成 **60000**。若"启用即全量写入"，`shell.enable = true` 会把 60000 悄悄改成 120000，正是本模块要防的那类静默改值。所以 `nixkits.dsh.shell.timeoutMs = null`（默认）保留 60000，显式填 120000 才是改回上游默认。同理 `web-search-deepseek.baseURL` 与 `llm-deepseek.baseURL` 留 `null`：它们未给出时会回落 `$DEEPSEEK_SEARCH_BASE_URL` / `$DEEPSEEK_BASE_URL`，写死字面量会遮蔽环境变量。

另外，`web-search-deepseek.apiKey` 刻意不镜像：它带 `role("secret")`，写进 settings.yaml 就等于把 API key 落到 `/nix/store`（世界可读）。密钥走 `apiKeyEnv` + systemd `LoadCredential`。

```nix
{
  nixkits.dsh = {
    # 新会话默认模型
    defaultModel = {
      enable = true;
      provider = "deepseek-official";
      model = "deepseek-flash";  # 三个版本目录都在，且三个都声明 image 模态的唯一 id
      reasoningEffort = "max";
    };
    # 单轮并行工具调用上限
    agentLoop = { enable = true; maxParallelToolCalls = 10; };
    # 子代理可选模型白名单（enable 同时把该特性的 enabled 打开）
    subagentModelSelection = {
      enable = true;
      allowedModels = [
        { provider = "deepseek-official"; model = "deepseek-flash"; }
      ];
    };
    # 新会话默认权限预设（取值来自组合行的 presets 表）
    permission = { enable = true; defaultPreset = "danger-full-access"; };
    # 新会话默认挂载的 Agent 预设
    agentPresets = { enable = true; default = "lampkeeper"; };
    # 子代理深度与并发上限
    subagent = { enable = true; maxDepth = 2; maxActiveSubagents = 12; };
    # 本地 shell 执行器：只写要改的字段，未写的不动组合基线（timeoutMs 基线 60000）
    shell = { enable = true; timeoutMs = 300000; maxTimeoutMs = 1800000; };
    # 联网搜索后端
    webSearchDeepSeek = { enable = true; model = "deepseek-flash"; maxTokens = 8192; };
    # 原生 DeepSeek 适配器：思考与流空闲超时
    llmDeepSeek = {
      enable = true;
      thinking = "enabled";
      reasoningEffort = "high";
      streamIdleTimeoutMs = 3600000;  # 分块间隔超时，不是总时长
    };
    # 界面语言固定为中文；不设则随各浏览器的 Accept-Language
    locale = { enable = true; preference = "zh"; };
    ui = {
      theme = { enable = true; preference = "dark"; fontSize = 14; };
      chat = { enable = true; transcriptView = "compact"; };
      conversation = { enable = true; busyEnter = "queue"; };
    };
  };
}
```

### 默认模型（defaultModel）

`nixkits.dsh.defaultModel` 为**新会话默认模型**提供结构化声明式配置（经 `@deepseek-ai/dsh-agent-default-model` 写入 `settings."agent-default-model"`）。默认 `enable = false`（不注入）；`enable = true` 时按下列子选项生成，**显式的 `nixkits.dsh.settings."agent-default-model"` 始终优先**于本选项生成的默认：

```nix
{
  nixkits.dsh.defaultModel = {
    enable = true;
    provider = "deepseek-official";  # 默认
    model = "deepseek-flash";        # 默认
    reasoningEffort = "off";         # 默认
  };
}
```

#### 模型目录随 dsh 版本走

`deepseek-official` 路由的模型目录是适配器**内置**的（`dsh-llm-deepseek` 的 `DEFAULT_MODELS`），不由设置文件决定，随 dsh 版本变化：

| dsh 版本 | 目录条目 | 其中声明 image 模态 |
|----------|----------|--------------------|
| stable `0.1.5-rc.2`、alpha `0.1.6-alpha.1` | `deepseek-flash`、`deepseek-v4-flash`、`deepseek-v4-pro`、`deepseek-v4-flash-vision-exp` | `deepseek-flash`、`deepseek-v4-flash-vision-exp` |
| alpha `0.1.6-alpha.2` | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |
| **两个通道 `0.2.0-rc.2`（当前）** | `deepseek-flash`、`deepseek-v4-pro` | `deepseek-flash` |

`deepseek-flash` 是三个目录**都存在**、且在其中**都声明 image 模态**的唯一 id —— 这也是模块默认值选它的理由。另一个能看图的 `deepseek-v4-flash-vision-exp` 只存在于两个较旧目录，且上游已于 2026-09-10 下线，不能作为默认值。

上游 2026-09-10 发布 DeepSeek-V4.1-Flash 时下线了 V4 Flash 与 V4 Flash Vision Exp，模型名收敛为 `deepseek-flash`（原生多模态，支持图像理解）与 `deepseek-v4-pro`；旧 id 出于兼容仍可调用，但由 V4.1-Flash 承接并按 Flash 计费（见[模型与价格](https://api-docs.deepseek.com/zh-cn/quick_start/pricing/)脚注）。

> ⚠️ **目录里没有的 id 不等于"等价地用着"**：dsh 把未收录的 id 当**纯文本**模型（`modelInfo` 回落 `inputModalities: ["text"]`），后果分两条路径走，**一条响、一条不响**：
>
> - **新贴的图当场被拒**：`session/prompt` 的附件准入读的是同一个 `inputModalities`，直接抛 `MODEL_DOES_NOT_SUPPORT_IMAGES`，界面显示"当前模型不支持图片，请切换支持图片的模型"。
> - **历史里已有的图被静默丢弃**：派发前 `projectImagesForTextModel` 把图片换成文本占位符，不报错，模型也从未看到图。
>
> 选默认值时务必挑目录里存在的 id。这个判定随 dsh 版本变化 —— 同一份设置在新版本上可能从"看图"变成"拒图"。

#### reasoningEffort 档位与开销

| reasoningEffort | 行为 | 开销 |
|-----------------|------|------|
| `off` | non-thinking：不生成思维链，映射为 `thinking:disabled` | **最省**（无 reasoning token），延迟最低；**FIM 补全仅支持该档** |
| `low` | 开启思考但力度最轻 | 比 off 稍贵（少量 reasoning token） |
| `high` | 默认档（dsh-llm-deepseek 适配器 default 即 high），质量/速度均衡 | 输出含推理段，token 占比上升 |
| `max` | 最高档推理，质量最强 | **最贵**（输出 token 占比最大） |

> `off` 映射为 `thinking:disabled` 是启用 FIM（Fill-In-The-Middle 补全）的前置条件（DeepSeek FIM 标注"仅非思考模式支持"）。上游 [FIM 补全 API](https://api-docs.deepseek.com/zh-cn/api/create-completion/) 的 `model` 只有 `deepseek-flash` 与 `deepseek-v4-pro` 两个取值，两者均为"仅非思考模式支持"。

