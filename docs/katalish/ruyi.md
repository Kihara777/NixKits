# ruyi

[ 中文 [](../] ｾﾞｯﾄｴｲﾁ / ﾙｲｰ . md ) | [ ｲﾝｸﾞﾘｯｼｭ ]( ﾙｲｰ . md ) | [ [日本語] [](../] ｼﾞｪｲｴｲ / ﾙｲｰ . md )

ﾊﾟｯｹｰｼﾞ [manager] ﾌｫｱ [ RuyiSDK ]( https [://] [ruyisdk] . [org] ) — RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ [toolkit] [providing] ﾂｰﾙﾁｪｰﾝ [installation] , ﾊﾞｰﾁｬﾙ ｴﾝﾊﾞｲﾛﾒﾝﾄ [management] , ﾃﾞｨﾊﾞｲｽ [provisioning] , ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ [operations] .

## Info

ｱｲﾃﾑ|ﾊﾞﾘｭｰ
- - - - - -|- - - - - - -
ﾊﾞｰｼﾞｮﾝ|0 . 51 . 0 - alpha . 20260616
Upstream|[ ruyisdk / ﾙｲｰ ] ( https : / / github . com / ruyisdk / ﾙｲｰ )
ﾗｲｾﾝｽ|Apache 2 . 0
ﾉｰﾄ|Alpha - stage ｿﾌﾄｳｪｱ , APIs ﾒｲ change

## Dev Shell

```bash
ﾆｯｸｽ [develop] [nix-kits] # ﾙｲｰ # ｳｪﾝ [nix-kits] ｲｽﾞ [already] ｱ ﾌﾚｲｸ ｲﾝﾌﾟｯﾄ
ﾆｯｸｽ [develop] [github] : [Kihara777] / NixKits # ﾙｲｰ # [zero-config] [one-shot]
```

[Enters] ｱﾝ ｴﾝﾊﾞｲﾛﾒﾝﾄ ｳｨｽﾞ ` ﾙｲｰ ` [available] ｵﾝ `$ ﾊﾟｽ `.

## Install

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . ﾊﾟｯｹｰｼﾞｰｽﾞ [.${] [pkgs] . ｼｽﾃﾑ }. ﾙｲｰ ];

# Or via overlay
[nixpkgs] . [overlays] = [ ｲﾝﾌﾟｯﾄｽﾞ . [nix-kits] . [overlays] . ﾃﾞﾌｫﾙﾄ ];
ｴﾝﾊﾞｲﾛﾒﾝﾄ . [systemPackages] = [ [pkgs] . ﾙｲｰ ];
```

## Usage

```bash
ﾙｲｰ [--help]
ﾙｲｰ ﾘｽﾄ [--all] # ﾘｽﾄ ｵｰﾙ [available] ﾊﾟｯｹｰｼﾞｰｽﾞ
ﾙｲｰ ｲﾝｽﾄｰﾙ < [pkg] > # ｲﾝｽﾄｰﾙ ｱ ﾂｰﾙﾁｪｰﾝ
ﾙｲｰ [venv] [--toolchain] < t > # ｸﾘｴｲﾄ ｱ ﾊﾞｰﾁｬﾙ ｴﾝﾊﾞｲﾛﾒﾝﾄ
ﾙｲｰ ﾃﾞｨﾊﾞｲｽ [provision] # [Provision] ｱ ﾃﾞｨﾊﾞｲｽ
```

> ﾙｲｰ [requires] [network] [access] ﾄｩ ｸﾛｰﾝ ｻﾞ ﾊﾟｯｹｰｼﾞ [index] (` [packages-index] `). ﾃﾞｨｽ [happens] [automatically] ｵﾝ ﾌｧｰｽﾄ ` ﾙｲｰ ﾘｽﾄ `.

## Module

[Declarative] ﾆｯｸｽOS ﾓｼﾞｭｰﾙ ﾌｫｱ ﾙｲｰ [runtime] ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ :

```nix
# flake.nix
{ ﾓｼﾞｭｰﾙｽﾞ = [ [nix-kits] . [nixosModules] . ﾙｲｰ ]; }

[services] . ﾙｲｰ = {
[enable] = [true] ;
ｾｯﾃｨﾝｸﾞｽﾞ = {
ﾊﾟｯｹｰｼﾞｰｽﾞ . [prereleases] = [false] ;
[repo] . [remote] = " https [://] [github] . [com] / [ruyisdk] / [packages-index] . [git] ";
[telemetry] . ﾓｰﾄﾞ = " [local] ";
};
[telemetryOptout] = [true] ; # [RUYI_TELEMETRY_OPTOUT] = 1
};
```

[Generates] `/ [etc] / [xdg] / ﾙｲｰ / ｺﾝﾌｨｸﾞ . [toml] `, [sets] ｴﾝﾊﾞｲﾛﾒﾝﾄ [variables] , ｱﾝﾄﾞ [auto-updates] ｻﾞ ﾊﾟｯｹｰｼﾞ [index] ｵﾝ [activation] .

[Supports] [declarative] ﾊﾞｰﾁｬﾙ [environments] :

```nix
[services] . ﾙｲｰ . [venvs] . [riscv] = {
[profile] = " [gnu-plct] ";
ﾂｰﾙﾁｪｰﾝ = " [gnu-plct] ";
[dest] = "/ ﾎｰﾑ / [kix] / [ruyi-venvs] / [riscv] ";
};
```

## NixOS Compatibility

ｻﾞ NixKits ﾙｲｰ ﾋﾞﾙﾄﾞ [includes] ` ﾊﾟｯﾁｰｽﾞ / [ruyi-nixos-compat] . ﾊﾟｯﾁ `, [transparently] [handling] [NixOS-specific] [issues] :

- ** ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ [**:] [Pre-compiled] RISC-V ﾂｰﾙﾁｪｰﾝ [binaries] ( ｼﾞｰｼｰｼｰ , ｷｭｰｴﾐｭｰ , [etc] .) [expect] `/ [lib64] / [ld-linux-x86-64] . so . 2 `, [absent] ｵﾝ ﾆｯｸｽOS . ｻﾞ ﾊﾟｯﾁ [reroutes] [execution] [through] ｻﾞ ﾆｯｸｽOS ` ld . so `.
- ** ﾂｰﾙﾁｪｰﾝ [sub-process] [repair] [**:] [GCC-internal] [sub-processes] ﾗｲｸ ` [cc1] `, ` ｱｽﾞ `, ` [collect2] ` [bypass] [ruyi's] ﾏｯｸｽ ; ｻﾞ ﾊﾟｯﾁ [auto-fixes] [their] ｴﾙﾌ ｲﾝﾀｰﾌﾟﾘﾀ [via] ` [patchelf] `.
- ** ﾆｯｸｽ [console_scripts] ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ [**:] [Uses] ` [RUYI_ARGV0] ` ｴﾇﾌﾞｲ [var] ﾄｩ [recover] ` ｴｸﾞｾﾞｯｸ -a ` [semantics] [lost] ｲﾝ ﾆｯｸｽ [wrappers] .

## Notes

- [Maintained] ﾊﾞｲ [ ISCAS ]( https [://] [www] . [iscas] . ac . cn ) ﾌｫｱ RISC-V [developers]
- [Runtime] [dependencies] ( [curl] , [gnutar] , [git] , [patchelf] , [etc] .) ｱｰ [injected] [via] [wrapProgram]
- ﾃｽﾄ [coverage] : [ruff] [lint] , [mypy] ﾀｲﾌﾟ [checks] , [pytest] [unit] ( 320 ), [integration] ( 52 ) — ｵｰﾙ [passing]