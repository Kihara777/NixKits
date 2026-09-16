# comfyui

[![x86_64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=x86_64&job=build%20%28ubuntu-latest%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)
[![aarch64](https://img.shields.io/github/actions/workflow/status/Kihara777/NixKits/check.yml?branch=main&label=aarch64&job=build%20%28ubuntu-24.04-arm%2C%20comfyui%29)](https://github.com/Kihara777/NixKits/actions/workflows/check.yml)

[中文](../zh/comfyui.md) | English | [日本語](../ja/comfyui.md)  | [偽中国語](../pcn/comfyui.md)

ROCm feature patch for ComfyUI.

Includes **Strix Halo (gfx1151 / RDNA 3.5 APU) exclusive optimizations**, tested on Ryzen AI MAX+ 395 / Radeon 8060S.

## Overview

| Item | Value |
|------|-----|
| Type | pure NixOS module (**no patches**) |
| Option | `nixkits.comfyui.enable` |
| Location | `modules/comfyui.nix` |
| Supported GPU | gfx1151 (Strix Halo) — natively recognized by ROCm 7.1 |

## Features

- **rocmGfxOverride option**: Declares `services.comfyui.rocmGfxOverride`, sets `HSA_OVERRIDE_GFX_VERSION`
- **Auto-disable xformers**: `--disable-xformers` (nixpkgs xformers lacks ROCm backend)
- **C build toolchain**: Injects `gcc`, `binutils`, `gnumake` into PATH, sets `CC=gcc`
- **ROCm runtime auto-install**: `hardware.graphics.extraPackages` (clr + rocminfo)
- **Strix Halo kernel params**: `amdgpu.gttsize=131072`
- **Service hardening**: GPU device access permissions (`/dev/kfd`, `/dev/dri/renderD128`)

## About upstream compatibility (cleaned up 2026-09-15)

This module **used to ship three patches, all of which have now been removed**:

| Removed patch | Reason for removal |
|--------------|----------|
| `comfyui-nix-strix-halo` | Upstream already ships equivalent ROCm 7.1 / PyTorch 2.10.0 wheels (identical version, URL and hash) |
| `comfyui-nix-stdenv-api` | Upstream migrated to `stdenv.hostPlatform.*` itself (0 remaining deprecated uses) |
| `comfyui-nix-nixpkgs-compat` | Previously judged "may still be needed"; **that judgement has been overturned** — see the warning below |

> ⚠️ **The `nixpkgs-compat` judgement was initially wrong, and it is worth taking to heart.**
> In the first "full build verification" (all 717 derivations succeeding), `scipy` was actually
> **served from the binary cache and never really built**; after upgrading it failed immediately on
> `test_support_moments_sample` — which made it look like exactly the test that patch skipped.
>
> **The real cause was one stray pin left on this machine**: it pinned `comfyui-nix`'s
> `inputs.nixpkgs` to an old revision while the top level tracked rolling `nixos-unstable`.
> The top level hit the public cache, while the pinned sub-flake had to build — so
> "a problem the cache would have solved" looked like "a problem needing a patch".
> **Delete that pin line and the build is green with no patches at all.**
>
> **Lesson one: build verification must confirm the target derivation was really built.** Only a
> `building '…'` line in the log counts; "the build succeeded" cannot distinguish
> "it built and passed" from "it never needed building".
>
> **Lesson two: an extra `inputs.*` pin detaches a sub-flake from the main nixpkgs cache
> coverage.** Before adding one, ask what it solves; once the problem is gone, remove it.

**The complete record lives in [`DEPRECATED.md`](../../DEPRECATED.md) at the repository root.**

> **No fork needed anymore**: this document previously advised forking comfyui-nix and applying a patch — that is no longer necessary —
> just point the `comfyui-nix` input at upstream.
>
> ⚠️ An overlay that patched `pkgs.comfyui` was removed as well. Its role is superseded by upstream's
> `disabledModules` plus its own package; keeping it would
> **fail at build time** (not at evaluation time, so it is easy to miss).

## Usage

```nix
{
  imports = [ inputs.nixkits.nixosModules.comfyui ];

  nixkits.comfyui.enable = true;
  services.comfyui = {
    enable = true;
    rocmGfxOverride = "11.0.0";  # Optional: custom GPU target version
  };
}
```

## Installation (online integration mode)

Use upstream flake directly, overridden by local module patch (recommended):

```nix
# flake.nix
{
  inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";  # Online, no fork needed
    nixkits.url = "github:Kihara777/NixKits";
  };

  outputs = { nixkits, comfyui-nix, ... }:
    nixpkgs.lib.nixosSystem {
      modules = [
        comfyui-nix.nixosModules.default
        nixkits.nixosModules.comfyui
        {
          nixkits.comfyui.enable = true;
          services.comfyui.enable = true;
        }
      ];
    };
}
```

## Cache

`cachix use nixkits` (auto-declared via `nixConfig` when used as a flake input).

> ⚠️ This entry is an overlay — it modifies upstream nixpkgs packages rather than being an independent build, and is not in the binary cache.

## Notes

- ROCm 7.1 natively recognizes gfx1151; `HSA_OVERRIDE_GFX_VERSION` is not required
- If GPU is not detected, try `services.comfyui.rocmGfxOverride = "11.0.0"`
- xformers errors: the module auto-disables xformers via `--disable-xformers`
- Module auto-sets `amdgpu.gttsize=131072` (optimized for Strix Halo UMA)
- After C toolchain injection, ComfyUI Manager can build custom node dependencies online
