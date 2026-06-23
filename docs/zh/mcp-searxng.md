# mcp-searxng

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | [偽中国語](../pcn/mcp-searxng.md)

[SearXNG](https://docs.searxng.org) 的 [MCP Server](https://modelcontextprotocol.io)，为 AI 助手提供网页搜索能力。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 1.7.1 |
| 上游 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## 引用

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## 开箱即用配置

以下提供 SearXNG + lighttpd 反向代理的完整 NixOS 配置，可直接使用：

```nix
{ config, ... }:
let
  searxKey = "YOUR_SECRET_KEY";  # 替换为随机字符串
in
{
  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings = {
      search.formats = [ "html" "json" ];
      server = {
        bind_address = "127.0.0.1";
        port = "42701";
        secret_key = searxKey;
        limiterSettings = {
          botdetection.trusted_proxies = [ "127.0.0.1/32" ];
          real_ip.x_for = 1;
        };
      };
    };
  };

  services.lighttpd = {
    enable = true;
    port = 4270;
    enableModules = [
      "mod_access"
      "mod_alias"
      "mod_proxy"
      "mod_setenv"
    ];
    extraConfig = ''
      proxy.server = ( "" => (
        ( "host" => "127.0.0.1", "port" => 42701 )
      ))
      setenv.add-request-header = (
        "X-Real-IP"       => "%{remote-addr}e",
        "X-Forwarded-For"  => "%{remote-addr}e",
        "X-Forwarded-Proto" => "http"
      )
    '';
  };
}
```

## MCP 客户端配置

```json
{
  "mcpServers": {
    "searxng": {
      "command": "mcp-searxng",
      "env": { "SEARXNG_URL": "http://127.0.0.1:4270" }
    }
  }
}
```

> SearXNG 需启用 JSON 格式（已在上述 `settings.search.formats` 中配置）。

## CodeWhale 配置

CodeWhale 的 MCP 配置文件位于 `~/.deepseek/mcp.json`。添加 mcp-searxng 后 **必须手动设置 `SEARXNG_URL`** 环境变量——`codewhale mcp add` 命令不会自动填充 `env` 字段。

```json
{
  "servers": {
    "SearXNG": {
      "command": "/etc/profiles/per-user/kix/bin/mcp-searxng",
      "args": [],
      "env": {
        "SEARXNG_URL": "http://127.0.0.1:42701"
      }
    }
  }
}
```

> **⚠️ 常见陷阱**：`codewhale mcp add SearXNG --command /path/to/mcp-searxng` 添加后 `env` 默认为 `{}`。
> 缺少 `SEARXNG_URL` 时 MCP 服务器静默失败——`codewhale mcp list` 显示 `[enabled]` 但调用无结果。

## 故障排查

### MCP 服务器无响应

```bash
# 检查 MCP 服务器是否注册且启用
codewhale mcp list

# 检查环境变量是否正确配置
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG 后端连通性

```bash
# 验证 SearXNG API 是否可达
curl -s http://127.0.0.1:42701/config | head -c 100

# 手动测试 MCP 服务器（应显示 MCP 协议握手信息）
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### SearXNG 搜索不工作

- 确认 `settings.search.formats` 包含 `"json"`（MCP Server 需要 JSON API）
- 检查 lighttpd 反向代理是否正确设置 `X-Forwarded-For` 头
- 查看日志：`journalctl -u searx --no-pager -n 30`

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
