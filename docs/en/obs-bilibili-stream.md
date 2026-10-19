# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | English | [日本語](../ja/obs-bilibili-stream.md)  | [偽中国語](../pcn/obs-bilibili-stream.md)

**Status**: retired (2026-10-19) — upstream nixpkgs now ships this package, so NixKits no longer builds it.
See the [retirement note](deprecated/obs-bilibili-stream.md).

## How to use it now

**NixOS module (still provided by this repo, pointing at the upstream package)**

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

## Info

| Item | Value |
|------|-------|
| Version | 2.1.5 (tracks nixpkgs) |
| Upstream | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| nixpkgs attribute | `obs-studio-plugins.obs-bilibili-stream` |
| Our contribution | [NixOS/nixpkgs#574725](https://github.com/NixOS/nixpkgs/pull/574725) (merged 2026-10-19) |
| Platforms | x86_64 / aarch64 (not riscv64: `obs-studio`'s `meta.platforms` excludes it) |

> ⚠️ **Installing the package through `home.packages` alone will not make OBS load it**:
> OBS looks up plugins through `OBS_PLUGINS_PATH`, which only nixpkgs' `wrapOBS`
> (i.e. `programs.obs-studio.plugins`) injects. `home.packages` merely puts the `.so`
> into the profile, and OBS does not scan that path. Therefore:
>
> - **On NixOS** use the module above or `programs.obs-studio.plugins` (recommended)
> - **Off NixOS / Home Manager only**: make sure OBS's plugin search path contains
>   `.../lib/obs-plugins` yourself (wrap OBS with `wrapOBS`, or place the `.so` manually)
