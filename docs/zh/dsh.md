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
