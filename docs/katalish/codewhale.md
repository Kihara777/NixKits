# codewhale

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [codewhale] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [codewhale] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [codewhale] . md )

ｱ [terminal] ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ [built] ﾌｫｱ [DeepSeek] V4 .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|0 . 8 . 60
Upstream|[ Hmbown / CodeWhale ] ( https : / / github . com / Hmbown / CodeWhale )
ﾀｲﾌﾟ|Pre - built binaries ( GitHub Releases )

## Install

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. [codewhale] ];

# Default overlay → pkgs.codewhale
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
```

## Usage

```bash
[codewhale] # [interactive] [TUI]
[codewhale] " [explain] ﾃﾞｨｽ [function] " # [one-shot] [prompt]
[codewhale] [--model] ｵｰﾄ " ﾌｨｯｸｽ ﾃﾞｨｽ ﾊﾞｸﾞ " # [auto-select] ﾓﾃﾞﾙ
[codewhale] [--yolo] # [auto-approve] ﾂｰﾙｽﾞ
[codewhale] [doctor] # ﾁｪｯｸ [setup]
[codewhale] [auth] [set] [--provider] [deepseek] # ｾｰﾌﾞ ｴｰﾋﾟｰｱｲ ｷｰ
```

[Requires] ｱ [ [DeepSeek] ｴｰﾋﾟｰｱｲ ｷｰ ]( https [://] ﾌﾟﾗｯﾄﾌｫｰﾑ . [deepseek] . [com] / [api_keys] ) ｵﾝ ﾌｧｰｽﾄ ﾗﾝ .