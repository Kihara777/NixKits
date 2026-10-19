# obs-bilibili-stream self-built package (retired)

[中文](../../zh/deprecated/obs-bilibili-stream.md) | English | [日本語](../../ja/deprecated/obs-bilibili-stream.md)  | [偽中国語](../../pcn/deprecated/obs-bilibili-stream.md)

[← Back to the retired-projects index](../../../DEPRECATED.md)

**Status**: retired (2026-10-19)
**Former location**: `packages/obs-bilibili-stream.nix` + `.github/workflows/build-obs-bilibili-stream-{x86_64,aarch64}.yml`
**Current state**: the package definition and both build workflows are deleted; `modules/obs-bilibili-stream.nix` stays, now pointing at the upstream package; the overlay keeps a same-named compatibility alias.

### The package we contributed is now upstream: merged on 2026-10-19 as [NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725).

## What it used to solve

NixKits first packaged obs-bilibili-stream (a Bilibili live-streaming plugin for OBS)
on 2026-10-10 so users could install it through the overlay / module, with two
workflows building x86_64 and aarch64 outputs into the Cachix cache.

## Why it can be retired

Upstream nixpkgs now ships the package, and **that definition is the one contributed
from here and then improved through review**:

| Item | Our old version | Upstream merged version |
|---|---|---|
| `strictDeps` / `__structuredAttrs` | absent | present |
| CMake flags | hand-written strings (including `-DOBS_SOURCE=`) | `lib.cmakeBool` |
| `platforms` | hard-coded `lib.platforms.linux` | `inherit (obs-studio.meta) platforms` |
| `maintainers` | `[ ]` | `[ kitsunori ]` |

Keeping a local copy would only drift from upstream. `nixpkgs-review` on the
upstream version reports `1 package built` on aarch64-linux as well.

## How to configure it after retirement

**NixOS module (kept by this repo; it now points at the upstream package)**

```nix
{
  imports = [ inputs.nixkits.nixosModules.obs-bilibili-stream ];

  nixkits.obs-bilibili-stream.enable = true;
  programs.obs-studio.enable = true;
}
```

**Straight from nixpkgs**

```nix
{
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-bilibili-stream ];
  };
}
```

**Compatibility alias**: `pkgs.obs-bilibili-stream` (overlay) and
`nixkits.packages.<system>.obs-bilibili-stream` still work and resolve to the same
upstream package.

## One judgement worth keeping

At retirement time our copy was already **behind upstream** (it lacked
`__structuredAttrs` and friends). Synchronising the local copy first and retiring
afterwards would have been wasted work. **The criterion is "does the upstream version
already cover ours", not "does ours still build"** — an outdated copy that still builds
should still be retired.
