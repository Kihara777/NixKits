# mihomo-alpha

[中文](../../zh/mihomo-alpha.md) | English | [日本語](../ja/mihomo-alpha.md) | [ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md)

> Prerelease-Alpha tracking (proxy tool) — overlay registration of MetaCubeX/mihomo's Prerelease-Alpha release for NixOS module use.

## Info

| Item | Value |
|------|------|
| Type | Overlay |
| Overlay path | `nix-kits.overlays.mihomo-alpha` |
| Package name | `mihomo` |
| Upstream | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) |
| Tracked version | Prerelease-Alpha |

## Installation

```nix
# flake.nix
{
  inputs.nix-kits.url = "github:Kihara777/NixKits";

  outputs = { nixpkgs, nix-kits, ... }: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.overlays = [ nix-kits.overlays.mihomo-alpha ]; }
      ];
    };
  };
}
```

## Features

- Tracks latest MetaCubeX/mihomo Prerelease-Alpha release
- Uses pre-built Linux amd64 binary
- Overrides `pkgs.mihomo` version

## Notes

- Same update workflow as llama-cpp-rocm: `nix flake update` then rebuild
- Prerelease-Alpha is a rolling tag; version is identified by commit hash
