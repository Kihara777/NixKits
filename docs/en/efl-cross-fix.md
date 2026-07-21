# efl-cross-fix

[中文](../zh/efl-cross-fix.md) | English | [日本語](../ja/efl-cross-fix.md)  | [偽中国語](../pcn/efl-cross-fix.md)

Fixes `efl` (Enlightenment Foundation Libraries) cross-compilation failures caused by missing host-architecture code generation tools.

## Info

| Item | Value |
|------|-------|
| Version | Tracks nixpkgs `enlightenment.efl` |
| Upstream | [Enlightenment/efl](https://git.enlightenment.org/enlightenment/efl) |
| Overlay | `overlays/efl-cross-fix.nix` |
| Scope | `pkgsCross.{riscv64,riscv64-musl,aarch64}.enlightenment.efl` |
| Note | Overlay modifies upstream packages; not in binary cache |

## Fix

- **Code-gen injection**: copies the host-compiled native `efl` `bin/` into the cross-compilation build directory and prepends it to `PATH`, so meson can find `eolian_gen`, `eet`, and other native tools
- **Multi-arch**: covers `riscv64`, `riscv64-musl`, and `aarch64` target architectures
- **Dependency chain**: packages that depend on `efl` via `pkgsCross` (e.g. `fastfetch`) benefit automatically

## Install

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.efl-cross-fix ];
}
```

## Cache

Patches are overlays that modify upstream nixpkgs packages rather than independent builds, and are not in the binary cache.