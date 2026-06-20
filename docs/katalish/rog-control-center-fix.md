# rog-control-center-ﾌｨｯｸｽ

[中文](../zh/rog-control-center-ﾌｨｯｸｽ.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/rog-control-center-ﾌｨｯｸｽ.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-ﾌｨｯｸｽ.md) | [偽中国語](../pcn/rog-control-center-ﾌｨｯｸｽ.md)

Fixes a systemd ﾃﾞｯﾄﾞﾛｯｸ during ｼｬｯﾄﾀﾞｳﾝ ｲﾝ `asus-ｼｬｯﾄﾀﾞｳﾝ.ｻｰﾋﾞｽ`.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | Tracks nixpkgs |
| Type | NixOS ﾓｼﾞｭｰﾙ |
| Path | `ﾓｼﾞｭｰﾙs/rog-control-center-ﾌｨｯｸｽ.nix` |
| Trigger | `ｻｰﾋﾞｽs.asusd.enable = true` |

## Fixes

- **Remove PartOf**: Clears `PartOf` ｵﾝ `asus-ｼｬｯﾄﾀﾞｳﾝ.ｻｰﾋﾞｽ` ﾄｩ ﾌﾟﾗｴﾌﾞｴﾝﾄ cascading stop ﾃﾞｯﾄﾞﾛｯｸ ｳｪﾝ asusd restarts

## ｲﾝｽﾄｰﾙ

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-ﾌｨｯｸｽ ];

  services.asusd.enable = true;
}
```
