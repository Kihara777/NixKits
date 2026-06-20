# rog-control-center-fix

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [rog-control-center-fix] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [rog-control-center-fix] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [rog-control-center-fix] . md )

ﾌｨｯｸｼｰｽﾞ ｱ [systemd] [deadlock] [during] [shutdown] ｲﾝ ` [asus-shutdown] . ｻｰﾋﾞｽ `.

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|Tracks nixpkgs
ﾀｲﾌﾟ|ﾆｯｸｽOS ﾓｼﾞｭｰﾙ
ﾊﾟｽ|` ﾓｼﾞｭｰﾙｽﾞ / rog - control - center - ﾌｨｯｸｽ . ﾆｯｸｽ `
ﾄﾘｶﾞｰ|` services . asusd . enable = true `

## Fixes

- ** ﾘﾑｰﾌﾞ [PartOf] [**:] [Clears] ` [PartOf] ` ｵﾝ ` [asus-shutdown] . ｻｰﾋﾞｽ ` ﾄｩ [prevent] [cascading] ｽﾄｯﾌﾟ [deadlock] ｳｪﾝ [asusd] [restarts]

## Install

```nix
{
[imports] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [nixosModules] . [rog-control-center-fix] ];

[services] . [asusd] . [enable] = [true] ;
}
```