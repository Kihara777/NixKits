# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi-nixos-compat.md) | [偽中国語](../pcn/ruyi-nixos-compat.md)

Provides NixOS ﾗﾝﾀｲﾑ ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ruyi: pre-compiled RISC-V ﾂｰﾙﾁｪｰﾝ binaries cannot ﾗﾝ directly ｵﾝ NixOS because ｻﾞ expected dynamic linker path `/lib64/ld-linux-x86-64.so.2` does ﾉｯﾄ exist. This ｵｰﾊﾞｰﾚｲ transparently addresses ﾃﾞｨｽ ﾌﾞｲｱ a ﾊﾟｯﾁ.

## Scope

Required ﾌｫｱ NixOS users who download ｱﾝﾄﾞ execute RISC-V cross-compilation toolchains (GCC, QEMU, etc.) ﾌﾞｲｱ ruyi. Users ﾉｯﾄ working ｳｨｽﾞ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ do ﾉｯﾄ need ﾄｩ enable it.

## ｲﾝｽﾄｰﾙ

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

## Features

- **Dynamic linker reroute**: Replaces embedded FHS paths ｳｨｽﾞ ｻﾞ NixOS `ld.so`
- **Toolchain sub-process repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) are ｵｰﾄ-fixed ﾌﾞｲｱ `ﾊﾟｯﾁelf`
- **Nix console_scripts compat**: Uses `RUYI_ARGV0` ﾄｩ recover `exec -a` semantics

## Design

Minimally invasive: ｻﾞ ﾊﾟｯﾁ only activates inside ruyi ｳｪﾝ a NixOS ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ｲｽﾞ detected ｱﾝﾄﾞ a pre-compiled ﾂｰﾙﾁｪｰﾝ ｲｽﾞ about ﾄｩ be `execv`'d. On non-NixOS systems ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ completely short-circuited.

## Verification

```bash
# check whether ｻﾞ nixos_compat module ｲｽﾞ loaded
find /nix/store/*-ruyi-*/lib -ﾈｰﾑ 'nixos_compat.py'
