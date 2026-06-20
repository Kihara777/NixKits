# ruyi-ﾆｯｸｽOS-compat

[中文](../../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../../ja/ruyi-nixos-compat.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/ruyi-nixos-compat.md)

Provides NixOS runtime compatibility ﾌｫｱ ruyi: pre-compiled ﾘｽｸ-V toolchain binaries cannot run directly ｵﾝ NixOS because ｻﾞ expected ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ `/lib64/ld-linux-x86-64.so.2` does ﾉｯﾄ exist. ﾃﾞｨｽ ｵｰﾊﾞｰﾚｲ transparently addresses ﾃﾞｨｽ via ｱ ﾊﾟｯﾁ.

## Scope

Required ﾌｫｱ NixOS ﾕｰｻﾞｰｽﾞ who download ｱﾝﾄﾞ execute ﾘｽｸ-V cross-compilation toolchains (GCC, QEMU, etc.) via ruyi. ﾕｰｻﾞｰｽﾞ ﾉｯﾄ working ｳｨｽﾞ ﾘｽｸ-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ do ﾉｯﾄ need ﾄｩ enable ｲｯﾄ.

## ｲﾝｽﾄｰﾙ

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

## ﾌｨｰﾁｬｰｽﾞ

- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ reroute**: Replaces embedded FHS ﾊﾟｽｽﾞ ｳｨｽﾞ ｻﾞ NixOS `ld.so`
- **Toolchain sub-ﾌﾟﾛｾｽ repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) ｱｰ ｵｰﾄ-fixed via `patchelf`
- **ﾆｯｸｽ console_scripts compat**: Uses `RUYI_ARGV0` ﾄｩ recover `exec -a` semantics

## Design

Minimally invasive: ｻﾞ ﾊﾟｯﾁ ｵﾝﾘｰ ｱｸﾃｨﾍﾞｲﾄｽﾞ inside ruyi when ｱ NixOS environment ｲｽﾞ detected ｱﾝﾄﾞ ｱ pre-compiled toolchain ｲｽﾞ about ﾄｩ ﾋﾞｰ `execv`'d. ｵﾝ non-NixOS ｼｽﾃﾑｽﾞ ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ completely short-circuited.

## Verification

```bash
# check whether the nixos_compat module is loaded
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'