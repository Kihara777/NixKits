# ruyi-nixos-compat

[中文](../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../ja/ruyi-nixos-compat.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/ruyi-nixos-compat.md)

Provides NixOS ﾗﾝﾀｲﾑ ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ ﾌｫｱ ruyi: pre-compiled RISC-V toolchain binaries cannot run directly on NixOS because ｻﾞ expected dynamic linker path `/lib64/ld-linux-x86-64.so.2` does ﾉｯﾄ exist. This ｵｰﾊﾞｰﾚｲ transparently addresses ﾃﾞｨｽ via ｱ ﾊﾟｯﾁ.

## Scope

Required ﾌｫｱ NixOS users who download ｱﾝﾄﾞ execute RISC-V cross-compilation toolchains (GCC, QEMU, etc.) via ruyi. Users ﾉｯﾄ working ｳｨｽﾞ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ do ﾉｯﾄ need to ｲﾈｰﾌﾞﾙ it.

## ｲﾝｽﾄｰﾙ

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

## ﾌｨｰﾁｬｰｽﾞ

- **Dynamic linker reroute**: Replaces embedded FHS paths ｳｨｽﾞ ｻﾞ NixOS `ld.so`
- **Toolchain sub-process repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) ｱｰ auto-fixed via `patchelf`
- **Nix console_scripts compat**: Uses `RUYI_ARGV0` to recover `exec -a` semantics

## Design

Minimally invasive: ｻﾞ ﾊﾟｯﾁ ｵﾝﾘｰ activates inside ruyi ｳｪﾝ ｱ NixOS ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ｲｽﾞ detected ｱﾝﾄﾞ ｱ pre-compiled toolchain ｲｽﾞ about to be `execv`'d. On non-NixOS systems ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ completely short-circuited.

## Verification

```bash
# check whether the nixos_compat module is loaded
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
