# rcc-ﾌｨｯｸｽ

[中文](../zh/rcc-ﾌｨｯｸｽ.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/rcc-ﾌｨｯｸｽ.md) | [ｶﾀﾘｯｼｭ](../katalish/rcc-ﾌｨｯｸｽ.md) | [偽中国語](../pcn/rcc-ﾌｨｯｸｽ.md)

ﾊﾟｯﾁｰｽﾞ `asusctl` ﾌｫｱ better ASUS ROG Control Center ｵﾝ 2-ｲﾝ-1 detachable devices.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Follows nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| Patch | This repo `ﾊﾟｯﾁes/rog-control-center-ﾌｨｯｸｽ.ﾊﾟｯﾁ` |
| Module | `nixosModules.rog-control-center-ﾌｨｯｸｽ` (systemd ﾃﾞｯﾄﾞﾛｯｸ ﾌｨｯｸｽ) |
| Note | Overlay replaces `pkgs.asusctl`, ﾉｰ standalone ﾊﾟｯｹｰｼﾞ |

## Fixes

- **Keyboard detection**: Shows multi-language ｵｰﾊﾞｰﾚｲ ｳｪﾝ keyboard disconnected, avoids crash
- **Hot-plug recovery**: D-Bus event-driven — ｵｰﾄ-restores Aura UI ｵﾝ reconnect
- **Boundary ﾁｪｯｸs**: PowerZone index guards ﾌｫｱ firmware-reported invalid zones
- **systemd ﾃﾞｯﾄﾞﾛｯｸ ﾌｨｯｸｽ**: Removes `PartOf` ﾌﾛﾑ `asus-ｼｬｯﾄﾀﾞｳﾝ.ｻｰﾋﾞｽ` ﾄｩ ﾌﾟﾗｴﾌﾞｴﾝﾄ cascading stop ﾃﾞｯﾄﾞﾛｯｸ

## ｲﾝｽﾄｰﾙ

Overlay (code ﾊﾟｯﾁ) + NixOS ﾓｼﾞｭｰﾙ (systemd ﾌｨｯｸｽ), recommended together:

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-ﾌｨｯｸｽ ];

  imports = [ inputs.nix-kits.nixosModules.rog-control-center-ﾌｨｯｸｽ ];

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
