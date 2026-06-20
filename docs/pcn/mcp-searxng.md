# mcp-searxng

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md) | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | 偽中国語

[SearXNG](https://docs.searxng.org) 用 [MCP Server](https://modelcontextprotocol.io)。AI アシスタントウェブ検索機能提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 1.7.1 |
| アップストリーム | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## インストール

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.mcp-searxng ];

# デフォルト overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## NixOS 完全設定(SearXNG + lighttpd)

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

> SearXNG  JSON 形式有効必要(上記 `settings.search.formats` 設定済)。

## CodeWhale 設定

CodeWhale  MCP 設定ファイル `~/.deepseek/mcp.json` 。mcp-searxng 追加後，**必手動 `SEARXNG_URL` 設定** — `codewhale mcp add` コマンド `env` フィールド自動入力。

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

> **⚠️ 落穴**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` 実行 `env`  `{}` 。
> `SEARXNG_URL` 場合，MCP サーバーサイレント失敗 — `codewhale mcp list`  `[enabled]` 表示，呼出結果返。

## トラブルシューティング

### MCP サーバー応答

```bash
# 登録ステータス確認
codewhale mcp list

# 環境変数設定確認
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG バックエンド接続

```bash
# SearXNG API 到達可能確認
curl -s http://127.0.0.1:42701/config | head -c 100

# 手動 MCP サーバーテスト(MCP ハンドシェイク表示)
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### 検索結果返

- `settings.search.formats`  `"json"` 含確認(MCP Server 要件)
- lighttpd リバースプロキシ `X-Forwarded-For` ヘッダー転送確認
- ログ確認: `journalctl -u searx --no-pager -n 30`
