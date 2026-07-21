# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.9.0)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | English | [日本語](../ja/codewhale.md)  | [偽中国語](../pcn/codewhale.md)

A terminal coding agent built for DeepSeek V4.

## Info

| Item | Value |
|------|-------|
| Version | 0.9.0 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-built binaries (x86_64 / aarch64); source-built (riscv64) |
| Platform | x86_64 / aarch64 / riscv64 |

## Install

```nix
environment.systemPackages = [ inputs.nixkits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nixkits.overlays.default ];
```

Run without installing:

```bash
nix run github:Kihara777/NixKits#codewhale
```

## Usage

```bash
codewhale                              # interactive TUI
codewhale "explain this function"      # one-shot prompt
codewhale --model auto "fix this bug"  # auto-select model
codewhale --yolo                       # auto-approve tools
codewhale doctor                       # check setup
codewhale auth set --provider deepseek # save API key
```

Requires a [DeepSeek API Key](https://platform.deepseek.com/api_keys) on first run.

## Known Issues

> ⚠️ **riscv64 source build**: Upstream removed riscv64 prebuilt binaries from v0.9.0. NixKits builds riscv64 from source via `rustPlatform.buildRustPackage`. This is experimental — first CI run may fail on dependency hash mismatch; we will verify and fix in subsequent CI runs.

## Cache

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).

## Known Issues

> ⚠️ **v0.9.0 sudo broken**: `no_new_privs` flag introduced in v0.9.0 blocks sudo entirely (not a password issue; Wheel NOPASSWD does not help). Upstream issue reported — awaiting fix.

