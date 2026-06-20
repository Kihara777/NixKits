# obs-bilibili-stream

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [obs-bilibili-stream] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [obs-bilibili-stream] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [obs-bilibili-stream] . md )

ﾋﾞﾘﾋﾞﾘ [live] ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ ｵﾌﾞｴｽ [Studio] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|2 . 1 . 0
Upstream|[ Zarosmm / ｵﾌﾞｴｽ - ﾋﾞﾘﾋﾞﾘ - stream ] ( https : / / github . com / Zarosmm / ｵﾌﾞｴｽ - ﾋﾞﾘﾋﾞﾘ - stream )
ﾌﾟﾗｯﾄﾌｫｰﾑ|Linux ｵﾝﾘｰ

## Install

** [Recommended] : ﾆｯｸｽOS ﾓｼﾞｭｰﾙ **

```nix
{
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
[imports] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [nixosModules] . [obs-bilibili-stream] ];
}
```

** [Manual] **

```nix
{
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
[programs] . [obs-studio] = {
[enable] = [true] ;
[plugins] = [ [pkgs] . [obs-bilibili-stream] ];
};
}
```

** ﾎｰﾑ [Manager] **

```nix
ﾎｰﾑ . ﾊﾟｯｹｰｼﾞｰｽﾞ = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. [obs-bilibili-stream] ];
```