# ruyi

[中文](../zh/ruyi.md) | [English](ruyi.md) | [日本語](../ja/ruyi.md)

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
nix develop github:Kihara777/NixKits#ruyi
```

Enters an environment with `ruyi` available on `$PATH`.

## Install

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# Or via overlay
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
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

## Notes

- Maintained by [ISCAS](https://www.iscas.ac.cn) for RISC-V developers
- Runtime dependencies (curl, gnutar, git, etc.) are injected via wrapProgram
- Test coverage: ruff lint, mypy type checks, pytest unit (277), integration (52) — all passing
