# ruyi-nixos-compat

[中文](../../zh/ruyi-nixos-compat.md) | [English](../en/ruyi-nixos-compat.md) | [日本語](../../ja/ruyi-nixos-compat.md) | [ｶﾀﾘｯｼｭ](ruyi-nixos-compat.md) | [偽中国語](../../pcn/ruyi-nixos-compat.md)

ﾌﾟﾛﾊﾞｲﾄﾞｽﾞ NixOS ﾗﾝﾀｲﾑ compatibility ﾌｫｱ ruyi: pre-compiled RISC-V toolchain binaries cannot ﾗﾝ directly ｵﾝ NixOS because ｻﾞ ｴｸｽﾍﾟｸﾃｨｯﾄﾞ ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ `/lib64/ld-linux-x86-64.so.2` does ﾉｯﾄ exist. ﾃﾞｨｽ ｵｰﾊﾞｰﾚｲ transparently addresses ﾃﾞｨｽ via ｱ ﾊﾟｯﾁ.

## Scope

Required ﾌｫｱ NixOS ﾕｰｻﾞｰｽﾞ ﾌｰ download ｱﾝﾄﾞ execute RISC-V cross-compilation toolchains (GCC, QEMU, etc.) via ruyi. ﾕｰｻﾞｰｽﾞ ﾉｯﾄ ﾜｰｷﾝｸﾞ ｳｨｽﾞ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ do ﾉｯﾄ ﾆｰﾄﾞ ﾄｩ ｲﾈｰﾌﾞﾙ ｲｯﾄ.

## ｲﾝｽﾄｰﾙ

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone ｵｰﾊﾞｰﾚｲ
];
```

## ﾌｨｰﾁｬｰｽﾞ

- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ reroute**: Replaces embedded FHS paths ｳｨｽﾞ ｻﾞ NixOS `ld.so`
- **Toolchain sub-process repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) ｱｰ auto-fixed via `patchelf`
- **ﾆｯｸｽ console_scripts compat**: ﾕｰｼｰｽﾞ `RUYI_ARGV0` ﾄｩ ﾘｶﾊﾞｰ `exec -a` semantics

## Design

Minimally invasive: ｻﾞ ﾊﾟｯﾁ ｵﾝﾘｰ activates inside ruyi ｳｪﾝ ｱ NixOS ｴﾝﾊﾞｲﾛﾒﾝﾄ ｲｽﾞ detected ｱﾝﾄﾞ ｱ pre-compiled toolchain ｲｽﾞ about ﾄｩ ﾋﾞｰ `execv`'d. ｵﾝ non-NixOS systems ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ completely short-circuited.

## Verification

```bash
# ﾁｪｯｸ whether ｻﾞ nixos_compat ﾓｼﾞｭｰﾙ ｲｽﾞ loaded
find /ﾆｯｸｽ/store/*-ruyi-*/ﾘﾌﾞ -name 'nixos_compat.py'