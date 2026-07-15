# opencode-telegram

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-opencode-telegram-x86_64.yml?branch=main&label=x86_64%20v0.22.2)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-opencode-telegram-aarch64.yml?branch=main&label=aarch64%20v0.22.2)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-opencode-telegram-riscv64.yml?branch=main&label=riscv64%20v0.22.2)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../ja/opencode-telegram.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/opencode-telegram.md)

Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ [OpenCode](https://opencode.ai).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.22.2 |
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

`cachix use nixkits` (declared automatically via `nixConfig` in ｻﾞ flake; prompted on first use).
