# ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ

[中文](../../zh/mcp-searxng.md) | [ｲﾝｸﾞﾘｯｼｭ](mcp-searxng.md) | [日本語](../../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../../katalish/mcp-searxng.md) | [偽中国語](../../pcn/mcp-searxng.md)

[ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ](https://modelcontextprotocol.io) ﾌｫｱ [SearXNG](https://docs.searxng.org) — ｳｪﾌﾞ ｻｰﾁ ﾌｫｱ ｱｲ ｱｽｽｲｽﾄｱﾝﾄｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 1.7.1 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ｲﾎｵﾗ-ｽｵｸｵﾙｲｳｸ/ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ](https://github.com/ihor-sokoliuk/MCP-searxng) |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → ﾌﾟｸｸﾞｽﾞ.ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## ﾌﾙ NixOS ｾｯﾄｱｯﾌﾟ

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
  "ﾑｸﾌﾟｽｴﾗﾌﾞｴﾗｽﾞ": {
    "ｻｰｸｽ": {
      "ｸｵﾑﾑｱﾝﾄﾞ": "ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ",
      "ｴﾇﾌﾞｲ": { "ｻｰｸｽ_URL": "http://127.0.0.1:4270" }
    }
  }
}
```

> SearXNG ﾘｸﾜｲｱｽﾞ ｼﾞｪｲｿﾝ ﾌｵﾗﾑｱﾄ (ｸｵﾝﾌｲｸﾞｳﾗﾄﾞ ｱﾊﾞﾌﾞ ｲﾝ `settings.search.formats`).

## CodeWhale ｺﾝﾌｨｸﾞ

CodeWhale ｽﾄｵﾗｽﾞ ｴﾑｼｰﾋﾟｰ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ ｲﾝ `~/.deepseek/mcp.json`. ｱﾌﾀｰ ｱﾄﾞﾄﾞｲﾝｸﾞ ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ, ｲｵｳ **ﾏｽﾄ ﾑｱﾝｳｱﾙﾘｰ ｾｯﾄ `SEARXNG_URL`** — ｻﾞ `codewhale mcp add` ｸｵﾑﾑｱﾝﾄﾞ ﾄﾞｵｽﾞ ﾉｯﾄ ｵｰﾄ-ﾌﾟｵﾌﾟｳﾙｱﾄｴ ｻﾞ `env` ﾌｨｰﾙﾄﾞ.

```json
{
  "ｽｴﾗﾌﾞｴﾗｽﾞ": {
    "SearXNG": {
      "ｸｵﾑﾑｱﾝﾄﾞ": "/ｴﾄｸ/ﾌﾟﾗｵﾌｲﾙｽﾞ/ﾌﾟｴﾗ-ﾕｰｻﾞｰ/ｸｲｸｽ/bin/ｴﾑｼｰﾋﾟｰ-ｻｰｸｽ",
      "ｱﾗｸﾞｽﾞ": [],
      "ｴﾇﾌﾞｲ": {
        "ｻｰｸｽ_URL": "http://127.0.0.1:42701"
      }
    }
  }
}
```

> **⚠️ ｸｵﾑﾑｵﾝ ﾌﾟｲﾄﾌｱﾙﾙ**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` ﾙｴｱﾌﾞｽﾞ `env` ｱｽﾞ `{}`.
> ｳｨｽﾞｱｳﾄ `SEARXNG_URL` ｻﾞ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ﾌｱｲﾙｽﾞ ｽｲﾙｴﾝﾄﾘｰ — `codewhale mcp list` ｼｵｳｽﾞ `[enabled]` ﾌﾞｳﾄ ｸｱﾙﾙｽﾞ ﾗｴﾄｳﾗﾝ ﾉｰ ﾗｴｽｳﾙﾄｽﾞ.

## ﾄﾗｵｳﾌﾞﾙｴｼｵｵﾄｲﾝｸﾞ

### ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ｳﾝﾗｴｽﾌﾟｵﾝｽｲﾌﾞｴ

```bash
# Check registration and status
codewhale mcp list

# Verify environment variable
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG ﾊﾞｯｸｴﾝﾄﾞ ｸｵﾝﾝｴｸﾄｲﾌﾞｲﾄｲ

```bash
# Verify SearXNG API is reachable
curl -s http://127.0.0.1:42701/config | head -c 100

# Manual MCP server test (should show MCP handshake)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### ｻｰﾁ ﾗｴﾄｳﾗﾝｽﾞ ﾉｰ ﾗｴｽｳﾙﾄｽﾞ

- ｴﾝｽｳﾗｴ `settings.search.formats` ｲﾝｸﾙｰﾄﾞｽﾞ `"json"` (ﾗｴｸｲﾗﾄﾞ ﾊﾞｲ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ)
- ﾍﾞﾘﾌｧｲ ﾙｲｶﾞﾄﾄﾌﾟﾄﾞ ﾗｴﾌﾞｴﾗｽｴ ﾌﾟﾗｵｸｽｲ ﾌｵﾗｳｱﾗﾄﾞｽﾞ `X-Forwarded-For` ﾍｯﾀﾞｰ
- ﾁｪｯｸ ﾛｸﾞｽﾞ: `journalctl -u searx --no-pager -n 30`