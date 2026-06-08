# mcp-searxng

[中文](mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)

[SearXNG](https://docs.searxng.org) 的 [MCP Server](https://modelcontextprotocol.io)，为 AI 助手提供网页搜索能力。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 1.2.1 |
| 上游 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## 引用

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
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
