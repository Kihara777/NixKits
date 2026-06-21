# ruyi

[中文](../zh/ruyi.md) | English | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

Package manager for [RuyiSDK](https://ruyisdk.org) — RISC-V development toolkit providing toolchain installation, virtual environment management, device provisioning, and package repository operations.

## Info

| Item | Value |
|------|-------|
| Version | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| License | Apache 2.0 |
| Note | Alpha-stage software, APIs may change |

## Dev Shell

```bash
nix develop nixkits#ruyi             # when nixkits is already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

Enters an environment with `ruyi` available on `$PATH`.

## Install

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# Or via overlay
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## Usage

```bash
ruyi --help
ruyi list --all          # List all available packages
ruyi install <pkg>       # Install a toolchain
ruyi venv --toolchain <t> # Create a virtual environment
ruyi device provision    # Provision a device
```

> ruyi requires network access to clone the package index (`packages-index`). This happens automatically on first `ruyi list`.

## Module

Declarative NixOS module for ruyi runtime configuration:

```nix
# flake.nix
{ modules = [ nixkits.nixosModules.ruyi ]; }

nixkits.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

Generates `/etc/xdg/ruyi/config.toml`, sets environment variables, and auto-updates the package index on activation.

Supports declarative virtual environments:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits ruyi build includes `patches/ruyi-nixos-compat.patch`, transparently handling NixOS-specific issues:

- **Dynamic linker path**: Pre-compiled RISC-V toolchain binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent on NixOS. The patch reroutes execution through the NixOS `ld.so`.
- **Toolchain sub-process repair**: GCC-internal sub-processes like `cc1`, `as`, `collect2` bypass ruyi's mux; the patch auto-fixes their ELF interpreter via `patchelf`.
- **Nix console_scripts compatibility**: Uses `RUYI_ARGV0` env var to recover `exec -a` semantics lost in Nix wrappers.

## Notes

- Maintained by [ISCAS](https://www.iscas.ac.cn) for RISC-V developers
- Runtime dependencies (curl, gnutar, git, patchelf, etc.) are injected via wrapProgram
- Test coverage: ruff lint, mypy type checks, pytest unit (320), integration (52) — all passing

## Cache

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).
