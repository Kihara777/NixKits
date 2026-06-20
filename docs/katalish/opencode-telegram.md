# opencode-telegram

[中文](../zh/opencode-telegram.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | [偽中国語](../pcn/opencode-telegram.md)

Telegram Bot ｸﾗｲｱﾝﾄ ﾌｫｱ [OpenCode](https://opencode.ai).

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.21.2 |
| Upstream | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## ﾕｰｾｰｼﾞ

```bash
# First-time ｾｯﾄｱｯﾌﾟ
opencode serve                           # start opencode server
opencode-telegram ｺﾝﾌｨｸﾞ                 # interactive Telegram Bot ｺﾝﾌｨｸﾞ

# Daily ﾕｰｽﾞ
opencode-telegram start                  # start (ｵｰﾄ-launches opencode)
opencode-telegram status                 # check status
opencode-telegram stop                   # stop
```

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# Default overlay → pkgs.opencode-telegram
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Flake Module

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
            ﾕｰｻﾞｰ = "kix";
            ｸﾞﾙｰﾌﾟ = "users";
            afterServices = [ "network-online.target" "llama-cpp.service" ];
          };
        }
      ];
    };
  };
}
```
