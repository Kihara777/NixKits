# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](mcp-searxng.md)

[SearXNG](https://docs.searxng.org) 用 [MCP Server](https://modelcontextprotocol.io)。AI アシスタントにウェブ検索機能を提供します。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 1.1.0 |
| アップストリーム | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## インストール

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# デフォルト overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## NixOS 完全設定（SearXNG + lighttpd）

```nix
{ config, ... }:
let
  searxKey = "YOUR_SECRET_KEY";
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
    enableModules = [ "mod_access" "mod_alias" "mod_proxy" "mod_setenv" ];
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

## MCP クライアント設定

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

> SearXNG は JSON 形式を有効にする必要があります（上記 `settings.search.formats` で設定済み）。
