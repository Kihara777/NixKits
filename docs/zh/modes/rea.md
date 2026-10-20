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

在维护模式的全部能力之上追加一个**自带插件** `@kihara777/dsh-nixos-shell/rea-mcp`：

| 项 | 值 |
|----|-----|
| 连接时机 | `agent/session-start`——**每个选了本预设的会话各一条**，会话结束即断开 |
| 传输 | stdio JSON-RPC，`args: ['mcp']` |
| 可执行文件 | `$REA_BIN_PATH`（模块导出为 `pkgs.rea` 的 `bin/rea`） |
| 工具命名 | `mcp__rea__<原名>`，注册到**该 agent 的 scope** |

由此得到三件事：

- **全量工具**：REA 的 207 个工具（6.7.0 的 `tools/list` 实测）全部注册为 `mcp__rea__*`，`inputSchema` **原样**交给注册表——不做「JSON Schema → dsh 简写 spec」的转换，因为那种转换器写歪了会**静默拒掉合法调用**。工具表很长是它的代价：本模式面向「我要全部逆向能力」的场景。
- **只有本模式的会话才有这些工具**：这是自己写 `rea-mcp`、而不是挂一条 `@deepseek-ai/dsh-mcp-client` 的唯一原因（见下）。
- **维护模式的一切照旧**：宿主校验、`nixos_shell` / `nixos_cli`、文档与维护日志技能、四语约定都在——分析出来的结论要写回仓库时，工作流已经在那儿了。

### 为什么不用 `@deepseek-ai/dsh-mcp-client`

第一版就是那么做的。2026-10-20 在真实部署里量到的结果：

- 预设是 **eager activation**——dsh 启动 4 秒后 `rea mcp` 就被 spawn，**那时还没有任何会话**；
- 工具注册落到 root scope，于是**掌灯模式的会话**也背上 207 个 `mcp__rea__*`（会话请求头里 31 + 207 = **238** 个工具）。

「模式」的语义是「只有选它的会话才有这些工具」，所以这一层自己写：连接与注册都绑在 `agent.ctx` 上，会话销毁时断开。

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
| 预设声明被平台接受 | ✅ `AgentPresetRegistry.mount()` 报 OK |
| REA MCP 服务真的起来了 | ✅ 部署后 dsh 启动 **4 秒**即 spawn（pid 实测，存活 5 小时+，8 条 pipe 连着 dsh） |
| 207 个工具真的进了模型请求 | ✅ 会话记录 `request/header` 里数到 **207** 个 `mcp__rea__*`（工具总数 238） |
| **只对本模式的会话可见** | ⏳ 改用 `rea-mcp` 之后待验：非 rea 会话应回到 31，rea 会话应为 238 |

前两行与第三行不是一回事：进程活着只说明连接活着，工具进没进请求要数请求头。
而「进了一个会话」与「只进这个模式的会话」又是两回事——第一版正是在这里出的错。
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
