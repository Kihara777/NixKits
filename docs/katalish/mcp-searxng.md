# mcp-searxng

[中文](../zh/mcp-searxng.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | [偽中国語](../pcn/mcp-searxng.md)

[MCP Server](https://modelcontextprotocol.io) ﾌｫｱ [SearXNG](https://docs.searxng.org) — web search ﾌｫｱ AI ｱｽｽｲｽﾄｱﾝﾄs.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| Version | 1.7.1 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# Default overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Full NixOS Setup

```nix
{ ｺﾝﾌｨｸﾞ, ... }:
let
  searxKey = "YOUR_SECRET_KEY";
ｲﾝ
{
  services.searx = {
    enable = true;
    redisCreateLocally = true;
    ｾｯﾃｨﾝｸﾞｽﾞ = {
      search.formats = [ "html" "json" ];
      server = {
        bind_address = "127.0.0.1";
        ﾎﾟｰﾄ = "42701";
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
    ﾎﾟｰﾄ = 4270;
    enableModules = [ "mod_access" "mod_alias" "mod_proxy" "mod_setenv" ];
    extraConfig = ''
      proxy.server = ( "" => (
        ( "host" => "127.0.0.1", "ﾎﾟｰﾄ" => 42701 )
      ))
      setenv.ｱﾄﾞ-request-header = (
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

> SearXNG requires JSON format (configured ｱﾊﾞﾌﾞ ｲﾝ `ｾｯﾃｨﾝｸﾞｽﾞ.search.formats`).

## CodeWhale Config

CodeWhale stores MCP ｺﾝﾌｨｷﾞｭﾗｴｰｼｮﾝ ｲﾝ `~/.deepseek/mcp.json`. After adding mcp-searxng, you **ﾑｽﾄ manually ｾｯﾄ `SEARXNG_URL`** — ｻﾞ `codewhale mcp ｱﾄﾞ` command ﾀﾞｽﾞ ﾉｯﾄ ｵｰﾄ-populate ｻﾞ `env` ﾌｨｰﾙﾄﾞ.

```json
{
  "servers": {
    "SearXNG": {
      "command": "/etc/profiles/ﾊﾟｰ-ﾕｰｻﾞｰ/kix/bin/mcp-searxng",
      "args": [],
      "env": {
        "SEARXNG_URL": "http://127.0.0.1:42701"
      }
    }
  }
}
```

> **⚠️ Common pitfall**: `codewhale mcp ｱﾄﾞ SearXNG --command /ﾊﾟｽ/ﾄｩ/mcp-searxng` leaves `env` ｱｽﾞ `{}`.
> Without `SEARXNG_URL` ｻﾞ MCP ｻｰﾊﾞｰ fails silently — `codewhale mcp ﾘｽﾄ` shows `[enabled]` ﾌﾞｯﾄ calls return ﾉｰ results.

## Troubleshooting

### MCP ｻｰﾊﾞｰ unresponsive

```bash
# Check registration ｱﾝﾄﾞ status
codewhale mcp ﾘｽﾄ

# Verify environment variable
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG backend connectivity

```bash
# Verify SearXNG API ｲｽﾞ reachable
curl -s http://127.0.0.1:42701/ｺﾝﾌｨｸﾞ | head -c 100

# Manual MCP server test (should show MCP handshake)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### Search returns ﾉｰ results

- Ensure `ｾｯﾃｨﾝｸﾞｽﾞ.search.formats` includes `"json"` (required ﾊﾞｲ MCP Server)
- Verify lighttpd reverse proxy forwards `X-Forwarded-For` header
- Check logs: `journalctl -u searx --ﾉｰ-pager -n 30`
