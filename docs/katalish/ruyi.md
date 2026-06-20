# ruyi

[中文](../zh/ruyi.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

Package ﾑｱﾝｱｼﾞｴﾗ for [RuyiSDK](https://ruyisdk.org) — RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ toolkit providing toolchain ｲﾝｽﾄｰﾙation, virtual ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ management, device provisioning, and ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ operations.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | Apache 2.0 |
| Note | Alpha-stage ｿﾌﾄｳｪｱ, APIs may change |

## Dev Shell

```bash
nix develop nix-kits#ruyi             # when nix-kits is already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

Enters an ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ with `ruyi` available on `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# Or via overlay
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## ﾕｰｾｰｼﾞ

```bash
ruyi --help
ruyi list --all          # List all available packages
ruyi install <pkg>       # Install a toolchain
ruyi venv --toolchain <t> # Create a virtual environment
ruyi device provision    # Provision a device
```

> ruyi requires network access to clone the ﾊﾟｯｹｰｼﾞ index (`ﾊﾟｯｹｰｼﾞs-index`). This happens automatically on first `ruyi list`.

## Module

Declarative NixOS ﾓｼﾞｭｰﾙ for ruyi ﾗﾝﾀｲﾑ ｺﾝﾌｨｷﾞｭﾗｴｰｼｮﾝ:

```nix
# flake.nix
{ modules = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
  enable = true;
  settings = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

Generates `/etc/xdg/ruyi/config.toml`, sets ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ variables, and auto-updates the ﾊﾟｯｹｰｼﾞ index on activation.

Supports declarative virtual ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄs:

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits ruyi ﾋﾞﾙﾄﾞ includes `ﾊﾟｯﾁes/ruyi-nixos-compat.ﾊﾟｯﾁ`, transparently handling NixOS-specific issues:

- **Dynamic linker path**: Pre-compiled RISC-V toolchain binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent on NixOS. The ﾊﾟｯﾁ reroutes execution through the NixOS `ld.so`.
- **Toolchain sub-process repair**: GCC-internal sub-processes like `cc1`, `as`, `collect2` bypass ruyi's mux; the ﾊﾟｯﾁ auto-fixes their ELF interpreter via `ﾊﾟｯﾁelf`.
- **Nix console_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: Uses `RUYI_ARGV0` env var to recover `exec -a` semantics lost in Nix wrappers.

## Notes

- Maintained by [ISCAS](https://www.iscas.ac.cn) for RISC-V developers
- Runtime dependencies (curl, gnutar, git, ﾊﾟｯﾁelf, etc.) are injected via wrapProgram
- Test coverage: ruff lint, mypy type ﾁｪｯｸs, pytest unit (320), integration (52) — all passing
