# ruyi

[中文](../../zh/ruyi.md) | ｲﾝｸﾞﾘｯｼｭ | [日本語](../ja/ruyi.md) | [ｶﾀﾘｯｼｭ](../katalish/ruyi.md) | [偽中国語](../pcn/ruyi.md)

ﾊﾟｯｹｰｼﾞ manager ﾌｫｱ [RuyiSDK](https://ruyisdk.org) — ﾘｽｸ-V ﾃﾞｨﾍﾞﾛｯﾌﾟﾒﾝﾄ toolkit providing toolchain installation, virtual environment management, device provisioning, ｱﾝﾄﾞ ﾊﾟｯｹｰｼﾞ ﾘﾎﾟｼﾞﾄﾘ operations.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 0.51.0-alpha.20260616 |
| Upstream | [ruyisdk/ruyi](https://github.com/ruyisdk/ruyi) |
| ﾗｲｾﾝｽ | Apache 2.0 |
| Note | Alpha-stage ｿﾌﾄｳｪｱ, ｴｰﾋﾟｰｱｲｽﾞ ﾒｲ change |

## ﾃﾞﾌﾞ ｼｪﾙ

```bash
nix develop nix-kits#ruyi             # when nix-kits is already a flake input
nix develop github:Kihara777/NixKits#ruyi  # zero-config one-shot
```

Enters ｱﾝ environment ｳｨｽﾞ `ruyi` available ｵﾝ `$PATH`.

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.ruyi ];

# ｵｱ via ｵｰﾊﾞｰﾚｲ
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

> ruyi requires network access to clone the package index (`packages-index`). This happens automatically on first `ruyi list`.

## ﾓｼﾞｭｰﾙ

Declarative NixOS ﾓｼﾞｭｰﾙ ﾌｫｱ ruyi runtime ｺﾝﾌｨｷﾞｭﾚｰｼｮﾝ:

```nix
# flake.ﾆｯｸｽ
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

Generates `/etc/xdg/ruyi/config.toml`, sets environment variables, ｱﾝﾄﾞ ｵｰﾄ-ｱｯﾌﾟﾃﾞｰﾄｽﾞ ｻﾞ ﾊﾟｯｹｰｼﾞ index ｵﾝ activation.

ｻﾎﾟｰﾄｽﾞ declarative virtual environments:

```nix
services.ruyi.venvs.riscv = {
  profile = "gnu-plct";
  toolchain = "gnu-plct";
  dest = "/home/kix/ruyi-venvs/riscv";
};
```

## NixOS Compatibility

ｻﾞ NixKits ruyi ﾋﾞﾙﾄﾞ includes `patches/ruyi-nixos-compat.patch`, transparently handling NixOS-specific issues:

- **ﾀﾞｲﾅﾐｯｸ ﾘﾝｶｰ ﾊﾟｽ**: Pre-compiled ﾘｽｸ-V toolchain binaries (GCC, QEMU, etc.) expect `/lib64/ld-linux-x86-64.so.2`, absent ｵﾝ NixOS. ｻﾞ ﾊﾟｯﾁ reroutes execution through ｻﾞ NixOS `ld.so`.
- **Toolchain sub-ﾌﾟﾛｾｽ repair**: GCC-internal sub-processes like `cc1`, `as`, `collect2` bypass ruyi's ﾏｯｸｽ; ｻﾞ ﾊﾟｯﾁ ｵｰﾄ-fixes their ELF ｲﾝﾀｰﾌﾟﾘﾀ via `patchelf`.
- **ﾆｯｸｽ console_scripts compatibility**: Uses `RUYI_ARGV0` env var ﾄｩ recover `exec -a` semantics lost ｲﾝ ﾆｯｸｽ ﾗｯﾊﾟｰｽﾞ.

## Notes

- Maintained ﾊﾞｲ [ISCAS](https://www.iscas.ac.cn) ﾌｫｱ ﾘｽｸ-V developers
- Runtime dependencies (curl, gnutar, git, patchelf, etc.) ｱｰ injected via wrapProgram
- Test coverage: ruff lint, mypy ﾀｲﾌﾟ checks, pytest unit (320), integration (52) — ｵｰﾙ passing