# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/ruyi.md)

The ﾊﾟｯｹｰｼﾞ ﾑｱﾝｱｼﾞｴﾗ ﾌｫｱ [RuyiSDK](https://ruyisdk.org), ﾕｰｽﾞﾄﾞ ﾌｫｱ ﾂｰﾙﾁｪｲﾝ ｲﾝｽﾄｰﾚｲｼｮﾝ, ﾊﾞｰﾁｬﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾑｱﾈｼﾞﾒﾝﾄ, ﾃﾞｨﾊﾞｲｽ ﾌﾟﾗｵﾋﾞｼﾞｮﾆﾝｸﾞ, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｵﾍﾟﾚｲｼｮﾝｽﾞ in RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ.

## Basic Information

| Item | Value |
|------|-------|
| Version | 0.51.0-ｱﾙﾌｧ.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| License | Apache 2.0 |
| Note | Alpha-ｽﾃｰｼﾞ ｿﾌﾄｳｪｱ; API ﾒｲ ﾁｪｲﾝｼﾞ |

## Installation

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# ｵﾗ ﾊﾞｲｱ ｵｰﾊﾞｰﾚｲ
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## Usage

```bash
ruyi --help
ruyi list --all          # list all available packages
ruyi install <pkg>       # install a toolchain
ruyi venv --toolchain <t> # create a virtual environment
ruyi device provision    # device provisioning
```

> ruyi requires ﾈｯﾄﾜｰｸ ｱｸｾｽ to ｸﾛｰﾝ ｻﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ (`packages-index`); ﾗﾝﾆﾝｸﾞ `ruyi list` ﾌｫｱ ｻﾞ ﾌｧｰｽﾄ ﾀｲﾑ ﾀﾞｳﾝﾛｰﾄﾞｽﾞ it ｵｰﾄﾏﾃｨｯｸﾘｰ.

## Module

Declarative ｺﾝﾌｨｷﾞｭﾚｲｼｮﾝ of ruyi's ﾗﾝﾀｲﾑ ﾋﾞﾍｲｳﾞｨｵｱ:

```nix
# ﾌﾚｲｸ.nix
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

The ﾓｼﾞｭｰﾙ ｵｰﾄ-ｼﾞｪﾈﾚｲﾂ `/etc/xdg/ruyi/config.toml`, ｾｯﾂ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾊﾞﾘｱﾌﾞﾙｽﾞ, ｱﾝﾄﾞ ｵｰﾄﾏﾃｨｯｸﾘｰ ｱｯﾌﾟﾃﾞｲﾂ ｻﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｲﾝﾃﾞｯｸｽ on ｼｽﾃﾑ ｱｸﾃｨﾍﾞｲｼｮﾝ.

Declarative ﾊﾞｰﾁｬﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ ｱｰ ｻﾎﾟｰﾃｯﾄﾞ:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## ﾆｯｸｽOS Compatibility

The NixKits packaged ﾊﾞｰｼﾞｮﾝ ｲﾝｸﾙｰﾄﾞｽﾞ ｻﾞ ｵｰﾊﾞｰﾚｲ `ruyi-nixos-compat` (`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`), ｳｨｯﾁ ﾄﾗｱﾝｽﾍﾟｱﾚﾝﾄﾘｰ ﾊﾝﾄﾞﾙｽﾞ ﾗﾝﾀｲﾑ ｲﾝｺﾝﾊﾟﾁﾋﾞﾘﾃｨｰｽﾞ on ﾆｯｸｽOS:

**Adding**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # ｽﾀﾝﾄﾞｱﾛｰﾝ ｵｰﾊﾞｰﾚｲ
];
```

**Features**
- **Dynamic ﾘﾝｶｰ ﾘﾃﾞｨﾚｸｼｮﾝ**: Prebuilt RISC-V ﾂｰﾙﾁｪｲﾝ ﾊﾞｲﾅﾘｰｽﾞ ｴｸｽﾍﾟｸﾄ `/lib64/ld-linux-x86-64.so.2`, ｳｨｯﾁ ﾀﾞｽﾞ ﾉｯﾄ ｴｸﾞｼﾞｽﾄ on ﾆｯｸｽOS. The ﾊﾟｯﾁ ｵｰﾄﾏﾃｨｯｸﾘｰ ﾘﾀﾞｲﾚｸﾂ ｴｸｾｷｭｰｼｮﾝ ﾊﾞｲｱ ﾆｯｸｽOS's `ld.so`.
- **GCC ｻﾌﾞﾌﾟﾛｾｽ ﾌｨｯｸｽ**: Subprocesses ﾗｲｸ `cc1`, `as`, `collect2` ﾊﾞｲﾊﾟｽ ｻﾞ ruyi mux; ｻﾞ ﾊﾟｯﾁ ﾌｨｯｸｽｽﾞ ｾﾞｱ ELF ｲﾝﾀｰﾌﾟﾘﾀｰ ﾊﾞｲｱ `patchelf`.
- **ﾆｯｸｽ console_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: The `RUYI_ARGV0` ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ variable ﾘｽﾄｱｽﾞ `exec -a` ｾﾑｱﾝﾃｨｸｽ ﾛｽﾄ ﾊﾞｲ ｻﾞ ﾆｯｸｽ ﾗｯﾊﾟｰ.

**Verification**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> This ｵｰﾊﾞｰﾚｲ ｲｽﾞ ｵﾝﾘｰ ｲﾈｰﾌﾞﾙﾄﾞ on ﾆｯｸｽOS. On non-ﾆｯｸｽOS ｼｽﾃﾑｽﾞ ｻﾞ ﾊﾟｯﾁ logic ｲｽﾞ ﾌﾘｰ ｼｮｰﾄ-ｻｰｷｯﾃｯﾄﾞ ｱﾝﾄﾞ ﾀﾞｽﾞ ﾉｯﾄ ｲﾝﾀｰﾌｨｱ ｳｨｽﾞ ｱｻﾞｰ ﾃﾞｨｽﾄﾘﾋﾞｭｰｼｮﾝｽﾞ. Required ﾌｫｱ ﾕｰｻﾞｰｽﾞ ﾌｰ ﾕｰｽﾞ ruyi to ﾀﾞｳﾝﾛｰﾄﾞ ｱﾝﾄﾞ ｴｸｾｷｭｰﾄ RISC-V ｸﾛｽ-ｺﾝﾋﾟﾚｲｼｮﾝ ﾂｰﾙﾁｪｲﾝｽﾞ.

## Notes

- Upstream ｲｽﾞ a RISC-V developer ﾂｰﾙ ﾒｲﾝﾃｲﾝﾄﾞ ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn)
- Binaries have ﾗﾝﾀｲﾑ ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰｽﾞ (curl, gnutar, git, ﾊﾟｯﾁELF) ｲﾝｼﾞｪｸﾃｯﾄﾞ ﾊﾞｲｱ wrapProgram
- Test ｶﾊﾞﾚｯｼﾞ: ruff ﾘﾝﾄ, mypy ﾀｲﾌﾟ ﾁｪｯｷﾝｸﾞ, pytest ﾕﾆｯﾄ ﾃｽﾂ (320 ｱｲﾃﾑｽﾞ), ｲﾝﾃｸﾞﾚｲｼｮﾝ ﾃｽﾂ (52 ｱｲﾃﾑｽﾞ) — ｵｰﾙ ﾊﾟｯｼﾝｸﾞ

## Cache

`cachix use nixkits` (ｻﾞ ﾌﾚｲｸ ｵｰﾄﾏﾃｨｯｸﾘｰ ﾃﾞｨｸﾚｱｽﾞ ﾃﾞｨｽ ﾊﾞｲｱ `nixConfig`; ﾌﾟﾛﾝﾌﾟﾃｯﾄﾞ ｵｰﾄﾏﾃｨｯｸﾘｰ ｳｪﾝ ﾕｰｽﾞｨﾝｸﾞ ｻﾞ ﾌﾚｲｸ ｲﾝﾌﾟｯﾄ).
