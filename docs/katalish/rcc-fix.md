# rcc-fix

[中文](../../zh/rcc-fix.md) | [English](rcc-fix.md) | [日本語](../../ja/rcc-fix.md) | [ｶﾀﾘｯｼｭ](../../katalish/rcc-fix.md)

ﾊﾟｯﾁｰｽﾞ `asusctl` ﾌｫｱ better ASUS ROG Control Center ｵﾝ 2-in-1 detachable devices.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | ﾌｫﾛｰｽﾞ nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| ﾊﾟｯﾁ | ﾃﾞｨｽ repo `patches/rog-control-center-fix.patch` |
| ﾓｼﾞｭｰﾙ | `nixosModules.rog-control-center-fix` (systemd deadlock ﾌｨｯｸｽ) |
| ﾉｰﾄ | ｵｰﾊﾞｰﾚｲ replaces `pkgs.asusctl`, ﾉｰ standalone ﾊﾟｯｹｰｼﾞ |

## ﾌｨｯｸｼｰｽﾞ

- **Keyboard detection**: Shows multi-language ｵｰﾊﾞｰﾚｲ ｳｪﾝ keyboard disconnected, avoids crash
- **Hot-plug recovery**: D-Bus event-driven — auto-restores Aura UI ｵﾝ reconnect
- **Boundary checks**: PowerZone index guards ﾌｫｱ firmware-reported invalid zones
- **systemd deadlock ﾌｨｯｸｽ**: Removes `PartOf` ﾌﾛﾑ `asus-shutdown.service` ﾄｩ prevent cascading ｽﾄｯﾌﾟ deadlock

## ｲﾝｽﾄｰﾙ

ｵｰﾊﾞｰﾚｲ (ｺｰﾄﾞ ﾊﾟｯﾁ) + NixOS ﾓｼﾞｭｰﾙ (systemd ﾌｨｯｸｽ), recommended together:

```nix
{
  nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.rcc-fix ];

  imports = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusctl = {
    ｲﾈｰﾌﾞﾙ = true;
    power-profile = true;
    cpu-power-control = true;
  };

  programs.rog-control-center = {
    ｲﾈｰﾌﾞﾙ = true;
    autoStart = true;
  };
}
```