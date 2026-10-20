# 狐莉模式 (Agent 预设)

中文 | [English](../../en/modes/foxli.md) | [日本語](../../ja/modes/foxli.md)  | [偽中国語](../../pcn/modes/foxli.md)

> 派生自 NixOS 模式的「瑞士军刀」预设：**日常维护、开发与逆向一体**。它同时是**下放给社区的能力边界**——掌灯模式派生自它，只再加私有适配层。

## 基本信息

| 项目 | 值 |
|------|-----|
| 模式 id | `foxli` |
| 分发方式 | dsh-nixos-shell 包内 `presets/foxli-mode/preset.patch.yml`，作为一条 `@deepseek-ai/dsh-agent-preset` patch 行 |
| 开启选项 | `nixkits.dsh.presets.foxliMode = true` |
| 派生自 | [NixOS模式](nixos.md)（正文 + 两块固定追加：**维护**、**逆向**） |
| 依赖包 | `nixkits.dsh.presets.reaPackage`（默认 `pkgs.rea`） |
| 文档 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（分发本模式的包）、[rea.md](../rea.md)（REA 包本身） |

## 三层派生

```
NixOS模式（最小 NixOS 适配）
  └─ 狐莉模式（维护 + 开发 + 逆向）      ← 本页；下放社区的能力到此为止
       └─ 掌灯模式（在 Kitsunome，读本仓这份正文 + 私有追加块）
```

**为什么合成一层**：原来的维护模式与逆向模式各自都是「NixOS + 一块」，分开放意味着下游要派生两次、技能清单要维护两份——而掌灯那份清单**没有任何判据在看**（2026-10-21 因此漏掉三个技能才发现）。合并之后下游只读这一份。

## 行为

在 NixOS 模式的全部能力之上追加**两块**。

### 维护块

- **运行时技能**：`maintenance-skills` 入口在 apply 时从**构建期嵌入**的仓库 `skills/` 树注册 `write-project-docs`、`write-maintenance-log`、`nix-flake-update-check`、`nixkits-check-updates`、`upstream-audit`、`nixkits-package-upstream`、`agent-self-maintenance`，并自动发现全部 `translate-*` 语言扩展。
- **维护工作流提示词，分两层**：

  | 段名 | 作用域 | 内容 |
  |------|--------|------|
  | `maintenance-workflow`（序号 901） | **通用**——任何仓库都成立 | 按逻辑类别分批提交、推送后记录、文档与代码同步、修复泛化到技能、技能内容单一来源 |
  | `maintenance-workflow-repo`（序号 902） | **本仓（NixKits）约定** | 四语与文档基准（`docs/zh/` 先写）、`write-maintenance-log` 为准绳、条目数一致的可核验判据、技能树单一来源 |

  判据只有一句：**这条规矩换个仓库还成立吗？** 成立留在通用层，不成立进适配层。

### 逆向块

一条自带插件 `@kihara777/dsh-nixos-shell/rea-mcp`：

| 项 | 值 |
|----|-----|
| 连接时机 | `agent/session-start`——**每个选了本模式的会话各一条**，会话结束即断开 |
| 传输 | stdio JSON-RPC，`args: ['mcp']` |
| 可执行文件 | `$REA_BIN_PATH`（模块导出为 `pkgs.rea` 的 `bin/rea`） |
| 工具命名 | `mcp__rea__<原名>`，注册到**该 agent 的 scope** |

REA 的 207 个工具（6.7.0 的 `tools/list` 实测）全部注册，`inputSchema` **原样**交给注册表——不做「JSON Schema → dsh 简写 spec」的转换，因为那种转换器写歪了会**静默拒掉合法调用**。工具表很长是它的代价。

**为什么不用 `@deepseek-ai/dsh-mcp-client`**：第一版就是那么做的。2026-10-20 的真实部署量到：预设是 **eager activation**（dsh 启动 4 秒后 `rea mcp` 就 spawn，那时还没有任何会话），工具注册落到 root scope，于是**掌灯模式的会话**也背上 207 个 `mcp__rea__*`（请求头里 31 + 207 = **238** 个工具）。「模式」的语义是「只有选它的会话才有」，所以这一层自己写。

## 前置条件

`pkgs.rea` 来自 NixKits overlay（`nixpkgs.overlays = [ inputs.nixkits.overlays.default ]`）。没加 overlay 时显式传 `presets.reaPackage`，否则求值会以「attribute 'rea' missing」失败——**显式失败，不是静默跳过**。

模块在 `presets.foxliMode = true` 时把 `REA_BIN_PATH` 注入 dsh 服务，预设正文里因此**不含任何 store 路径**（正文要能逐字节派生，也要能在没有 Nix 的机器上读）。

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
| **只对本模式的会话可见** | ⏳ 改用 `rea-mcp`（按会话）之后待验：非本模式的会话应回到 31，本模式的会话应为 238 |

前两行与第三行不是一回事：进程活着只说明连接活着，工具进没进请求要数请求头。而「进了一个会话」与「只进这个模式的会话」又是两回事——第一版正是在这里出的错。

## 启用

```nix
{
  nixkits.dsh = {
    # 预设里的 `@kihara777/dsh-nixos-shell/*` 行要靠这个注入才解析得到
    plugins.packages = [{
      package = pkgs.dsh-nixos-shell;
      id = "nixos-shell";
      name = "@kihara777/dsh-nixos-shell";
    }];
    presets.nixosMode = true;     # 狐莉模式派生自它
    presets.foxliMode = true;
  };
}
```

## 派生关系

狐莉模式的组合文件 = NixOS 模式的 `plugins:` 正文 + **两块固定追加**（维护块、逆向块，含注释），除此之外不得有任何差异。

```yaml
# 维护块
- id: maintenance-skills
  name: '@kihara777/dsh-nixos-shell/maintenance-skills'
# 逆向块
- id: rea-mcp
  name: '@kihara777/dsh-nixos-shell/rea-mcp'
```

`develop/check-preset-derivation.py` 逐字节核对，并挂入 `nix flake check`（CI 每次 push 执行）：`PATCH_FOXLI_DELTA = PATCH_MAINTENANCE_DELTA + PATCH_REA_DELTA`——两块各留独立常量，否则 diff 读不出「加了什么」。刻意变更追加块本身时，同步更新脚本里的常量。

**掌灯模式的派生不在这里**：它在 Kitsunome，构建期读本页这份正文再拼私有追加块，由那边的检查器核对。

## 怎么确认它真的挂上了

看会话里有没有 `mcp__rea__*` 工具；或看设置里 `preset-foxli` 那一行的 `fiberPhase`。**「配置文件里写了」不等于「挂载成功」**——预设行的激活失败会留在 roster 上并带诊断信息，不会静默消失。
