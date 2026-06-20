# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-fix.md) | [偽中国語](../pcn/rog-control-center-fix.md)

Fixes a systemd deadlock during shutdown in `asus-shutdown.ｻｰﾋﾞｽ`.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Tracks nixpkgs |
| Type | NixOS ﾓｼﾞｭｰﾙ |
| Path | `ﾓｼﾞｭｰﾙs/rog-control-center-fix.nix` |
| Trigger | `ｻｰﾋﾞｽs.asusd.enable = true` |

## Fixes

- **Remove PartOf**: Clears `PartOf` on `asus-shutdown.ｻｰﾋﾞｽ` to prevent cascading stop deadlock when asusd restarts

## ｲﾝｽﾄｰﾙ

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
