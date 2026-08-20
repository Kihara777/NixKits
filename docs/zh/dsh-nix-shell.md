# dsh-nix-shell

中文 | [English](../en/dsh-nix-shell.md) | [日本語](../ja/dsh-nix-shell.md)  | [偽中国語](../pcn/dsh-nix-shell.md)

DeepSeek Harness（DSH）的 NixOS 感知 Shell 工具插件。在 NixOS 上，dsh 进程的 PATH 常不含 bash（`/bin/bash` 不存在），内置 bash 工具每次调用报 `spawn bash ENOENT`。本插件注册模型工具 `nix_shell`：优先使用 PATH 可解析的 bash（健康环境下退化为普通 shell 工具），失败时回退到 Nix store 中的 shell 路径，并为每个子进程注入 NixOS 完整 PATH。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | DSH Host 插件（npm 包）|
| npm 名 | `@kihara777/dsh-nix-shell` |
| 版本 | `0.2.0` |
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
| `sudoSocketPath` | `""`（关闭） | 外部 sudo 守护套接字路径；亦可经环境变量 `NIXKITS_SUDO_SOCKET` 提供 |

## sudo 守护集成

dsh 沙箱中 `sudo` 的 setuid 被剥离，无法直接提权。插件在**初始化时**探测外部 sudo 守护套接字（组合 config 的 `sudoSocketPath`，回退环境变量 `NIXKITS_SUDO_SOCKET`），存在即启用 `sudo`/`justification` 参数；`sudo: true` 的请求不再本地执行，而是整单（command/cwd/env/timeout）经 Unix 套接字交由守护以 root 执行：

```
nix_shell(sudo=true)
  └─ Unix 套接字 ──▶ systemd 套接字激活（nixkits-sudo@.service, root）
                       └─ nixkits-sudo-exec.js：单请求单连接，JSON 请求/响应
```

- **访问控制边界**：套接字文件归 dsh 服务用户所有且 `0600`（`SocketUser`/`SocketMode`），仅该用户可连接——相当于为该用户提供免密 root 执行入口
- **审计**：`justification` 必填，随结果回显；服务 stderr 入 journal
- 模块一键开启：`nixkits.dsh.sudo.enable = true`（自动生成 socket + 每连接 root 服务 + 注入 `NIXKITS_SUDO_SOCKET`）
- 守护不可用时 `sudo` 参数不出现；套接字消失后调用返回明确错误

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
- insert:
  - id: tool-nix-shell
    name: '@kihara777/dsh-nix-shell'
```

> **注意**：新条目必须包裹在 `- insert:` 操作下——裸 `- id:` 行只补丁已有条目，dsh 会报 `patch: entry … not found` 并丢弃该行；包本身需位于 profile 可解析处（`$DSH_HOME/node_modules` 或 dsh 安装树的 node_modules）。

工具调用：

```
nix_shell(command = "nix flake check", workdir = "/path/to/flake")

# 经外部 sudo 守护进程以 root 执行（需先部署守护，见「sudo 守护集成」）
nix_shell(command = "nixos-rebuild switch --flake /etc/nixos", sudo = true, justification = "...")
```
