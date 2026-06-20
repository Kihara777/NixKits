# mcp-searxng

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [mcp-searxng] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [mcp-searxng] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [mcp-searxng] . md )

[ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ ]( https [://] [modelcontextprotocol] . io ) ﾌｫｱ [ SearXNG ]( https [://] ﾄﾞｷｭｽﾞ . [searxng] . [org] ) — [web] ｻｰﾁ ﾌｫｱ AI [assistants] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|1 . 4 . 0
Upstream|[ ihor - sokoliuk / ｴﾑｼｰﾋﾟｰ - searxng ] ( https : / / github . com / ihor - sokoliuk / ｴﾑｼｰﾋﾟｰ - searxng )

## Install

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. [mcp-searxng] ];

# Default overlay → pkgs.mcp-searxng
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
```

## Full NixOS Setup

```nix
{ ｺﾝﾌｨｸﾞ , ... }:
[let]
[searxKey] = " [YOUR_SECRET_KEY] ";
ｲﾝ
{
[services] . [searx] = {
[enable] = [true] ;
[redisCreateLocally] = [true] ;
ｾｯﾃｨﾝｸﾞｽﾞ = {
ｻｰﾁ . [formats] = [ " [html] " " ｼﾞｪｲｿﾝ " ];
ｻｰﾊﾞｰ = {
[bind_address] = " 127 . 0 . 0 . 1 ";
[port] = " 42701 ";
[secret_key] = [searxKey] ;
[limiterSettings] = {
[botdetection] . [trusted_proxies] = [ " 127 . 0 . 0 . 1 / 32 " ];
[real_ip] . [x_for] = 1 ;
};
};
};
};

[services] . [lighttpd] = {
[enable] = [true] ;
[port] = 4270 ;
[enableModules] = [ " [mod_access] " " [mod_alias] " " [mod_proxy] " " [mod_setenv] " ];
[extraConfig] = ''
[proxy] . ｻｰﾊﾞｰ = ( "" => (
( " [host] " => " 127 . 0 . 0 . 1 ", " [port] " => 42701 )
))
[setenv] . [add-request-header] = (
" [X-Real-IP] " => ["%{] [remote-addr] } e ",
" [X-Forwarded-For] " => ["%{] [remote-addr] } e ",
" [X-Forwarded-Proto] " => " ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ "
)
'' ;
};
}
```

## MCP Client Config

```json
{
" [mcpServers] ": {
" [searxng] ": {
" ｺﾏﾝﾄﾞ ": " [mcp-searxng] ",
" ｴﾇﾌﾞｲ ": { " [SEARXNG_URL] ": " ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ [://] 127 . 0 . 0 . 1 : 4270 " }
}
}
}
```

> SearXNG [requires] ｼﾞｪｲｿﾝ ﾌｫｰﾏｯﾄ ( [configured] ｱﾊﾞﾌﾞ ｲﾝ ` ｾｯﾃｨﾝｸﾞｽﾞ . ｻｰﾁ . [formats] `).

## CodeWhale Config

CodeWhale [stores] ｴﾑｼｰﾋﾟｰ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ ｲﾝ `~/. [deepseek] / ｴﾑｼｰﾋﾟｰ . ｼﾞｪｲｿﾝ `. ｱﾌﾀｰ [adding] [mcp-searxng] , [you] ** ﾏｽﾄ [manually] [set] ` [SEARXNG_URL] `** — ｻﾞ ` [codewhale] ｴﾑｼｰﾋﾟｰ ｱﾄﾞ ` ｺﾏﾝﾄﾞ [does] ﾉｯﾄ [auto-populate] ｻﾞ ` ｴﾇﾌﾞｲ ` [field] .

```json
{
" [servers] ": {
" SearXNG ": {
" ｺﾏﾝﾄﾞ ": "/ [etc] / [profiles] / [per-user] / [kix] / ﾋﾞﾝ / [mcp-searxng] ",
" ｱｰｸﾞｽﾞ ": [],
" ｴﾇﾌﾞｲ ": {
" [SEARXNG_URL] ": " ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ [://] 127 . 0 . 0 . 1 : 42701 "
}
}
}
}
```

> [**⚠️] [Common] [pitfall] [**:] ` [codewhale] ｴﾑｼｰﾋﾟｰ ｱﾄﾞ SearXNG [--command] / ﾊﾟｽ / ﾄｩ / [mcp-searxng] ` [leaves] ` ｴﾇﾌﾞｲ ` ｱｽﾞ `{}`.
> [Without] ` [SEARXNG_URL] ` ｻﾞ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ [fails] [silently] — ` [codewhale] ｴﾑｼｰﾋﾟｰ ﾘｽﾄ ` [shows] `[ [enabled] ]` [but] [calls] [return] ﾉｰ [results] .

## Troubleshooting

### MCP server unresponsive

```bash
# Check registration and status
[codewhale] ｴﾑｼｰﾋﾟｰ ﾘｽﾄ

# Verify environment variable
[cat] [~/.] [deepseek] / ｴﾑｼｰﾋﾟｰ . ｼﾞｪｲｿﾝ | [grep] [-A3] [SEARXNG_URL]
```

### SearXNG backend connectivity

```bash
# Verify SearXNG API is reachable
[curl] -s ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ [://] 127 . 0 . 0 . 1 : 42701 / ｺﾝﾌｨｸﾞ | ﾍｯﾄﾞ -c 100

# Manual MCP server test (should show MCP handshake)
[SEARXNG_URL] =" ｴｲﾁﾃｨｰﾃｨｰﾋﾟｰ [://] 127 . 0 . 0 . 1 : 42701 " [timeout] 3 [mcp-searxng]
```

### Search returns no results

- [Ensure] ` ｾｯﾃｨﾝｸﾞｽﾞ . ｻｰﾁ . [formats] ` [includes] `" ｼﾞｪｲｿﾝ "` ( [required] ﾊﾞｲ ｴﾑｼｰﾋﾟｰ ｻｰﾊﾞｰ )
- [Verify] [lighttpd] [reverse] [proxy] [forwards] ` [X-Forwarded-For] ` ﾍｯﾀﾞｰ
- ﾁｪｯｸ [logs] : ` [journalctl] -u [searx] [--no-pager] -n 30 `