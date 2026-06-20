# ruyi

[中文](../zh/ruyi.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

Package ﾑｱﾝｱｼﾞｴﾗ ﾌｫｱ [RuyiSDK](https://ruyisdk.org) — RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾂｰﾙｷｯﾄ ﾌﾟﾗｵﾌﾞｲﾃﾞｨﾝｸﾞ ﾂｰﾙﾁｪｰﾝ ｲﾝｽﾄｰﾙation, ﾊﾞｰﾁｬﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾑｱﾝｱｼﾞﾒﾝﾄ, ﾃﾞｨﾌﾞｱｲｽ provisioning, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｵﾍﾟﾗｴｰｼｮﾝｽﾞ.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | Apache 2.0 |
| Note | Alpha-stage ｿﾌﾄｳｪｱ, APIs may change |

## Dev Shell

```bash
nix develop nix-kits#ruyi             # ｳｪﾝ nix-kits ｲｽﾞ already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-ｺﾝﾌｨｸﾞ one-shot
```

Enters an ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ｳｨｽﾞ `ruyi` ｱﾌﾞｴｲﾗﾌﾞﾙ ｵﾝ `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# Or ﾌﾞｲｱ overlay
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## ﾕｰｾｰｼﾞ

```bash
ruyi --help
ruyi ﾘｽﾄ --ｵｰﾙ          # List ｵｰﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ packages
ruyi ｲﾝｽﾄｰﾙ <pkg>       # Install a ﾂｰﾙﾁｪｰﾝ
ruyi venv --ﾂｰﾙﾁｪｰﾝ <t> # Create a ﾊﾞｰﾁｬﾙ environment
ruyi ﾃﾞｨﾌﾞｱｲｽ provision    # Provision a ﾃﾞｨﾌﾞｱｲｽ
```

> ruyi requires network access ﾄｩ clone ｻﾞ ﾊﾟｯｹｰｼﾞ index (`ﾊﾟｯｹｰｼﾞs-index`). This happens automatically ｵﾝ ﾌｧｰｽﾄ `ruyi ﾘｽﾄ`.

## Module

Declarative NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ruyi ﾗﾝﾀｲﾑ ｺﾝﾌｨｷﾞｭﾗｴｰｼｮﾝ:

```nix
# flake.nix
{ modules = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
  enable = true;
  ｾｯﾃｨﾝｸﾞｽﾞ = {
    packages.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.mode = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

Generates `/etc/xdg/ruyi/ｺﾝﾌｨｸﾞ.toml`, sets ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ variables, ｱﾝﾄﾞ ｵｰﾄ-updates ｻﾞ ﾊﾟｯｹｰｼﾞ index ｵﾝ activation.

Supports declarative ﾊﾞｰﾁｬﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄs:

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  ﾂｰﾙﾁｪｰﾝ = "gnu-plct";
  dest = "/ﾎｰﾑ/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

The NixKits ruyi ﾋﾞﾙﾄﾞ includes `ﾊﾟｯﾁes/ruyi-nixos-compat.ﾊﾟｯﾁ`, transparently handling NixOS-specific issues:

- **Dynamic linker path**: Pre-compiled RISC-V ﾂｰﾙﾁｪｰﾝ binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent ｵﾝ NixOS. The ﾊﾟｯﾁ reroutes execution through ｻﾞ NixOS `ld.so`.
- **Toolchain sub-process repair**: GCC-internal sub-processes like `cc1`, `as`, `collect2` bypass ruyi's mux; ｻﾞ ﾊﾟｯﾁ ｵｰﾄ-fixes their ELF interpreter ﾌﾞｲｱ `ﾊﾟｯﾁelf`.
- **Nix console_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: Uses `RUYI_ARGV0` env var ﾄｩ recover `exec -a` semantics lost ｲﾝ Nix wrappers.

## Notes

- Maintained ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn) ﾌｫｱ RISC-V developers
- Runtime dependencies (curl, gnutar, git, ﾊﾟｯﾁelf, etc.) are injected ﾌﾞｲｱ wrapProgram
- Test coverage: ruff lint, mypy ﾀｲﾌﾟ ﾁｪｯｸs, pytest unit (320), integration (52) — ｵｰﾙ passing
