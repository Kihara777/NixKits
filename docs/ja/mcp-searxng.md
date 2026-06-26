# mcp-searxng

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20mcp-searxng%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | 日本語 | [ｶﾀﾘｯｼｭ](../katalish/mcp-searxng.md) | [偽中国語](../pcn/mcp-searxng.md)

[SearXNG](https://docs.searxng.org) 用 [MCP Server](https://modelcontextprotocol.io)。AI アシスタントにウェブ検索機能を提供します。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 1.8.0 |
| アップストリーム | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## インストール

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.mcp-searxng ];

# デフォルト overlay → pkgs.mcp-searxng
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
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

## CodeWhale 設定

CodeWhale の MCP 設定ファイルは `~/.deepseek/mcp.json` にあります。mcp-searxng を追加した後、**必ず手動で `SEARXNG_URL` を設定してください** — `codewhale mcp add` コマンドは `env` フィールドを自動入力しません。

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

> **⚠️ よくある落とし穴**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` を実行すると `env` は `{}` のままです。
> `SEARXNG_URL` がない場合、MCP サーバーはサイレントに失敗します — `codewhale mcp list` には `[enabled]` と表示されますが、呼び出しても結果が返りません。

## トラブルシューティング

### MCP サーバーが応答しない

```bash
# 登録とステータスを確認
codewhale mcp list

# 環境変数の設定を確認
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG バックエンド接続

```bash
# SearXNG API が到達可能か確認
curl -s http://127.0.0.1:42701/config | head -c 100

# 手動 MCP サーバーテスト（MCP ハンドシェイクが表示されるはず）
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### 検索結果が返らない

- `settings.search.formats` に `"json"` が含まれているか確認（MCP Server の要件）
- lighttpd リバースプロキシが `X-Forwarded-For` ヘッダーを転送しているか確認
- ログを確認: `journalctl -u searx --no-pager -n 30`

## キャッシュ

`cachix use nixkits`（flake は `nixConfig` で自動宣言、flake input として使用時に自動案内）。
