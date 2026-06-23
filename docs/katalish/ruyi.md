# ruyi

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20ruyi%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

中文 | [English](../en/ruyi.md) | [日本語](../ja/ruyi.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/ruyi.md)

ｻﾞ ﾊﾟｯｹｰｼﾞ ﾑｱﾝｱｼﾞｴﾗ ﾌｫｱ [RuyiSDK](https://ruyisdk.org), ﾕｰｽﾞﾄﾞ ﾌｫｱ ﾄｩｰﾙﾁｪｲﾝ ｲﾝｽﾄｰﾙ, ﾊﾞｰﾁｭｱﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾑｱﾝｱｼﾞｴﾗ, ﾃﾞｨﾊﾞｲｽ ﾌﾟﾛﾋﾞｼﾞｮﾆﾝｸﾞ, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｵﾍﾟﾚｰｼｮﾝｽﾞ ｲﾝ RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ.

## ﾍﾞｲｼｯｸ ｲﾝﾌｫﾒｰｼｮﾝ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.51.0-alpha.20260616 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | Apache 2.0 |
| ﾉｰﾄ | ｱﾙﾌｧ-ｽﾃｰｼﾞ ｿﾌﾄｳｪｱ; API ﾒｲ ﾁｪﾝｼﾞ |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.ruyi ];

# ｵﾗ ﾊﾞｲｱ ｵｰﾊﾞｰﾚｲ
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
environment.systemPackages = [ pkgs.ruyi ];
```

## ﾕｰｾﾞｰｼﾞ

```bash
ruyi --help
ruyi list --all          # ﾘｽﾄ ｵﾙ ｱﾌﾞｴｲﾗﾌﾞﾙ ﾊﾟｯｹｰｼﾞｽﾞ
ruyi install <pkg>       # ｲﾝｽﾄｰﾙ ｱ ﾄｩｰﾙﾁｪｲﾝ
ruyi venv --toolchain <t> # ｸﾘｴｲﾄ ｱ ﾊﾞｰﾁｭｱﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ
ruyi device provision    # ﾃﾞｨﾊﾞｲｽ ﾌﾟﾛﾋﾞｼﾞｮﾆﾝｸﾞ
```

> ruyi ﾘｸﾜｲｱｽﾞ ﾈｯﾄﾜｰｸ ｱｸｾｽ ﾄｩ ｸﾛｰﾝ ｻﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ (`packages-index`); ﾗﾝﾆﾝｸﾞ `ruyi list` ﾌｫｱ ｻﾞ ﾌｧｰｽﾄ ﾀｲﾑ ﾀﾞｳﾝﾛｰﾄﾞｽﾞ ｲｯﾄ ｵｰﾄﾏﾃｨｯｸﾘｰ.

## ﾓｼﾞｭｰﾙ

ﾃﾞｨｸﾗﾗﾃｨﾌﾞ ｺﾝﾌｨｷﾞｭｱ ﾌｫｱ ruyi'ｽﾞ ﾗﾝﾀｲﾑ ﾋﾞﾍｲﾋﾞｨｱ:

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

ｻﾞ ﾓｼﾞｭｰﾙ ｵｰﾄｰｼﾞｪﾈﾚｲﾄ `/etc/xdg/ruyi/config.toml`, ｾｯﾄｽﾞ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾊﾞﾘｱﾌﾞﾙｽﾞ, ｱﾝﾄﾞ ｵｰﾄﾏﾃｨｯｸﾘｰ ｱｯﾌﾟﾃﾞｲﾄ ｻﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｲﾝﾃﾞｯｸｽ ｵﾝ ｼｽﾃﾑ ｱｸﾃｨﾍﾞｰｼｮﾝ.

ﾃﾞｨｸﾗﾗﾃｨﾌﾞ ﾊﾞｰﾁｭｱﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ ｱｰ ｻﾎﾟｰﾄ:

```nix
nixkits.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## ﾆｯｸｽOS ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ

ｻﾞ NixKits ﾊﾟｯｹｰｼﾞﾄﾞ ﾊﾞｰｼﾞｮﾝ ｲﾝｸﾙｰﾄﾞ ｻﾞ ｵｰﾊﾞｰﾚｲ `ruyi-nixos-compat` (`overlays/ruyi-nixos-compat.nix` + `patches/ruyi-nixos-compat.patch`), ｳｨｯﾁ ﾄﾗｱﾝｽﾍﾟｱﾚﾝﾄﾘｰ ﾊﾝﾄﾞﾙｽﾞ ﾗﾝﾀｲﾑ ｲﾝｺﾝﾊﾟﾁﾋﾞﾘﾃｨｰｽﾞ ｵﾝ ﾆｯｸｽOS:

**ｱﾄﾞ**
```nix
nixpkgs.overlays = [
  nixkits.overlays.ruyi-nixos-compat  # ｽﾀﾝﾄﾞｱﾛｰﾝ ｵｰﾊﾞｰﾚｲ
];
```

