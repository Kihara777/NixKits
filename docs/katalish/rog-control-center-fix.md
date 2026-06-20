# rog-control-center-fix

[中文](../../zh/rog-control-center-fix.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-fix.md) | [偽中国語](../pcn/rog-control-center-fix.md)

Fixes ｱ systemd deadlock during shutdown ｲﾝ `asus-shutdown.service`.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | Tracks nixpkgs |
| ﾀｲﾌﾟ | NixOS ﾓｼﾞｭｰﾙ |
| ﾊﾟｽ | `modules/rog-control-center-fix.nix` |
| ﾄﾘｶﾞｰ | `services.asusd.enable = true` |

## Fixes

- **ﾘﾑｰﾌﾞ PartOf**: Clears `PartOf` ｵﾝ `asus-shutdown.service` ﾄｩ prevent cascading ｽﾄｯﾌﾟ deadlock when asusd restarts

## ｲﾝｽﾄｰﾙ

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```