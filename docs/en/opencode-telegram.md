# opencode-telegram

[中文](../zh/opencode-telegram.md) | English | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | [偽中国語](../pcn/opencode-telegram.md)

Telegram Bot client for [OpenCode](https://opencode.ai).

## Info

| Item | Value |
|------|-------|
| Version | 0.21.2 |
| Upstream | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## Usage

```bash
# First-time setup
opencode serve                           # start opencode server
opencode-telegram config                 # interactive Telegram Bot config

# Daily use
opencode-telegram start                  # start (auto-launches opencode)
opencode-telegram status                 # check status
opencode-telegram stop                   # stop
```

## Install

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
          };
        }
      ];
    };
  };
}
```
