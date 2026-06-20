# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)

[MCP Server](https://modelcontextprotocol.io) ﾌｫｱ [SearXNG](https://docs.searxng.org) — ｳｪﾌﾞ ｻｰﾁ ﾌｫｱ AI assistants.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 1.4.0 |
| Upstream | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## ｲﾝｽﾄｰﾙ

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.mcp-searxng ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.mcp-searxng
nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
```

## Full NixOS ｾｯﾄｱｯﾌﾟ

```nix
{ ｺﾝﾌｨｸﾞ, ... }:
let
  searxKey = "YOUR_SECRET_KEY";
ｲﾝ
{
  services.searx = {
    ｲﾈｰﾌﾞﾙ = true;
    redisCreateLocally = true;
    ｾｯﾃｨﾝｸﾞｽﾞ = {
      ｻｰﾁ.formats = [ "html" "ｼﾞｪｲｿﾝ" ];
      ｻｰﾊﾞｰ = {
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
    ｲﾈｰﾌﾞﾙ = true;
    port = 4270;
    enableModules = [ "mod_access" "mod_alias" "mod_proxy" "mod_setenv" ];
    extraConfig = ''
      proxy.ｻｰﾊﾞｰ = ( "" => (
        ( "host" => "127.0.0.1", "port" => 42701 )
      ))
      setenv.add-request-header = (
        "X-Real-IP"       => "%{remote-addr}e",
        "X-Forwarded-For"  => "%{remote-addr}e",
        "X-Forwarded-Proto" => "ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ"
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
      "ｺﾏﾝﾄﾞ": "mcp-searxng",
      "ｴﾇﾌﾞｲ": { "SEARXNG_URL": "http://127.0.0.1:4270" }
    }
  }
}
```

> SearXNG ﾘｸﾜｲｱｽﾞ ｼﾞｪｲｿﾝ ﾌｫｰﾏｯﾄ (configured above ｲﾝ `settings.search.formats`).

## CodeWhale ｺﾝﾌｨｸﾞ

CodeWhale stores ｴﾑｼｰﾋﾟｰ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ ｲﾝ `~/.deepseek/mcp.json`. ｱﾌﾀｰ adding mcp-searxng, you **ﾏｽﾄ manually set `SEARXNG_URL`** — ｻﾞ `codewhale mcp add` ｺﾏﾝﾄﾞ does ﾉｯﾄ auto-populate ｻﾞ `env` field.

```json
{
  "servers": {
    "SearXNG": {
      "ｺﾏﾝﾄﾞ": "/etc/profiles/per-user/kix/ﾋﾞﾝ/mcp-searxng",
      "ｱｰｸﾞｽﾞ": [],
      "ｴﾇﾌﾞｲ": {
        "SEARXNG_URL": "http://127.0.0.1:42701"
      }
    }
  }
}
```

> **⚠️ Common pitfall**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` leaves `env` ｱｽﾞ `{}`.
> Without `SEARXNG_URL` ｻﾞ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ fails silently — `codewhale mcp list` shows `[enabled]` but calls return ﾉｰ results.

## Troubleshooting

### ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ unresponsive

```bash
# ﾁｪｯｸ registration ｱﾝﾄﾞ status
codewhale ｴﾑｼｰﾋﾟｰ ﾘｽﾄ

# Verify ｴﾝﾊﾞｲﾛﾒﾝﾄ variable
cat ~/.deepseek/ｴﾑｼｰﾋﾟｰ.ｼﾞｪｲｿﾝ | grep -A3 SEARXNG_URL
```

### SearXNG ﾊﾞｯｸｴﾝﾄﾞ connectivity

```bash
# Verify SearXNG ｴｰﾋﾟｰｱｲ ｲｽﾞ reachable
curl -s http://127.0.0.1:42701/config | head -c 100

# Manual ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ﾃｽﾄ (ｼｭｯﾄﾞ show ｴﾑｼｰﾋﾟｰ handshake)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### ｻｰﾁ returns ﾉｰ results

- Ensure `settings.search.formats` ｲﾝｸﾙｰﾄﾞｽﾞ `"json"` (required ﾊﾞｲ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ)
- Verify lighttpd reverse proxy forwards `X-Forwarded-For` ﾍｯﾀﾞｰ
- ﾁｪｯｸ logs: `journalctl -u searx --no-pager -n 30`