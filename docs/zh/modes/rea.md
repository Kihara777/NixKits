# 逆向模式 (Agent 预设)

中文 | [English](../../en/modes/rea.md) | [日本語](../../ja/modes/rea.md)  | [偽中国語](../../pcn/modes/rea.md)

> 基于维护模式的逆向工程代理：在维护模式的**全部能力**之上，把 REA（Reverse Engineer Anything）的 MCP 服务挂进本会话——工具名为 `mcp__rea__*`，全量注册。

## 基本信息

| 项目 | 值 |
|------|-----|
| 模式 id | `rea` |
| 分发方式 | dsh-nixos-shell 包内 `presets/rea-mode/preset.patch.yml`，作为一条 `@deepseek-ai/dsh-agent-preset` patch 行 |
| 开启选项 | `nixkits.dsh.presets.reaMode = true` |
| 派生自 | [维护模式](maintenance.md)（组合末尾追加固定行块） |
| 依赖包 | `nixkits.dsh.presets.reaPackage`（默认 `pkgs.rea`） |
| 文档 | [rea.md](../rea.md)（包本身）、[dsh-nixos-shell.md](../dsh-nixos-shell.md)（分发本模式的包） |

## 行为

在维护模式的全部能力之上追加一条 `@deepseek-ai/dsh-mcp-client` 行：

| 项 | 值 |
|----|-----|
| `serverName` | `rea` |
| `transport` | `stdio` |
| `command` | `$REA_BIN_PATH`（模块导出为 `pkgs.rea` 的 `bin/rea`） |
| `args` | `['mcp']` |
| `failOnStartupError` | `false` |

由此得到三件事：

- **全量工具**：`mcp-rea` 行把 REA 的 MCP 工具全量注册为 `mcp__rea__*`；REA 服务端 `tools/list` 实测 **207 个**（**「行写好了」与「会话里真的有这 207 个工具」是两件事**，见下方「验证状态」）。`dsh-mcp-client` **没有**白名单/过滤选项（核过它的 README 与 config 字段表），所以「只挑一部分」的唯一办法是不挂这条行——本模式面向「我要全部逆向能力」的场景，**工具表很长是它的代价，不是缺陷**。
- **维护模式的一切照旧**：宿主校验、`nixos_shell` / `nixos_cli`、文档与维护日志技能、四语约定都在——分析出来的结论要写回仓库时，工作流已经在那儿了。
- **REA 起不来不拖垮预设**：`failOnStartupError: false`。REA 挂掉时维护模式的其余能力仍然可用，缺的只是 `mcp__rea__*` 这一组工具（日志里会有连接失败）。

## 前置条件

`pkgs.rea` 来自 NixKits overlay（`nixpkgs.overlays = [ inputs.nixkits.overlays.default ]`）。没加 overlay 时显式传 `presets.reaPackage`，否则求值会以「attribute 'rea' missing」失败——**显式失败，不是静默跳过**。

模块在 `presets.reaMode = true` 时把 `REA_BIN_PATH` 注入 dsh 服务，预设正文里因此**不含任何 store 路径**（正文要能逐字节派生，也要能在没有 Nix 的机器上读）。

## 已知边界

与 [rea 包文档](../rea.md) 同一套，不在此重复。三条最容易被误读的：

| 事项 | 实际情况 |
|------|---------|
| `rea doctor` 的宿主机判定 | NixOS 上报 `unsupported_host`（上游按 apt/dnf/pacman 家族识别发行版）。**静态分析实测照常可用**——那是判定口径，不是运行前提 |
| frida 动态插桩 | 本包内不可用（离线构建 + `--ignore-scripts`） |
| Hopper / Ghidra / IDA、JADX | 自备；JDK 与 `ps` 已随 `pkgs.rea` 提供 |

## 验证状态

| 层 | 结果 |
|---|---|
| 预设声明被平台接受 | ✅ `AgentPresetRegistry.mount()` 报 OK（一次性 `DSH_HOME`，34 行插件） |
| 包解析与插件加载 | ✅ 同上——`@kihara777` 的插件行都能解析 |
| **MCP 连接与工具注册** | ⚠️ **未验**：`dsh headless` 的一次性任务里，agent 不会选择自定义预设，预设的插件因此没有被激活（实测：挂载后 `rea mcp` 子进程 **0 个**，模型请求体里也没有 `mcp__rea__*`）。要验这一层，只能在一个**真的选了逆向模式**的会话里看工具表。 |

这条区别值得写下来：**「mount() 成功」不等于「有 agent 在用这个预设」**。
`mount()` 证明的是声明合法、包能解析、平台接受它；它不证明 persona、工具、MCP 连接在会话里真的生效。

## 启用

```nix
{
  nixkits.dsh = {
    # 预设里的 `@kihara777/dsh-nixos-shell/maintenance-skills` 等行要靠这个注入才解析得到
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.maintenanceMode = true;   # 逆向模式派生自维护模式
    presets.reaMode = true;
  };
}
```

## 派生关系

逆向模式的组合文件 = 维护模式的 `plugins:` 正文 + **末尾追加固定的 `mcp-rea` 行块**（含注释），除此之外不得有任何差异。

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

派生链是**三段**：NixOS模式 → 维护模式 → 逆向模式。`develop/check-preset-derivation.py` 逐段逐字节核对，并挂入 `nix flake check`（CI 每次 push 执行）：改 NixOS模式漏了维护模式，第一段先响；改维护模式漏了逆向模式，第二段响。刻意变更追加块本身时，需同步更新脚本里的 `PATCH_REA_DELTA` 常量。详见仓库 `AGENTS.md`「预设」一节。

## 怎么确认它真的挂上了

看会话里有没有 `mcp__rea__*` 工具；或在设置里看 `preset-rea` 那一行的 `fiberPhase`。**「配置文件里写了」不等于「挂载成功」**——预设行的激活失败会留在 roster 上并带诊断信息，不会静默消失。
