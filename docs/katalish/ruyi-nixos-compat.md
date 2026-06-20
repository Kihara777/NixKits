# ruyi-nixos-compat

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / [ruyi-nixos-compat] . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( [ruyi-nixos-compat] . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / [ruyi-nixos-compat] . md )

[Provides] ﾆｯｸｽOS [runtime] ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ﾙｲｰ : [pre-compiled] RISC-V ﾂｰﾙﾁｪｰﾝ [binaries] [cannot] ﾗﾝ [directly] ｵﾝ ﾆｯｸｽOS [because] ｻﾞ [expected] ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ `/ [lib64] / [ld-linux-x86-64] . so . 2 ` [does] ﾉｯﾄ [exist] . ﾃﾞｨｽ ｵｰﾊﾞｰﾚｲ [transparently] [addresses] ﾃﾞｨｽ [via] ｱ ﾊﾟｯﾁ .

## Scope

[Required] ﾌｫｱ ﾆｯｸｽOS [users] ﾌｰ [download] ｱﾝﾄﾞ [execute] RISC-V [cross-compilation] [toolchains] ( ｼﾞｰｼｰｼｰ , ｷｭｰｴﾐｭｰ , [etc] .) [via] ﾙｲｰ . [Users] ﾉｯﾄ [working] ｳｨｽﾞ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ do ﾉｯﾄ [need] ﾄｩ [enable] ｲｯﾄ .

## Install

```nix
[nixpkgs] . [overlays] = [
[nix-kits] . [overlays] . [ruyi-nixos-compat] # [standalone] ｵｰﾊﾞｰﾚｲ
];
```

## Features

- ** ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ [reroute] [**:] [Replaces] [embedded] [FHS] [paths] ｳｨｽﾞ ｻﾞ ﾆｯｸｽOS ` ld . so `
- ** ﾂｰﾙﾁｪｰﾝ [sub-process] [repair] [**:] [GCC-internal] [sub-processes] (` [cc1] `, ` ｱｽﾞ `, ` [collect2] `) ｱｰ [auto-fixed] [via] ` [patchelf] `
- ** ﾆｯｸｽ [console_scripts] [compat] [**:] [Uses] ` [RUYI_ARGV0] ` ﾄｩ [recover] ` ｴｸﾞｾﾞｯｸ -a ` [semantics]

## Design

[Minimally] [invasive] : ｻﾞ ﾊﾟｯﾁ ｵﾝﾘｰ [activates] [inside] ﾙｲｰ ｳｪﾝ ｱ ﾆｯｸｽOS ｴﾝﾊﾞｲﾛﾒﾝﾄ ｲｽﾞ [detected] ｱﾝﾄﾞ ｱ [pre-compiled] ﾂｰﾙﾁｪｰﾝ ｲｽﾞ [about] ﾄｩ ﾋﾞｰ ` [execv] ` 'd . ｵﾝ [non-NixOS] [systems] ｻﾞ ﾊﾟｯﾁ [logic] ｲｽﾞ [completely] [short-circuited] .

## Verification

```bash
# check whether the nixos_compat module is loaded
[find] / ﾆｯｸｽ / [store] /* [-ruyi-] */ ﾘﾌﾞ [-name] ['nixos_compat] . [py']