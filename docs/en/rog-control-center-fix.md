# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md)

Fixes a systemd deadlock during shutdown in `asus-shutdown.service`.

## Info

| Item | Value |
|------|-------|
| Version | Tracks nixpkgs |
| Type | NixOS module |
| Path | `modules/rog-control-center-fix.nix` |
| Trigger | `services.asusd.enable = true` |

## Fixes

- **Remove PartOf**: Clears `PartOf` on `asus-shutdown.service` to prevent cascading stop deadlock when asusd restarts

## Install

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
