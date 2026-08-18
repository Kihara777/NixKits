# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | 日本語  | [偽中国語](../pcn/dsh.md)

DeepSeek Harness（DSH）—— Everything is a Plugin（すべてがプラグイン）。

## 基本情報

| 項目 | 値 |
|------|-----|
| タイプ | Node.js アプリ（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| バージョン | `0.1.0-rc.6` |
| ライセンス | MIT |
| コマンド | `dsh` |

## インストール

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## 使い方

```bash
dsh --help
dsh web   # ブラウザ UI を起動
```

## サービス設定

常駐 web サービスとして実行するには `nixkits.dsh` モジュールを使用。dsh は RCE 安全のため loopback のみ（`127.0.0.1:8615`）をリッスンし、lighttpd リバースプロキシで对外ポート `8625` に公開（ファイアウォール自動開放）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh は非 loopback を拒否
    port = 8615;          # 内部 loopback ポート
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外ポート
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```

## プラグイン宣言的管理

dsh のプラグインは `cordis.patch.yml` からランタイムにホットリロードされる（再起動不要）。`nixkits.dsh.plugins` で宣言的なオン/オフと設定が可能：

```nix
{
  nixkits.dsh.plugins = {
    disabled = [ "session-telemetry-otel" "session-stats" ];  # 無効化
    settings."dsh-web-app" = { printUrl = false; };           # 設定上書き
    extraPatch = "...";  # 生フラグメント（MCP insert リストなど）
  };
}
```

| オプション | 説明 |
|------|------|
| `disabled` | 無効化するプラグイン entry id、`- id: <id> / disabled: true` に描画 |
| `settings` | プラグイン config 上書き（id → JSON、YAML flow style） |
| `extraPatch` | 生 cordis.patch.yml フラグメント（MCP サーバーなど） |
