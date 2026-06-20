# rcc-fix

[中文](../../zh/rcc-fix.md) | [English](rcc-fix.md) | [日本語](../../ja/rcc-fix.md) | [ｶﾀﾘｯｼｭ](../../katalish/rcc-fix.md)

Patches `asusctl` for better ASUS ROG Control Center on 2-in-1 detachable devices.

## Info

| Item | Value |
|------|-------|
| Version | Follows nixpkgs `asusctl` |
| Upstream | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| Patch | This repo `patches/rog-control-center-fix.patch` |
| Module | `nixosModules.rog-control-center-fix` (systemd deadlock fix) |
| Note | Overlay replaces `pkgs.asusctl`, no standalone package |

## Fixes

- **Keyboard detection**: Shows multi-language overlay when keyboard disconnected, avoids crash
- **Hot-plug recovery**: D-Bus event-driven — auto-restores Aura UI on reconnect
- **Boundary checks**: PowerZone index guards for firmware-reported invalid zones
- **systemd deadlock fix**: Removes `PartOf` from `asus-shutdown.service` to prevent cascading stop deadlock

## Install

Overlay (code patch) + NixOS module (systemd fix), recommended together:

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
