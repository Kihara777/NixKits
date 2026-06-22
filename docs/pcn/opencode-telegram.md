# opencode-telegram

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | 偽中国語

[OpenCode](https://opencode.ai) 之 Telegram Bot 依頼者。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | 0.21.2 |
| 上流 | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## 使方

```bash
# 初回セットアップ
opencode serve                           # opencode サーバーを起動
opencode-telegram config                 # 対話型 Telegram Bot 設定

# 日常使用
opencode-telegram start                  # 起動（opencode を自動起動）
opencode-telegram status                 # 状態確認
opencode-telegram stop                   # 停止
```

## 導入

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.opencode-telegram ];

# デフォルト overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## Flake 部品

```nix
# flake.nix
{
  inputs.nixkits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nixkits, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nixkits.nixosModules.opencode-telegram
        {
          nixkits.opencode-telegram = {
            enable = true;
            user = "kix";
            group = "users";
            afterServices = [ "network-online.target" "llama-cpp.service" ];
          };
        }
      ];
    };
  };
}
```

## 緩衝

`cachix use nixkits`（flake `nixConfig` 自動宣言、flake input 使用時自動案内）。