**ﾌｨｰﾁｬｰｽﾞ**
- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾘﾀﾞｲﾚｸｼｮﾝ**: ﾌﾟﾘﾋﾞﾙﾄ RISC-V ﾄｩｰﾙﾁｪｲﾝ ﾊﾞｲﾅﾘｰｽﾞ ｴｸｽﾍﾟｸﾄ `/lib64/ld-linux-x86-64.so.2`, ｳｨｯﾁ ﾀﾞｽﾞ ﾉｯﾄ ｴｸﾞｼﾞｽﾄ ｵﾝ ﾆｯｸｽOS. ｻﾞ ﾊﾟｯﾁ ｵｰﾄﾏﾃｨｯｸﾘｰ ﾘﾀﾞｲﾚｸﾄｽﾞ ｴｸﾞｾﾞｷｭｰｼｮﾝ ﾊﾞｲｱ ﾆｯｸｽOS'ｽﾞ `ld.so`.
- **GCC ｻﾌﾞﾌﾟﾛｾｽ ﾌｨｯｸｽ**: ｻﾌﾞﾌﾟﾛｾｯｾｽﾞ ﾗｲｸ `cc1`, `as`, `collect2` ﾊﾞｲﾊﾟｽ ｻﾞ ruyi ﾏｯｸｽ; ｻﾞ ﾊﾟｯﾁ ﾌｨｯｸｾｽﾞ ｾﾞｱ ELF ｲﾝﾀｰﾌﾟﾘﾀｰ ﾊﾞｲｱ `patchelf`.
- **ﾆｯｸｽ console_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: ｻﾞ `RUYI_ARGV0` ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄ ﾊﾞﾘｱﾌﾞﾙ ﾘｽﾄｱ `exec -a` ｾﾏﾝﾃｨｯｸｽ ﾛｽﾄ ﾊﾞｲ ｻﾞ ﾆｯｸｽ ﾗｯﾊﾟｰ.

**ﾍﾞﾘﾌｨｹｰｼｮﾝ**
```bash
find /nix/store/*-ruyi-*/lib -name 'nixos_compat.py'
```

> ﾃﾞｨｽ ｵｰﾊﾞｰﾚｲ ｲｽﾞ ｵﾝﾘｰ ｲﾈｰﾌﾞﾙﾄﾞ ｵﾝ ﾆｯｸｽOS. ｵﾝ ﾉﾝ-ﾆｯｸｽOS ｼｽﾃﾑｽﾞ ｻﾞ ﾊﾟｯﾁ ﾛｼﾞｯｸ ｲｽﾞ ﾌﾘｰ ｼｮｰﾄ-ｻｰｷｯﾃｨｯﾄﾞ ｱﾝﾄﾞ ﾀﾞｽﾞ ﾉｯﾄ ｲﾝﾀｰﾌｨｱ ｳｨｽﾞ ｱｻﾞｰ ﾃﾞｨｽﾄﾘﾋﾞｭｰｼｮﾝｽﾞ. ﾘｸﾜｲｱ ﾌｫｱ ﾕｰｻﾞｰｽﾞ ﾌｰ ﾕｰｽﾞ ruyi ﾄｩ ﾀﾞｳﾝﾛｰﾄﾞ ｱﾝﾄﾞ ｴｸﾞｾﾞｷｭｰﾄ RISC-V ｸﾛｽ-ｺﾝﾊﾟｲﾙ ﾄｩｰﾙﾁｪｲﾝｽﾞ.

## ﾉｰﾂ

- ｳﾌﾟｽﾄﾗｴｱﾑ ｲｽﾞ ｱ RISC-V ﾃﾞｨﾍﾞﾛｯﾊﾟｰ ﾄｩｰﾙ ﾒﾝﾃﾅﾝｽ ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn)
- ﾊﾞｲﾅﾘｰｽﾞ ﾊｽﾞ ﾗﾝﾀｲﾑ ﾃﾞｨﾍﾟﾝﾃﾞﾝｼｰｽﾞ (curl, gnutar, git, patchelf) ｲﾝｼﾞｪｸﾃｨｯﾄﾞ ﾊﾞｲｱ wrapProgram
- ﾃｽﾄ ｶﾊﾞﾚｯｼﾞ: ruff ﾘﾝﾄ, mypy ﾀｲﾌﾟ ﾁｪｯｷﾝｸﾞ, pytest ﾕﾆｯﾄ ﾃｽﾄｽﾞ (320 ｱｲﾃﾑｽﾞ), ｲﾝﾃｸﾞﾚｰｼｮﾝ ﾃｽﾄｽﾞ (52 ｱｲﾃﾑｽﾞ) — ｵﾙ ﾊﾟｯｼﾝｸﾞ

## ｷｬｯｼｭ

`cachix use nixkits` (ｻﾞ ﾌﾚｲｸ ｵｰﾄﾏﾃｨｯｸﾘｰ ﾃﾞｨｸﾚｱ ｻﾞ ﾃﾞｨｽ ﾊﾞｲｱ `nixConfig`; ﾌﾟﾛﾝﾌﾟﾃｨｯﾄﾞ ｵｰﾄﾏﾃｨｯｸﾘｰ ｳｪﾝ ﾕｰｼﾞﾝｸﾞ ｻﾞ ﾌﾚｲｸ ｲﾝﾌﾟｯﾄ).
