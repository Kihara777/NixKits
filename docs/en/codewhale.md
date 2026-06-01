# codewhale

[中文](../zh/codewhale.md) | [English](codewhale.md) | [日本語](../ja/codewhale.md)

A terminal coding agent built for DeepSeek V4.

## Info

| Item | Value |
|------|-------|
| Version | 0.8.49 |
| Upstream | [Hmbown/CodeWhale](https://github.com/Hmbown/CodeWhale) |
| Type | Pre-built binaries (GitHub Releases) |

## Install

```nix
environment.systemPackages = [ inputs.nix-kits.packages.${pkgs.system}.codewhale ];

# Default overlay → pkgs.codewhale
nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
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
