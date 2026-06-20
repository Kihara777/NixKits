# opencode-telegram

[中文](../../zh/opencode-telegram.md) | [English](../en/opencode-telegram.md) | [日本語](../../ja/opencode-telegram.md) | [ｶﾀﾘｯｼｭ](opencode-telegram.md) | [偽中国語](../../pcn/opencode-telegram.md)

Telegram ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ ﾌｫｱ [OpenCode](https://opencode.ai).

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.21.2 |
| Upstream | [grinev/opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot) |

## ﾕｰｾｰｼﾞ

```bash
# First-time ｾｯﾄｱｯﾌﾟ
opencode serve                           # ｽﾀｰﾄ opencode ｻｰﾊﾞｰ
opencode-telegram ｺﾝﾌｨｸﾞ                 # interactive Telegram ﾎﾞｯﾄ ｺﾝﾌｨｸﾞ

# Daily ﾕｰｽﾞ
opencode-telegram ｽﾀｰﾄ                  # ｽﾀｰﾄ (auto-launches opencode)
opencode-telegram status                 # ﾁｪｯｸ status
opencode-telegram ｽﾄｯﾌﾟ                   # ｽﾄｯﾌﾟ
```

## ｲﾝｽﾄｰﾙ

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.opencode-telegram ];

# ﾃﾞﾌｫﾙﾄ ｵｰﾊﾞｰﾚｲ → pkgs.opencode-telegram
nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
```

## ﾌﾚｲｸ ﾓｼﾞｭｰﾙ

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ
{
  ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾕｰｱｰﾙｴﾙ = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.your-host = nixpkgs.ﾘﾌﾞ.nixosSystem {
      ﾓｼﾞｭｰﾙｽﾞ = [
        nix-kits.nixosModules.opencode-telegram
        {
          services.opencode-telegram = {
            ｲﾈｰﾌﾞﾙ = true;
            ﾕｰｻﾞｰ = "kix";
            group = "ﾕｰｻﾞｰｽﾞ";
            afterServices = [ "network-online.target" "llama-cpp.ｻｰﾋﾞｽ" ];
          };
        }
      ];
    };
  };
}
```