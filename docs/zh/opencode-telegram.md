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
opencode-telegram start           # 交互式配置
opencode-telegram start --daemon  # 后台运行
opencode-telegram status          # 查看状态
opencode-telegram stop            # 停止
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
