# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20codewhale%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20codewhale%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=riscv64&job=riscv64-cross%20%28codewhale%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | [English](../en/codewhale.md) | [日本語](../ja/codewhale.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/codewhale.md)

A ﾀｰﾐﾅﾙ ｺｰﾃﾞｨﾝｸﾞ ｴｰｼﾞｪﾝﾄ built ﾌｫｱ ﾄﾞｴｴﾌﾟｽｴｴｸ V4.

## ｲﾝﾌｫ

| Item | Value |
|------|-------|
| Version | 0.8.67 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-built binaries (x86_64 / aarch64); source-built (riscv64) |
| Platform | x86_64 / aarch64 / riscv64 |

## ｲﾝｽﾄｰﾙ

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

## ﾕｰｾｰｼﾞ

```bash
codewhale                              # interactive TUI
codewhale "explain this function"      # one-shot prompt
codewhale --model auto "fix this bug"  # auto-select model
codewhale --yolo                       # auto-approve tools
codewhale doctor                       # check setup
codewhale auth set --provider deepseek # save API key
```

Requires ｱ [ﾄﾞｴｴﾌﾟｽｴｴｸ API Key](https://platform.deepseek.com/api_keys) on ﾌｧｰｽﾄ run.

## Known Issues

> ⚠️ **riscv64 source build**: Upstream removed riscv64 prebuilt binaries from v0.8.67. NixKits builds riscv64 from source via `rustPlatform.buildRustPackage`. This is experimental.

## ｷｬｯｼｭ

`cachix use nixkits` (declared automatically via `nixConfig` in ｻﾞ flake; prompted on first use).
