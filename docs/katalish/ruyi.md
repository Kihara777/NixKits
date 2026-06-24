# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/ruyi.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/ruyi.md)

The package manager for [RuyiSDK](https://ruyisdk.org), used for toolchain installation, virtual environment management, device provisioning, and package repository operations in RISC-V development environments.

## Basic Information

| Item | Value |
|------|-------|
| Version | 0.50.0 (stable) |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| License | Apache 2.0 |
| Channel | stable | beta | alpha |

## Installation

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# or via overlay
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## Version Channels

ruyi provides three independent packages:

| Package | Version | Purpose |
|------|------|------|
| `ruyi` | 0.50.0 (stable) | Production |
| `ruyi-beta` | 0.50.0-beta.20260623 | Preview |
| `ruyi-alpha` | 0.51.0-alpha.20260616 | Bleeding edge |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta
];
```

## Usage

```bash
ruyi --help
ruyi list --all          # list all available packages
ruyi install <pkg>       # install a toolchain
ruyi venv --toolchain <t> # create a virtual environment
ruyi device provision    # device provisioning
```

> ruyi requires network access to clone the package repository (`packages-index`); running `ruyi list` for the first time downloads it automatically.

## Module

Declarative configuration of ruyi's runtime behavior:

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

The module auto-generates `/etc/xdg/ruyi/config.toml`, sets environment variables, and automatically updates the package repository index on system activation.

Declarative virtual environments are supported:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits packaged version includes the overlay `ruyi-nixos-compat` (`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`), which transparently handles runtime incompatibilities on NixOS:

**Adding**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # standalone overlay
];
```

**Features**
- **Dynamic linker redirection**: Prebuilt RISC-V toolchain binaries expect `/lib64/ld-linux-x86-64.so.2`, which does not exist on NixOS. The patch automatically redirects execution via NixOS's `ld.so`.
- **GCC subprocess fix**: Subprocesses like `cc1`, `as`, `collect2` bypass the ruyi mux; the patch fixes their ELF interpreter via `patchelf`.
- **Nix console_scripts compatibility**: The `RUYI_ARGV0` environment variable restores `exec -a` semantics lost by the Nix wrapper.

**Verification**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> This overlay is only enabled on NixOS. On non-NixOS systems the patch logic is fully short-circuited and does not interfere with other distributions. Required for users who use ruyi to download and execute RISC-V cross-compilation toolchains.

## Notes

- Upstream is a RISC-V developer tool maintained by [ISCAS](https://www.iscas.ac.cn)
- Binaries have runtime dependencies (curl, gnutar, git, patchelf) injected via wrapProgram
- Test coverage: ruff lint, mypy type checking, pytest unit tests (320 items), integration tests (52 items) — all passing

## Cache

`cachix use nixkits` (the flake automatically declares this via `nixConfig`; prompted automatically when using the flake input).
