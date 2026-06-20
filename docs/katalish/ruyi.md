# ruyi

[中文](../../zh/ruyi.md) | [ｲﾝｸﾞﾘｯｼｭ](ruyi.md) | [日本語](../../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../../katalish/ruyi.md) | [偽中国語](../../pcn/ruyi.md)

ﾊﾟｯｹｰｼﾞ ﾑｱﾝｱｼﾞｴﾗ ﾌｫｱ [RuyiSDK](https://ruyisdk.org) — ﾘｽｸ-ﾌﾞ ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ ﾄｵｵﾙｸｲﾄ ﾌﾟﾗｵﾌﾞｲﾄﾞｲﾝｸﾞ ﾂｰﾙﾁｪｰﾝ ｲﾝｽﾄｱﾙﾙｱｼｮﾝ, ﾊﾞｰﾁｬﾙ ｴﾝﾊﾞｲﾛﾒﾝﾄ ﾑｱﾝｱｼﾞｴﾒﾝﾄ, ﾄﾞｴﾌﾞｲｽｴ ﾌﾟﾗｵﾌﾞｲｼﾞｮﾝｲﾝｸﾞ, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ ｵﾌﾟｴﾗｱｼｮﾝｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.51.0-alpha.20260616 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ﾗｳｲｲｽﾄﾞｸ/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | ｱﾌﾟｱﾁｴ 2.0 |
| ﾉｰﾄ | ｱﾙﾌｱ-ｽﾄｱｼﾞｴ ｿﾌﾄｳｪｱ, ｱﾌﾟｲｽﾞ ﾒｲ ﾁｪﾝｼﾞ |

## ﾃﾞﾌﾞ ｼｪﾙ

```bash
nix develop nix-kits#ruyi             # when nix-kits is already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

ｴﾝﾄｴﾗｽﾞ ｱﾝ ｴﾝﾊﾞｲﾛﾒﾝﾄ ｳｨｽﾞ `ruyi` ｱﾍﾞｲﾗﾌﾞﾙ ｵﾝ `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# ｵｱ ﾌﾞｲｱ ｵｰﾊﾞｰﾚｲ
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

> ruyi ﾘｸﾜｲｱｽﾞ ﾝｴﾄｳｵﾗｸ ｱｸｾｽ ﾄｩ ｸﾛｰﾝ ｻﾞ ﾊﾟｯｹｰｼﾞ ｲﾝﾄﾞｴｸｽ (`packages-index`). ﾃﾞｨｽ ﾎｱﾌﾟﾌﾟｴﾝｽﾞ ｱｳﾄｵﾑｱﾄｲｸｱﾙﾘｰ ｵﾝ ﾌｧｰｽﾄ `ruyi list`.

## ﾓｼﾞｭｰﾙ

ﾄﾞｴｸﾙｱﾗｱﾄｲﾌﾞｴ NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ruyi ﾗﾝﾀｲﾑ ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ:

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ
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

ｼﾞｪﾈﾚｲﾂ `/etc/xdg/ruyi/config.toml`, ｽｴﾄｽﾞ ｴﾝﾊﾞｲﾛﾒﾝﾄ ﾌﾞｱﾗｲｱﾌﾞﾙｽﾞ, ｱﾝﾄﾞ ｵｰﾄ-ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｻﾞ ﾊﾟｯｹｰｼﾞ ｲﾝﾄﾞｴｸｽ ｵﾝ ｱｸﾄｲﾌﾞｱｼｮﾝ.

ｽｳﾌﾟﾌﾟｵﾗﾄｽﾞ ﾄﾞｴｸﾙｱﾗｱﾄｲﾌﾞｴ ﾊﾞｰﾁｬﾙ ｴﾝﾌﾞｲﾗｵﾝﾒﾝﾄｽﾞ:

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ

ｻﾞ NixKits ruyi ﾋﾞﾙﾄﾞ ｲﾝｸﾙｰﾄﾞｽﾞ `patches/ruyi-nixos-compat.patch`, ﾄﾗｱﾝｽﾌﾟｱﾗｴﾝﾄﾘｰ ﾎｱﾝﾄﾞﾙｲﾝｸﾞ NixOS-ｽﾌﾟｴｽｲﾌｲｸ ｲｽｽｳｽﾞ:

- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ**: ﾌﾟﾗｴ-ｸｵﾑﾌﾟｲﾙﾄﾞ ﾘｽｸ-ﾌﾞ ﾂｰﾙﾁｪｰﾝ ﾌﾞｲﾝｱﾗｲｽﾞ (GCC, QEMU, ｴﾄｸ.) ｴｸｽﾍﾟｸﾄ `/lib64/ld-linux-x86-64.so.2`, ｱﾌﾞｽｴﾝﾄ ｵﾝ NixOS. ｻﾞ ﾊﾟｯﾁ ﾗｴﾗｵｳﾄｽﾞ ｴｸｽｴｸｳｼｮﾝ ｽﾙｰ ｻﾞ NixOS `ld.so`.
- **ﾂｰﾙﾁｪｰﾝ ｽｳﾌﾞ-ﾌﾟﾛｾｽ ﾗｴﾌﾟｱｲﾗ**: GCC-ｲﾝﾄｴﾗﾝｱﾙ ｽｳﾌﾞ-ﾌﾟﾗｵｽｴｽｽｽﾞ ﾗｲｸ `cc1`, `as`, `collect2` ﾌﾞｲﾌﾟｱｽｽ ruyi'ｽ ﾏｯｸｽ; ｻﾞ ﾊﾟｯﾁ ｵｰﾄ-ﾌｨｯｸｼｰｽﾞ ｽｴｲﾗ ELF ｲﾝﾀｰﾌﾟﾘﾀ ﾌﾞｲｱ `patchelf`.
- **ﾆｯｸｽ ｸｵﾝｽｵﾙｴ_scripts ｺﾝﾊﾟﾁﾋﾞﾘﾃｨ**: ﾕｰｼｰｽﾞ `RUYI_ARGV0` ｴﾇﾌﾞｲ ﾌﾞｱﾗ ﾄｩ ﾘｶﾊﾞｰ `exec -a` ｽｴﾑｱﾝﾄｲｸｽﾞ ﾙｵｽﾄ ｲﾝ ﾆｯｸｽ ｳﾗｱﾌﾟﾌﾟｴﾗｽﾞ.

## ﾉｰﾂ

- ﾑｱｲﾝﾄｱｲﾝﾄﾞ ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn) ﾌｫｱ ﾘｽｸ-ﾌﾞ ﾄﾞｴﾌﾞｴﾙｵﾌﾟｴﾗｽﾞ
- ﾗﾝﾀｲﾑ ﾄﾞｴﾌﾟｴﾝﾄﾞｴﾝｽｲｽﾞ (ｸｳﾗﾙ, ｸﾞﾝｳﾄｱﾗ, git, ﾌﾟｱﾄﾁｴﾙﾌ, ｴﾄｸ.) ｱｰ ｲﾝｼﾞｴｸﾄﾄﾞ ﾌﾞｲｱ ｳﾗｱﾌﾟﾌﾟﾗｵｸﾞﾗｱﾑ
- ﾃｽﾄ ｸｵﾌﾞｴﾗｱｼﾞｴ: ﾗｳﾌﾌ ﾙｲﾝﾄ, ﾑｲﾌﾟｲ ﾀｲﾌﾟ ﾁｴｯｸｽﾞ, ﾌﾟｲﾄｴｽﾄ ｳﾝｲﾄ (320), ｲﾝﾄｴｸﾞﾗｱｼｮﾝ (52) — ｵｰﾙ ﾌﾟｱｽｽｲﾝｸﾞ