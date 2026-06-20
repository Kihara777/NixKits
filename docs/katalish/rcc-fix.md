# rcc-fix

[中文](../../zh/rcc-fix.md) | [English](rcc-fix.md) | [日本語](../../ja/rcc-fix.md) | [ｶﾀﾘｯｼｭ](../../katalish/rcc-fix.md) | [偽中国語](../../pcn/rcc-fix.md)

ﾊﾟｯﾁｰｽﾞ `asusctl` ﾌｫｱ better ASUS ROG Control Center ｵﾝ 2-in-1 detachable devices.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | Follows nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| ﾊﾟｯﾁ | ﾃﾞｨｽ repo `patches/rog-control-center-fix.patch` |
| ﾓｼﾞｭｰﾙ | `nixosModules.rog-control-center-fix` (systemd deadlock fix) |
| Note | ｵｰﾊﾞｰﾚｲ replaces `pkgs.asusctl`, ﾉｰ standalone ﾊﾟｯｹｰｼﾞ |

## Fixes

- **Keyboard detection**: Shows multi-ﾗﾝｹﾞｰｼﾞ ｵｰﾊﾞｰﾚｲ when keyboard disconnected, avoids crash
- **Hot-plug recovery**: D-Bus ｲﾍﾞﾝﾄ-driven — ｵｰﾄ-restores Aura UI ｵﾝ reconnect
- **Boundary checks**: PowerZone index guards ﾌｫｱ firmware-reported invalid zones
- **systemd deadlock fix**: ﾘﾑｰﾌﾞｽﾞ `PartOf` ﾌﾛﾑ `asus-shutdown.service` ﾄｩ prevent cascading ｽﾄｯﾌﾟ deadlock

## ｲﾝｽﾄｰﾙ

ｵｰﾊﾞｰﾚｲ (ｺｰﾄﾞ ﾊﾟｯﾁ) + NixOS ﾓｼﾞｭｰﾙ (systemd fix), recommended together:

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusctl = {
    enable = true;
    power-profile = true;
    cpu-power-control = true;
  };

  programs.rog-control-center = {
    enable = true;
    autoStart = true;
  };
}
```