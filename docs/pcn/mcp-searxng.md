# mcp-searxng

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-x86_64.yml?branch=main&label=x86_64%20v2.1.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-aarch64.yml?branch=main&label=aarch64%20v2.1.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-mcp-searxng-riscv64.yml?branch=main&label=riscv64%20v2.1.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/mcp-searxng.md) | [English](../en/mcp-searxng.md) | [日本語](../ja/mcp-searxng.md)  | 偽中国語

[SearXNG](https://docs.searxng.org) 用 [MCP Server](https://modelcontextprotocol.io)。AI 代理網検索機能提供。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 2.1.0 |
| 上流 | [ihor-sokoliuk/MCP-searxng](https://github.com/ihor-sokoliuk/MCP-searxng) |

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.mcp-searxng ];

# 既定上乗 → pkgs.mcp-searxng
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

## MCP 依頼者設定

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

> SearXNG JSON 形式有効必要（上記 `settings.search.formats` 以設定済）。

## CodeWhale 設定

CodeWhale MCP 設定書類 `~/.deepseek/mcp.json` 所在。mcp-searxng 追加後、**必手動 `SEARXNG_URL` 設定** — `codewhale mcp add` 指令 `env` 欄自動入力非。

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

> **⚠️ 多発落穴**: `codewhale mcp add SearXNG --command /path/to/mcp-searxng` 実行時 `env` `{}` 侭。
> `SEARXNG_URL` 無場合、MCP 伺服器黙失敗 — `codewhale mcp list` `[enabled]` 表示、呼出結果不返。

## 障害対処

### MCP 伺服器無応答

```bash
# 登録及状態確認
codewhale mcp list

# 環境変数設定確認
cat ~/.deepseek/mcp.json | grep -A3 SEARXNG_URL
```

### SearXNG 後端接続

```bash
# SearXNG API 到達可能確認
curl -s http://127.0.0.1:42701/config | head -c 100

# 手動 MCP 伺服器試験（MCP 握手表示）
SEARXNG_URL="http://127.0.0.1:42701" timeout 3 mcp-searxng
```

### 検索結果不返

- `settings.search.formats` `"json"` 包含確認（MCP Server 要件）
- lighttpd 逆代理 `X-Forwarded-For` 頭転送確認
- 記録確認: `journalctl -u searx --no-pager -n 30`

## 緩衝

`cachix use nixkits`（flake `nixConfig` 以自動宣言、flake input 使用時自動案内）。
