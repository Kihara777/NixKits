# ruyi

[![ruyi x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-x86_64.yml?branch=main&label=ruyi%20x86_64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-aarch64.yml?branch=main&label=ruyi%20aarch64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-riscv64.yml?branch=main&label=ruyi%20riscv64%20v0.52.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-x86_64.yml?branch=main&label=ruyi-beta%20x86_64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-aarch64.yml?branch=main&label=ruyi-beta%20aarch64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-beta riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-beta-riscv64.yml?branch=main&label=ruyi-beta%20riscv64%20v0.53.0-beta.20260917)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-x86_64.yml?branch=main&label=ruyi-alpha%20x86_64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-aarch64.yml?branch=main&label=ruyi-alpha%20aarch64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![ruyi-alpha riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-ruyi-alpha-riscv64.yml?branch=main&label=ruyi-alpha%20riscv64%20v0.52.0-alpha.20260714)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)


[中文](../zh/ruyi.md) | English | [日本語](../ja/ruyi.md)  | [偽中国語](../pcn/ruyi.md)

The package manager for [RuyiSDK](https://ruyisdk.org), used for toolchain installation, virtual environment management, device provisioning, and package repository operations in RISC-V development environments.

## Basic Information

| Item | Value |
|------|-------|
| Version | 0.52.0 (stable) |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| License | Apache 2.0 |
| Channel | stable 0.52.0 · beta 0.53.0-beta.20260917 · alpha 0.52.0-alpha.20260714 |

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
| `ruyi` | 0.52.0 (stable) | Production |
| `ruyi-beta` | 0.53.0-beta.20260917 | Preview |
| `ruyi-alpha` | 0.52.0-alpha.20260714 | Bleeding edge |

```nix
environment.systemPackages = [
  inputs.nixkits.packages.${pkgs.system}.ruyi-beta
];
```

## Usage

```bash
ruyi --help
ruyi list --all          # list all available packages
ruyi install <pkg>       # install a package
ruyi venv --toolchain <t> # create Python virtualenv with given toolchain
ruyi device provision    # create RISC-V device virtual environment
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
  dest = "~/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits packaged version **ships the patch** `patches/ruyi-nixos-compat.patch` built in, which transparently handles runtime incompatibilities on NixOS. The patch now lives in `packages/ruyi/ruyi.nix` and is shared by all three channels (stable / beta / alpha) — **no overlay configuration is required**; it takes effect as soon as the package is installed.

> History: this patch used to be mounted via the overlay `ruyi-nixos-compat` onto **nixpkgs' `ruyi`**. nixpkgs later dropped the `ruyi` package, so the overlay lost its host — neither the flake package nor the NixOS module could see it (only the devShell, which wrapped it itself, worked). Declaring `patches = [...]` in the package removes the mismatch where the documentation claimed an inclusion that did not actually take effect.

**Features**
- **Dynamic linker redirection**: Prebuilt RISC-V toolchain binaries expect `/lib64/ld-linux-x86-64.so.2`, which does not exist on NixOS. The patch automatically redirects execution via NixOS's `ld.so`.
- **GCC subprocess fix**: Subprocesses like `cc1`, `as`, `collect2` bypass the ruyi mux; the patch fixes their ELF interpreter via `patchelf`.
- **Nix console_scripts compatibility**: The `RUYI_ARGV0` environment variable restores `exec -a` semantics lost by the Nix wrapper.

**Verification**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> The patch logic is fully short-circuited on non-NixOS systems and does not interfere with other distributions. Required for users who use ruyi to download and execute RISC-V cross-compilation toolchains.

## Notes

- Upstream is a RISC-V developer tool maintained by [ISCAS](https://www.iscas.ac.cn)
- Binaries have runtime dependencies (curl, gnutar, git, patchelf) injected via wrapProgram
- Python runtime dependencies come from `propagatedBuildInputs`. Upstream has listed `pyelftools` (ELF/ABI checks) as a runtime dependency since 0.53.0 and imports `elftools` at test collection time -- without it the whole pytest run aborts with `Interrupted: 1 error during collection`. This package adds the dependency **unconditionally in the shared base**, so the 0.52.x channels (which do not need it upstream) carry it too: redundant but harmless, in exchange for one identical definition across all three channels
- Test coverage: ruff lint, mypy type checking, pytest unit and integration tests -- the counts differ per channel (measured):
  - `ruyi` (0.52.0): **368** unit, **58** integration
  - `ruyi-beta` (0.53.0-beta): **462** unit, **70** integration
  - `ruyi-alpha` (0.52.0-alpha): **346** unit, **57** integration
  - The ruff and mypy steps are `|| true` in `checkPhase` (non-blocking); **pytest is what actually gates the build**

## Cache

`cachix use nixkits` (the flake automatically declares this via `nixConfig`; prompted automatically when using the flake input).
