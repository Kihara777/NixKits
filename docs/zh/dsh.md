# dsh

中文 | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本信息

| 项目 | 值 |
|------|-----|
| 类型 | Node.js 应用（CLI） |
| 上游 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.0-rc.6` |
| 许可 | MIT |
| 命令 | `dsh` |

## 安装

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

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
| `extraPatch` | 手写 cordis.patch.yml 片段（如 MCP 服务） |
