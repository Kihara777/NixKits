# rcc-fix

[中文](../zh/rcc-fix.md) | [English](rcc-fix.md) | [日本語](../ja/rcc-fix.md)

Patches `asusctl` for better ASUS ROG Control Center on 2-in-1 detachable devices.

## Info

| Item | Value |
|------|-------|
| Version | Follows nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| Patch | This repo `patches/rog-control-center-fix.patch` |
| Note | Overlay replaces `pkgs.asusctl`, no standalone package |

## Fixes

- **Keyboard detection**: Shows multi-language message instead of crashing on detachable keyboards
- **Hot-plug recovery**: D-Bus event-driven — auto-restores Aura UI on reconnect
- **Boundary checks**: PowerZone index guards for firmware-reported invalid zones

## Install

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

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
