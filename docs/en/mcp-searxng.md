# mcp-searxng

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-x86_64.yml?branch=main&label=x86_64%20v2.0.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-aarch64.yml?branch=main&label=aarch64%20v2.0.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-riscv64.yml?branch=main&label=riscv64%20v2.0.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/mcp-searxng.md) | English | [日本語](../ja/mcp-searxng.md)  | [偽中国語](../pcn/mcp-searxng.md)

[MCP Server](https://modelcontextprotocol.io) for [SearXNG](https://docs.searxng.org) — web search for AI assistants.

## Info

| Item | Value |
|------|-------|
| Version | 2.0.0 |
| Upstream | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## Install

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
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

## CodeWhale Config

CodeWhale stores MCP configuration in `~/.deepseek/mcp.json`. After adding mcp-searxng, you **must manually set `SEARXNG_URL`** — the `codewhale mcp add` command does not auto-populate the `env` field.

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

> **⚠️ Common pitfall**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` leaves `env` as `{}`.
> Without `SEARXNG_URL` the MCP server fails silently — `codewhale mcp list` shows `[enabled]` but calls return no results.

## Troubleshooting

### MCP server unresponsive

```bash
# Check registration and status
codewhale mcp list

# Verify environment variable
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG backend connectivity

```bash
# Verify SearXNG API is reachable
curl -s http://127.0.0.1:42701/config | head -c 100

# Manual MCP server test (should show MCP handshake)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### Search returns no results

- Ensure `settings.search.formats` includes `"json"` (required by MCP Server)
- Verify lighttpd reverse proxy forwards `X-Forwarded-For` header
- Check logs: `journalctl -u searx --no-pager -n 30`

## Cache

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).
