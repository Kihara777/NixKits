# opencode-telegram

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [opencode-telegram] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [opencode-telegram] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [opencode-telegram] . md )

ﾃﾚｸﾞﾗﾑ ﾎﾞｯﾄ ｸﾗｲｱﾝﾄ ﾌｫｱ [ OpenCode ]( https [://] [opencode] . ai ).

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|0 . 21 . 2
Upstream|[ grinev / opencode - ﾃﾚｸﾞﾗﾑ - ﾎﾞｯﾄ ] ( https : / / github . com / grinev / opencode - ﾃﾚｸﾞﾗﾑ - ﾎﾞｯﾄ )

## Usage

```bash
# First-time setup
[opencode] [serve] # ｽﾀｰﾄ [opencode] ｻｰﾊﾞｰ
[opencode-telegram] ｺﾝﾌｨｸﾞ # [interactive] ﾃﾚｸﾞﾗﾑ ﾎﾞｯﾄ ｺﾝﾌｨｸﾞ

# Daily use
[opencode-telegram] ｽﾀｰﾄ # ｽﾀｰﾄ ( [auto-launches] [opencode] )
[opencode-telegram] [status] # ﾁｪｯｸ [status]
[opencode-telegram] ｽﾄｯﾌﾟ # ｽﾄｯﾌﾟ
```

## Install

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. [opencode-telegram] ];

# Default overlay → pkgs.opencode-telegram
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
```

## Flake Module

```nix
# flake.nix
{
ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾕｰｱｰﾙｴﾙ = " [github] : [Kihara777] / NixKits ";

[outputs] = { [nixpkgs] , [nix-kits] , ... }: {
[nixosConfigurations] . [your-host] = [nixpkgs] . ﾘﾌﾞ . [nixosSystem] {
ﾓｼﾞｭｰﾙｽﾞ = [
[nix-kits] . [nixosModules] . [opencode-telegram]
{
[services] . [opencode-telegram] = {
[enable] = [true] ;
ﾕｰｻﾞｰ = " [kix] ";
[group] = " [users] ";
[afterServices] = [ " [network-online] . [target] " " [llama-cpp] . ｻｰﾋﾞｽ " ];
};
}
];
};
};
}
```