# opencode-telegram

[中文](../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](opencode-telegram.md)

[OpenCode](https://opencode.ai) の Telegram Bot クライアント。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | 0.21.1 |
| アップストリーム | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## 使い方

```bash
# 初回セットアップ
opencode serve                           # opencode サーバーを起動
opencode-telegram config                 # 対話型 Telegram Bot 設定

# 日常使用
opencode-telegram start                  # 起動（opencode を自動起動）
opencode-telegram status                 # 状態確認
opencode-telegram stop                   # 停止
```

## インストール

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# デフォルト overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Flake モジュール

```nix
# flake.nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      modules = [
        nix-kits.nixosModules.opencode-telegram
        {
          services.opencode-telegram = {
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
