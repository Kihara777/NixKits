# NixOS模式 (Agent 预设)

中文 | [English](../../en/modes/nixos.md) | [日本語](../../ja/modes/nixos.md)  | [偽中国語](../../pcn/modes/nixos.md)

> 基于创造模式的 NixOS 专用代理：会话初始化校验宿主系统（非 NixOS 拒绝一切执行），加载 `nixos_shell` / `nixos_cli` 与 NixOS 高效开发提示词。

## 基本信息

| 项目 | 值 |
|------|-----|
| 模式 id | `nixos` |
| 分发方式 | dsh-nixos-shell 包内 `presets/nixos-mode/`，seed-once 复制到 `$DSH_HOME/.agent-presets/nixos` |
| 开启选项 | `nixkits.dsh.presets.nixosMode = true` |
| 派生自 | 创造模式（随 dsh 分发的 `cordis` 预设） |
| 文档 | [dsh-nixos-shell.md](../dsh-nixos-shell.md)（分发本模式的包） |

## 行为

- **宿主校验**：`nixos-gate` 在 apply 时读 `/etc/NIXOS` 与 `/etc/os-release`；非 NixOS 则注册工具守卫拒绝一切执行，并注入拒绝提示词（要求切回其他模式），本机不装 NixOS 也能安全挂载。
- **工具**：`nixos_shell`（PATH 注入 / `nix shell` 工具引导 / sudo 守护路由）与 `nixos_cli`（只读诊断：capabilities / system-status / generations / journal / audit-store-paths）。
- **提示词**：NixOS 高效开发指南（声明式系统本质、包管理、路径陷阱）。
- **技能**（5 个）：预设自带的 `cordis-plugin-development`、`editing-cordis-compositions`，加上从仓库 `skills/` 树经构建期子集 `skills-nixos/` 注册的 `nixos-modern-cli`、`recover-nixos-config`、`nixos-specialisation-tuning`。
- **组合**：创造模式的完整工具面 + `persona` 行（`complete: true`）+ `nixos-gate` + `nixos-shell` 两行。

## persona 行（预设身份）

组合中挂载 `@deepseek-ai/dsh-persona` 行，为该会话提供身份提示词（遮蔽部署级默认 persona）：

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `prefix` | string | —（**必填**） | 身份提示词前缀；缺失时插件加载失败（`$.prefix missing required value`） |
| `suffix` | string | `""` | 追加在运行时上下文之后的后缀 |
| `complete` | boolean | `false` | 置 `true` 时该 persona 作为完整提示词，不再拼接运行时上下文 |
| `includeRuntimeContext` | boolean | `true` | 是否附加上下文（模型、工作目录等） |

> **升级注意**：`prefix` 在 dsh 0.1.5-alpha.2 起为**必填**（此前字段名为 `text`）。若 preset 仍写 `text`，persona 插件加载失败会**连累整个会话创建**——`session/create` 失败后，设置界面、llm 提供方目录、会话历史均无法加载，前端表现为 `llm/listProviders failed: Failed to fetch` 与 `commands/list` 无限重试。**该症状与「模型界面报错」同源，勿误判为网络/反代问题**；升级 dsh 后应校验 preset 中各插件行的 config schema。

## 安装

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

rebuild 后在会话模式选择器里选「NixOS模式」即可。

## 注意

- **seed-once**：仅当 `$DSH_HOME/.agent-presets/nixos` 不存在时才复制；此后该目录归用户所有（模块会放开写权限），仓库升级不再覆盖它。
- 门控入口是包内子路径 `@kihara777/dsh-nixos-shell/nixos-gate`，只在预设组合中挂载，不影响全局会话。
