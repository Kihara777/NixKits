# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/rog-control-center-fix.md)

Fixes ｱ systemd deadlock during shutdown in `asus-shutdown.ｻｰﾋﾞｽ`.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Tracks nixpkgs |
| Type | NixOS ﾓｼﾞｭｰﾙ |
| Path | `modules/rog-control-center-fix.nix` |
| Trigger | `services.asusd.ｲﾈｰﾌﾞﾙ = true` |

## Fixes

- **Remove PartOf**: Clears `PartOf` on `asus-shutdown.ｻｰﾋﾞｽ` to prevent cascading stop deadlock ｳｪﾝ asusd restarts

## ｲﾝｽﾄｰﾙ

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
