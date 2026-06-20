# rcc-fix

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [rcc-fix] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [rcc-fix] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [rcc-fix] . md )

ﾊﾟｯﾁｰｽﾞ ` [asusctl] ` ﾌｫｱ [better] [ASUS] [ROG] [Control] [Center] ｵﾝ [2-in-1] [detachable] [devices] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|Follows nixpkgs ` asusctl `
Upstream|[ Asus - linux / asusctl ] ( https : / / github . com / Asus - linux / asusctl )
ﾊﾟｯﾁ|ﾃﾞｨｽ repo ` ﾊﾟｯﾁｰｽﾞ / rog - control - center - ﾌｨｯｸｽ . ﾊﾟｯﾁ `
ﾓｼﾞｭｰﾙ|` nixosModules . rog - control - center - ﾌｨｯｸｽ ` ( systemd deadlock ﾌｨｯｸｽ )
ﾉｰﾄ|ｵｰﾊﾞｰﾚｲ replaces ` pkgs . asusctl ` , ﾉｰ standalone ﾊﾟｯｹｰｼﾞ

## Fixes

- ** [Keyboard] [detection] [**:] [Shows] [multi-language] ｵｰﾊﾞｰﾚｲ ｳｪﾝ [keyboard] [disconnected] , [avoids] [crash]
- ** [Hot-plug] [recovery] [**:] D-Bus [event-driven] — [auto-restores] [Aura] UI ｵﾝ [reconnect]
- ** [Boundary] [checks] [**:] [PowerZone] [index] [guards] ﾌｫｱ [firmware-reported] [invalid] [zones]
- ** [systemd] [deadlock] ﾌｨｯｸｽ [**:] [Removes] ` [PartOf] ` ﾌﾛﾑ ` [asus-shutdown] . ｻｰﾋﾞｽ ` ﾄｩ [prevent] [cascading] ｽﾄｯﾌﾟ [deadlock]

## Install

ｵｰﾊﾞｰﾚｲ ( ｺｰﾄﾞ ﾊﾟｯﾁ ) + ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ( [systemd] ﾌｨｯｸｽ ), [recommended] [together] :

```nix
{
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . [rcc-fix] ];

[imports] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [nixosModules] . [rog-control-center-fix] ];

[services] . [asusctl] = {
[enable] = [true] ;
[power-profile] = [true] ;
[cpu-power-control] = [true] ;
};

[programs] . [rog-control-center] = {
[enable] = [true] ;
[autoStart] = [true] ;
};
}
```