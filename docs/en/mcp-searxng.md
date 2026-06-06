# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)

[MCP Server](https://modelcontextprotocol.io) for [SearXNG](https://docs.searxng.org) — web search for AI assistants.

## Info

| Item | Value |
|------|-------|
| Version | 1.1.0 |
| Upstream | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## Install

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Full NixOS Setup

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

## MCP Client Config

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

> SearXNG requires JSON format (configured above in `settings.search.formats`).
