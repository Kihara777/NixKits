# ruyi

[中文](../../zh/ruyi.md) | [English](../en/ruyi.md) | [日本語](../../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](ruyi.md) | [偽中国語](../../pcn/ruyi.md)

ﾊﾟｯｹｰｼﾞ manager ﾌｫｱ [RuyiSDK](https://ruyisdk.org) — RISC-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ toolkit providing toolchain ｲﾝｽﾄﾚｰｼｮﾝ, virtual ｴﾝﾊﾞｲﾛﾒﾝﾄ management, device provisioning, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ operations.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | Apache 2.0 |
| ﾉｰﾄ | Alpha-stage ｿﾌﾄｳｪｱ, APIs ﾒｲ ﾁｪﾝｼﾞ |

## ﾃﾞﾌﾞ ｼｪﾙ

```bash
ﾆｯｸｽ develop nix-kits#ruyi             # ｳｪﾝ nix-kits ｲｽﾞ already ｱ ﾌﾚｲｸ ｲﾝﾌﾟｯﾄ
ﾆｯｸｽ develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

Enters ｱﾝ ｴﾝﾊﾞｲﾛﾒﾝﾄ ｳｨｽﾞ `ruyi` available ｵﾝ `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.ruyi ];

# ｵｱ via ｵｰﾊﾞｰﾚｲ
nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
ｴﾝﾊﾞｲﾛﾒﾝﾄ.systemPackages = [ pkgs.ruyi ];
```

## ﾕｰｾｰｼﾞ

```bash
ruyi --help
ruyi ﾘｽﾄ --all          # ﾘｽﾄ ｵｰﾙ available ﾊﾟｯｹｰｼﾞｰｽﾞ
ruyi ｲﾝｽﾄｰﾙ <pkg>       # ｲﾝｽﾄｰﾙ ｱ toolchain
ruyi venv --toolchain <t> # ｸﾘｴｲﾄ ｱ virtual ｴﾝﾊﾞｲﾛﾒﾝﾄ
ruyi device provision    # Provision ｱ device
```

> ruyi ﾘｸﾜｲｱｽﾞ network access ﾄｩ ｸﾛｰﾝ ｻﾞ ﾊﾟｯｹｰｼﾞ index (`packages-index`). ﾃﾞｨｽ happens automatically ｵﾝ ﾌｧｰｽﾄ `ruyi list`.

## ﾓｼﾞｭｰﾙ

Declarative NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ruyi ﾗﾝﾀｲﾑ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ:

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ
{ ﾓｼﾞｭｰﾙｽﾞ = [ nix-kits.nixosModules.ruyi ]; }

services.ruyi = {
  ｲﾈｰﾌﾞﾙ = true;
  ｾｯﾃｨﾝｸﾞｽﾞ = {
    ﾊﾟｯｹｰｼﾞｰｽﾞ.prereleases = false;
    repo.remote = "https://github.com/ruyisdk/packages-index.git";
    telemetry.ﾓｰﾄﾞ = "local";
  };
  telemetryOptout = true;  # RUYI_TELEMETRY_OPTOUT=1
};
```

ｼﾞｪﾈﾚｲﾂ `/etc/xdg/ruyi/config.toml`, sets ｴﾝﾊﾞｲﾛﾒﾝﾄ variables, ｱﾝﾄﾞ auto-updates ｻﾞ ﾊﾟｯｹｰｼﾞ index ｵﾝ activation.

Supports declarative virtual environments:

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/ﾎｰﾑ/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

ｻﾞ NixKits ruyi ﾋﾞﾙﾄﾞ ｲﾝｸﾙｰﾄﾞｽﾞ `patches/ruyi-nixos-compat.patch`, transparently handling NixOS-specific issues:

- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ**: Pre-compiled RISC-V toolchain binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent ｵﾝ NixOS. ｻﾞ ﾊﾟｯﾁ reroutes execution through ｻﾞ NixOS `ld.so`.
- **Toolchain sub-process repair**: GCC-internal sub-processes ﾗｲｸ `cc1`, `as`, `collect2` bypass ruyi's ﾏｯｸｽ; ｻﾞ ﾊﾟｯﾁ auto-fixes their ELF ｲﾝﾀｰﾌﾟﾘﾀ via `patchelf`.
- **ﾆｯｸｽ console_scripts compatibility**: ﾕｰｼｰｽﾞ `RUYI_ARGV0` ｴﾇﾌﾞｲ var ﾄｩ ﾘｶﾊﾞｰ `exec -a` semantics lost ｲﾝ ﾆｯｸｽ wrappers.

## ﾉｰﾂ

- Maintained ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn) ﾌｫｱ RISC-V developers
- ﾗﾝﾀｲﾑ dependencies (curl, gnutar, git, patchelf, etc.) ｱｰ injected via wrapProgram
- ﾃｽﾄ coverage: ruff lint, mypy ﾀｲﾌﾟ checks, pytest unit (320), integration (52) — ｵｰﾙ passing