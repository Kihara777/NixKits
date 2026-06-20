# rcc-fix

[中文](../zh/rcc-fix.md) | [English](../en/rcc-fix.md) | [日本語](../ja/rcc-fix.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/rcc-fix.md)

ﾊﾟｯﾁｰｽﾞ `asusctl` ﾌｫｱ better ASUS ROG Control Center on 2-in-1 detachable devices.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Follows nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| Patch | This repo `patches/rog-control-center-fix.ﾊﾟｯﾁ` |
| Module | `nixosModules.rog-control-center-fix` (systemd deadlock fix) |
| Note | Overlay replaces `pkgs.asusctl`, no standalone ﾊﾟｯｹｰｼﾞ |

## Fixes

- **Keyboard detection**: Shows multi-ﾗﾝｹﾞｰｼﾞ ｵｰﾊﾞｰﾚｲ ｳｪﾝ keyboard disconnected, avoids crash
- **Hot-plug recovery**: D-Bus event-driven — auto-restores Aura UI on reconnect
- **Boundary checks**: PowerZone index guards ﾌｫｱ firmware-reported invalid zones
- **systemd deadlock fix**: Removes `PartOf` ﾌﾛﾑ `asus-shutdown.ｻｰﾋﾞｽ` to prevent cascading stop deadlock

## ｲﾝｽﾄｰﾙ

Overlay (code ﾊﾟｯﾁ) + NixOS ﾓｼﾞｭｰﾙ (systemd fix), recommended together:

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
