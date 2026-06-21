# ruyi

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/ruyi.md)

Package ﾑｱﾝｱｼﾞｴﾗ ﾌｫｱ [RuyiSDK](https://ruyisdk.org) — RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ toolkit providing toolchain installation, virtual ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ management, device provisioning, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ operations.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| License | Apache 2.0 |
| Note | Alpha-stage ｿﾌﾄｳｪｱ, APIs may change |

## Dev Shell

```bash
nix develop nixkits#ruyi             # when nixkits is already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

Enters an ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ｳｨｽﾞ `ruyi` ｱﾌﾞｴｲﾗﾌﾞﾙ on `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# Or via overlay
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
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

> ruyi requires network access to clone ｻﾞ ﾊﾟｯｹｰｼﾞ index (`packages-index`). This happens ｵｰﾄﾏﾃｨｯｸﾘｰ on ﾌｧｰｽﾄ `ruyi list`.

## Module

Declarative NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ruyi ﾗﾝﾀｲﾑ configuration:

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

Generates `/etc/xdg/ruyi/config.toml`, sets ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ variables, ｱﾝﾄﾞ auto-updates ｻﾞ ﾊﾟｯｹｰｼﾞ index on activation.

Supports declarative virtual environments:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits ruyi ﾋﾞﾙﾄﾞ includes `patches/ruyi-nixos-compat.ﾊﾟｯﾁ`, transparently handling NixOS-specific issues:

- **Dynamic linker path**: Pre-compiled RISC-V toolchain binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent on NixOS. The ﾊﾟｯﾁ reroutes execution through ｻﾞ NixOS `ld.so`.
- **Toolchain sub-process repair**: GCC-internal sub-processes like `cc1`, `as`, `collect2` bypass ruyi's mux; ｻﾞ ﾊﾟｯﾁ auto-fixes their ELF interpreter via `patchelf`.
- **Nix console_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: Uses `RUYI_ARGV0` env var to recover `exec -a` semantics lost in Nix wrappers.

## Notes

- Maintained ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn) ﾌｫｱ RISC-V developers
- Runtime dependencies (curl, gnutar, git, patchelf, etc.) ｱｰ injected via wrapProgram
- Test coverage: ruff lint, mypy type checks, pytest unit (320), integration (52) — ｵｰﾙ passing

## ｷｬｯｼｭ

NixKits ﾊﾞｲﾅﾘ ｷｬｯｼｭ ｶﾗ ｱﾌﾞｴｲﾗﾌﾞﾙ、ﾛｰｶﾙ ｺﾝﾊﾟｲﾙ 回避：

```bash
cachix use nixkits
```

或 NixOS 設定：

```nix
nix.settings.substituters = [ "https://nixkits.cachix.org" ];
nix.settings.trusted-public-keys = [ "nixkits.cachix.org-1:ycmoZnAnvjGsSzIMdGNmFdc65LeRW/GZ7GdN7KkRL8c=" ];
```
