# dsh

[中文](../zh/dsh.md) | [English](../en/dsh.md) | [日本語](../ja/dsh.md)  | 偽中国語

DeepSeek Harness（DSH）—— 万物皆插件（Everything is a Plugin）。

## 基本情報

| 項目 | 値 |
|------|-----|
| 類型 | Node.js 応用（CLI） |
| 上流 | [deepseek-ai/deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) |
| 版本 | `0.1.0-rc.6` |
| 許可 | MIT |
| 命令 | `dsh` |

## 導入

```nix
# /etc/nixos/flake.nix
nixkits.extraPackages = [ nixkits.dsh ];
```

## 使用

```bash
dsh --help
dsh web   # 瀏覧器 UI 起動
```

## 服務設定

常駐 web 服務実行 `nixkits.dsh` module 使用。dsh RCE 安全 loopback のみ（`127.0.0.1:8615`）監聽、lighttpd 反代对外端口 `8625` 公開（防火牆自動開放）：

```nix
{
  nixkits.dsh = {
    enable = true;
    host = "127.0.0.1";   # 固定：dsh 拒否非 loopback
    port = 8615;          # 内部 loopback 端口
    reverseProxy = {
      enable = true;
      port = 8625;        # lighttpd 对外端口
    };
    environment.DEEPSEEK_API_KEY = "sk-...";
  };
}
```
