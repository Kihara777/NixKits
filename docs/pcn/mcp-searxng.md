# mcp-searxng

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml) [![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | 偽中国語

[SearXNG](https://docs.searxng.org) 用 [MCP Server](https://modelcontextprotocol.io)。AI 検索功能提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | 1.7.1 |
| 上游 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## 安裝

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.mcp-searxng ];

# デフォルト overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## NixOS 完全設置(SearXNG + lighttpd)

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

## MCP 客户端設置

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

> SearXNG JSON 形式有効必要(上記 `settings.search.formats` 設置済)。

## CodeWhale 設置

CodeWhale MCP 設置ァ `~/.deepseek/mcp.json` 。mcp-searxng 追加後，**必手動 `SEARXNG_URL` 設置** — `codewhale mcp add` `env` 自動入力。

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

> **⚠️ 落穴**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` 実行 `env` `{}` 。
> `SEARXNG_URL` 場合，MCP 服務器失敗 — `codewhale mcp list` `[enabled]` 表示，呼出結果返。

## 

### MCP 服務器応答

```bash
# 登録とステータスを確認
codewhale mcp list

# 環境変数の設定を確認
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG 接続

```bash
# SearXNG API が到達可能か確認
curl -s http://127.0.0.1:42701/config | head -c 100

# 手動 MCP サーバーテスト（MCP ハンドシェイクが表示されるはず）
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### 検索結果返

- `settings.search.formats` `"json"` 含確認(MCP Server 要件)
- lighttpd `X-Forwarded-For` 転送確認
- 確認: `journalctl -u searx --no-pager -n 30`

## 緩存

`cachix use nixkits`（flake 已自 `nixConfig` 自動宣言、直以 flake input 使用時自動提示）。
