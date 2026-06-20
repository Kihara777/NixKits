# rog-control-center-fix

[中文](../../zh/rog-control-center-fix.md) | [English](rog-control-center-fix.md) | [日本語](../../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../../katalish/rog-control-center-fix.md)

ﾌｨｯｸｼｰｽﾞ ｱ systemd deadlock during shutdown ｲﾝ `asus-shutdown.service`.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | Tracks nixpkgs |
| ﾀｲﾌﾟ | NixOS ﾓｼﾞｭｰﾙ |
| ﾊﾟｽ | `modules/rog-control-center-fix.nix` |
| ﾄﾘｶﾞｰ | `services.asusd.enable = true` |

## ﾌｨｯｸｼｰｽﾞ

- **ﾘﾑｰﾌﾞ PartOf**: Clears `PartOf` ｵﾝ `asus-shutdown.service` ﾄｩ prevent cascading ｽﾄｯﾌﾟ deadlock ｳｪﾝ asusd restarts

## ｲﾝｽﾄｰﾙ

```nix
{
  imports = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.ｲﾈｰﾌﾞﾙ = true;
}
```