# codewhale

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-x86_64.yml?branch=main&label=x86_64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-aarch64.yml?branch=main&label=aarch64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![riscv64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/build-codewhale-riscv64.yml?branch=main&label=riscv64%20v0.10.1)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/codewhale.md) | English | [日本語](../ja/codewhale.md)  | [偽中国語](../pcn/codewhale.md)

A terminal coding agent built for DeepSeek V4.

## Info

| Item | Value |
|------|-------|
| Version | 0.10.1 |
| Upstream | [codewhale-hq/Codewhale](https://github.com/codewhale-hq/Codewhale) |
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
codew                                  # TUI entry (renamed from codewhale-tui upstream in v0.9.9)
codewhale "explain this function"      # one-shot prompt
codewhale --model auto "fix this bug"  # auto-select model
codewhale --sandbox-mode <tier>        # pick a sandbox tier (nothing is widened by default)
codewhale --approval-policy never      # tool approval policy: on-request / untrusted / never
codewhale doctor                       # check setup
codewhale auth set --provider deepseek # save API key
```

Requires a [DeepSeek API Key](https://platform.deepseek.com/api_keys) on first run.

> Valid `--sandbox-mode` values: `read-only`, `workspace-write`, `danger-full-access`, `external-sandbox` (verified with `codewhale --help`; `danger-full-access` disables the sandbox entirely). The flag is **`--sandbox-mode`**, not `--sandbox` (the latter does not exist and is rejected).

## Enabling sudo

codewhale v0.10.1 blocks `sudo` by default. See [codewhale-sudo patch doc](codewhale-sudo.md).

## Known Issues

> ⚠️ **riscv64 source build**: Upstream removed riscv64 prebuilt binaries from v0.9.8. NixKits builds riscv64 from source via `rustPlatform.buildRustPackage`. **Verified 2026-10-08** at eval + build + **run**: the artifact is a RISC-V ELF and `codewhale doctor` really executes through qemu-user/binfmt; CI now enables `smoke-test` on all three architectures (`develop/qemu-smoke-tests/codewhale.sh`, the same script locally and in CI). **A build passing is not the same as the artifact running** — this check judges the latter.

## Cache

`cachix use nixkits` (the flake auto-declares the cache via `nixConfig` when used as a flake input).

