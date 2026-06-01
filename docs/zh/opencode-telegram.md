# opencode-telegram

[中文](opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md)

[OpenCode](https://opencode.ai) 的 Telegram Bot 客户端。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.21.0 |
| 上游 | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## 使用

```bash
# 首次配置
opencode serve                           # 启动 opencode 服务端
opencode-telegram config                 # 交互式配置 Telegram Bot

# 日常使用
opencode-telegram start                  # 启动（自动拉起 opencode）
opencode-telegram status                 # 查看状态
opencode-telegram stop                   # 停止
```

## 引用

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## flake 模块

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
