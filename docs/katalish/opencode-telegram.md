# opencode-ﾃﾚｸﾞﾗﾑ

[中文](../../zh/opencode-telegram.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](../katalish/opencode-telegram.md) | [偽中国語](../pcn/opencode-telegram.md)

ﾃﾚｸﾞﾗﾑ ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ ﾌｫｱ [OpenCode](https://opencode.ai).

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.21.2 |
| Upstream | [grinev/opencode-ﾃﾚｸﾞﾗﾑ-bot](https://github.com/grinev/opencode-telegram-bot) |

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
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.opencode-telegram ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.opencode-ﾃﾚｸﾞﾗﾑ
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
```

## Flake ﾓｼﾞｭｰﾙ

```nix
# flake.ﾆｯｸｽ
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