# dsh-nix-shell

中文 | [English](../en/dsh-nix-shell.md) | [日本語](../ja/dsh-nix-shell.md)  | [偽中国語](../pcn/dsh-nix-shell.md)

DeepSeek Harness（DSH）的 NixOS 感知 Shell 工具插件。在 NixOS 上，dsh 进程的 PATH 常不含 bash（`/bin/bash` 不存在），内置 bash 工具每次调用报 `spawn bash ENOENT`。本插件注册模型工具 `nix_shell`：优先使用 PATH 可解析的 bash（健康环境下退化为普通 shell 工具），失败时回退到 Nix store 中的 shell 路径，并为每个子进程注入 NixOS 完整 PATH。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | DSH Host 插件（npm 包）|
| npm 名 | `@kihara777/dsh-nix-shell` |
| 版本 | `0.1.0` |
| 许可 | MIT |
| 工具名 | `nix_shell` |

## 架构

```
模型 ⇐ 工具注册（ctx.tools）⇐ 插件 ⇐ ctx.subprocess ⇐ bash -c <command>
                                      ⇑ ctx.timer（超时截止）
```

- 纯 Host 插件：仅消费能力接缝（`subprocess`/`timer`/`tools`），不发布服务，可与 `tool-bash` 一样裸放在组合中
- 依赖 peer（`cordis`/`dsh-subprocess`/`dsh-timer`）由宿主 dsh 树提供，与 dsh 生态一致
- **不应用沙箱执行策略**——定位是内置沙箱 bash 工具无法启动时的过渡桥；模块 PATH 修复（见 [dsh](dsh.md)）后优先使用内置工具

## 配置

| 项 | 默认 | 说明 |
|------|------|------|
| `toolName` | `nix_shell` | 注册的工具名 |
| `shellPath` | `/run/current-system/sw/bin/bash` | PATH 解析失败时的回退 shell |
| `pathEnv` | NixOS 布局 | 注入子进程的 PATH（含 `$USER` 展开）|
| `defaultTimeoutMs` | `300000` | 默认超时 |
| `maxTimeoutMs` | `3600000` | 超时上限 |
| `stdoutMaxBytes` / `stdoutSpillMaxBytes` | 2 MiB / 16 MiB | 输出内存上限与完整落盘上限 |
| `graceMs` | `5000` | 终止宽限 |

## 使用

推荐经 `nixkits.dsh.plugins.packages` 声明式安装（自动注入 node_modules + 生成组合行）：

```nix
{
  nixkits.dsh.plugins.packages = [{
    package = pkgs.dsh-nix-shell;
    id = "tool-nix-shell";
    name = "@kihara777/dsh-nix-shell";
  }];
}
```

组合行手工挂载（npm 安装于 dsh 可解析处时）：

```yaml
- id: tool-nix-shell
  name: '@kihara777/dsh-nix-shell'
```

工具调用：

```
nix_shell(command = "nix flake check", workdir = "/path/to/flake")
```
