# opencode-telegram

中文 | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | [偽中国語](../pcn/opencode-telegram.md)

[OpenCode](https://opencode.ai) 的 Telegram Bot 客户端。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.21.2 |
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
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## flake 模块

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

## 缓存

可通过 NixKits 二进制缓存获取，避免本地编译：

```bash
cachix use nixkits
```

或 NixOS 配置添加：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
