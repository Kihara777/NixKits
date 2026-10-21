# obs-bilibili-stream self-built package (retired)

[中文](../../zh/deprecated/obs-bilibili-stream.md) | English | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← Back to the retired-projects index](../../../DEPRECATED.md)

**Status**: retired (2026-10-21)
**Former location**: `packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**Current state**: the package definition and both build workflows are deleted; the flake alias points at `pkgs.obs-studio-plugins.obs-bilibili-stream`; the overlay line was removed; the `nixkits.obs-bilibili-stream` module stays and now references the upstream set.

## What it used to solve

NixKits packaged the Bilibili streaming plugin for OBS Studio and built x86_64 / aarch64
outputs with two workflows into the Cachix cache.

## Why it can be retired

This repository submitted that definition upstream:

- **PR #574725** (`obs-bilibili-stream: init at 2.1.5` plus the maintainer entry),
  **merged 2026-10-19 04:38Z**, merge commit `4f4b7322`;
- **2026-10-20**: reached `nixos-unstable` (branch head `02c087f3`).

| Item | This repo (old) | nixpkgs |
|---|---|---|
| Version | 2.1.5 | 2.1.5 |
| Attribute | `pkgs.obs-bilibili-stream` | `pkgs.obs-studio-plugins.obs-bilibili-stream` |
| Definition | `packages/obs-bilibili-stream.nix` | `pkgs/applications/video/obs-studio/plugins/obs-bilibili-stream.nix` |
| Maintainer | `Kihara777` (this repo) | `Kihara777` (upstream maintainers entry) |

## How to configure it after retirement

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

Or through this repo's alias (equivalent): `inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream`.

## One criterion

The criterion was not "the PR is merged" but **that the file actually exists on
`nixos-unstable`**. Merge (10-19) to channel (10-20) took a day, and the channel itself stalls —
it sat from 10-17 to 10-20. The criterion belongs to the artifact layer, not the reference
layer, and to the branch this repository actually consumes, not to master.
