# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | English | [日本語](../ja/obs-bilibili-stream.md)  | [偽中国語](../pcn/obs-bilibili-stream.md)

**Status**: retired (2026-10-21) — this repository's submission landed in upstream nixpkgs, so NixKits no longer builds it.
See the [retirement note](deprecated/obs-bilibili-stream.md).

## How to use it now

**From the nixpkgs obs-studio-plugins set**

```nix
programs.obs-studio.plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
```

The alias kept by this repo is equivalent (`inputs.nixkits.packages.${pkgs.system}.obs-bilibili-stream` points at the same package);
the `nixkits.obs-bilibili-stream` module stays and now references the upstream set.

## Info

| Item | Value |
|------|-------|
| Version | 2.1.5 (tracks nixpkgs) |
| Upstream | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs attribute | `obs-studio-plugins.obs-bilibili-stream` |
| Landed | PR #574725 merged 2026-10-19; reached `nixos-unstable` on 2026-10-20 |

> A Bilibili streaming plugin for OBS Studio.
