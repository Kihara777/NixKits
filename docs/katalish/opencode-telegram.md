# opencode-telegram

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross%20%28opencode-telegram%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/opencode-telegram.md)

Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ [OpenCode](https://opencode.ai).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.22.0 |
| Upstream | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## ﾕｰｾｰｼﾞ

```bash
# First-time setup
opencode serve                           # start opencode server
opencode-telegram config                 # interactive Telegram Bot config

# Daily use
opencode-telegram start                  # start (auto-launches opencode)
opencode-telegram status                 # check status
opencode-telegram stop                   # stop
```

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## Flake Module

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
            # Ensure opencode is in the service PATH (pick one):
            # Option A:
            #   extraPackages = [ pkgs.opencode ];
            # Option B — home-manager path:
            extraBinPaths = [ "/etc/profiles/per-user/kix/bin" ];
          };
        }
      ];
    };
  };
}
```

## ｷｬｯｼｭ

`cachix use nixkits`（flake ﾊ `nixConfig` ﾃﾞ 自動宣言、flake input 使用時 ﾆ 自動案内）。
