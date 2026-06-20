# ｴﾑｼｰﾋﾟｰ-searxng

[中文](../../zh/mcp-searxng.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | [偽中国語](../pcn/mcp-searxng.md)

[ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ](https://modelcontextprotocol.io) ﾌｫｱ [SearXNG](https://docs.searxng.org) — web ｻｰﾁ ﾌｫｱ AI assistants.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 1.7.1 |
| Upstream | [ihor-sokoliuk/ｴﾑｼｰﾋﾟｰ-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.ｴﾑｼｰﾋﾟｰ-searxng
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

## ｴﾑｼｰﾋﾟｰ ｸﾗｲｱﾝﾄ ｺﾝﾌｨｸﾞ

```json
{
  "mcpServers": {
    "searxng": {
      "ｺﾏﾝﾄﾞ": "ｴﾑｼｰﾋﾟｰ-searxng",
      "env": { "SEARXNG_URL": "http://127.0.0.1:4270" }
    }
  }
}
```

> SearXNG requires JSON format (configured above in `settings.search.formats`).

## CodeWhale ｺﾝﾌｨｸﾞ

CodeWhale stores ｴﾑｼｰﾋﾟｰ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ ｲﾝ `~/.deepseek/mcp.json`. After ｱﾄﾞｲﾝｸﾞ ｴﾑｼｰﾋﾟｰ-searxng, you **ﾏｽﾄ manually set `SEARXNG_URL`** — ｻﾞ `codewhale mcp add` ｺﾏﾝﾄﾞ does ﾉｯﾄ ｵｰﾄ-populate ｻﾞ `env` field.

```json
{
  "ｻｰﾊﾞｰｽﾞ": {
    "SearXNG": {
      "ｺﾏﾝﾄﾞ": "/etc/profiles/per-ﾕｰｻﾞｰ/kix/bin/ｴﾑｼｰﾋﾟｰ-searxng",
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

### ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ unresponsive

```bash
# Check registration and status
codewhale mcp list

# Verify environment variable
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG ﾊﾞｯｸｴﾝﾄﾞ connectivity

```bash
# Verify SearXNG API is reachable
curl -s http://127.0.0.1:42701/config | head -c 100

# Manual MCP server test (should show MCP handshake)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### ｻｰﾁ returns ﾉｰ results

- Ensure `settings.search.formats` includes `"json"` (required ﾊﾞｲ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ)
- Verify lighttpd reverse proxy forwards `X-Forwarded-For` ﾍｯﾀﾞｰ
- Check logs: `journalctl -u searx --no-pager -n 30`