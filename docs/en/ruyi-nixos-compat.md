# ruyi-nixos-compat

[中文](../../zh/ruyi-nixos-compat.md) | English | [日本語](../ja/ruyi-nixos-compat.md) | [Katalish](../katalish/ruyi-nixos-compat.md) | [Pseudo-Chinese](../pcn/ruyi-nixos-compat.md)

Provides NixOS runtime compatibility for ruyi: pre-compiled RISC-V toolchain binaries cannot run directly on NixOS because the expected dynamic linker path `/lib64/ld-linux-x86-64.so.2` does not exist. This overlay transparently addresses this via a patch.

## Scope

Required for NixOS users who download and execute RISC-V cross-compilation toolchains (GCC, QEMU, etc.) via ruyi. Users not working with RISC-V development do not need to enable it.

## Install

```nix
nixpkgs.overlays = [
  nix-kits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

## Features

- **Dynamic linker reroute**: Replaces embedded FHS paths with the NixOS `ld.so`
- **Toolchain sub-process repair**: GCC-internal sub-processes (`cc1`, `as`, `collect2`) are auto-fixed via `patchelf`
- **Nix console_scripts compat**: Uses `RUYI_ARGV0` to recover `exec -a` semantics

## Design

Minimally invasive: the patch only activates inside ruyi when a NixOS environment is detected and a pre-compiled toolchain is about to be `execv`'d. On non-NixOS systems the patch logic is completely short-circuited.

## Verification

```bash
# check whether the nixos_compat module is loaded
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
