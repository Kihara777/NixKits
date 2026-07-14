# opencode-telegram

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross%20%28opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | [偽中国語](../pcn/opencode-telegram.md)

[OpenCode](https://opencode.ai) 的 Telegram Bot 客户端。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 0.22.2 |
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
            # 确保 opencode 在服务 PATH 中（二选一）
            # 方案 A — 系统级包：
            #   extraPackages = [ pkgs.opencode ];
            # 方案 B — home-manager 路径：
            extraBinPaths = [ "/etc/profiles/per-user/kix/bin" ];
          };
        }
      ];
    };
  };
}
```

## 缓存

`cachix use nixkits`（flake 已通过 `nixConfig` 自动声明，直接使用 flake input 时自动提示）。
