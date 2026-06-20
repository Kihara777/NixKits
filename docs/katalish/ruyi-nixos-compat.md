# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | [偽中国語](../pcn/ruyi-nixos-compat.md)

Provides NixOS ﾗﾝﾀｲﾑ ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ruyi: pre-compiled RISC-V ﾂｰﾙﾁｪｰﾝ binaries cannot ﾗﾝ directly ｵﾝ NixOS ﾋﾞｺｰｽﾞ ｻﾞ expected dynamic linker ﾊﾟｽ `/lib64/ld-linux-x86-64.so.2` ﾀﾞｽﾞ ﾉｯﾄ exist. This ｵｰﾊﾞｰﾚｲ transparently addresses ﾃﾞｨｽ ﾌﾞｲｱ ｱ ﾊﾟｯﾁ.

## Scope

Required ﾌｫｱ NixOS users ﾌｰ download ｱﾝﾄﾞ execute RISC-V cross-compilation toolchains (GCC, QEMU, etc.) ﾌﾞｲｱ ruyi. Users ﾉｯﾄ working ｳｨｽﾞ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾄﾞｩ ﾉｯﾄ ﾆｰﾄﾞ ﾄｩ ｲﾈｰﾌﾞﾙ it.

## ｲﾝｽﾄｰﾙ

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

## Features

- **Dynamic linker reroute**: Replaces embedded FHS paths ｳｨｽﾞ ｻﾞ NixOS `ld.so`
- **Toolchain sub-ﾌﾟﾛｾｽ repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) ｱｰ ｵｰﾄ-fixed ﾌﾞｲｱ `ﾊﾟｯﾁelf`
- **Nix console_scripts compat**: Uses `RUYI_ARGV0` ﾄｩ ﾘｶﾊﾞｰ `exec -a` semantics

## Design

Minimally invasive: ｻﾞ ﾊﾟｯﾁ ｵﾝﾘｰ activates inside ruyi ｳｪﾝ ｱ NixOS ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ｲｽﾞ detected ｱﾝﾄﾞ ｱ pre-compiled ﾂｰﾙﾁｪｰﾝ ｲｽﾞ ｱﾊﾞｳﾄ ﾄｩ ﾋﾞｰ `execv`'d. On non-NixOS systems ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ completely short-circuited.

## Verification

```bash
# check whether ｻﾞ nixos_compat module ｲｽﾞ loaded
find /nix/store/*-ruyi-*/lib -ﾈｰﾑ 'nixos_compat.py'
