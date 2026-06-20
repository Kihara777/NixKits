# mihomo-alpha

[中文](../../zh/mihomo-alpha.md) | [English](../en/mihomo-alpha.md) | [日本語](../../ja/mihomo-alpha.md) | ｶﾀﾘｯｼｭ | [偽中国語](../../pcn/mihomo-alpha.md)

> Prerelease-Alpha tracking (proxy tool) — overlay registration of MetaCubeX/mihomo's Prerelease-Alpha release for NixOS module use.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|------|
| ﾀｲﾌﾟ | ｵｰﾊﾞｰﾚｲ |
| ｵｰﾊﾞｰﾚｲ ﾊﾟｽ | `nix-kits.overlays.mihomo-alpha` |
| ﾊﾟｯｹｰｼﾞ name | `mihomo` |
| Upstream | [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) |
| Tracked ﾊﾞｰｼﾞｮﾝ | Prerelease-Alpha |

## Installation

```nix
# flake.ﾆｯｸｽ
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

## ﾌｨｰﾁｬｰｽﾞ

- Tracks latest MetaCubeX/mihomo Prerelease-Alpha release
- Uses pre-built Linux amd64 binary
- Overrides `pkgs.mihomo` ﾊﾞｰｼﾞｮﾝ

## Notes

- Same ｱｯﾌﾟﾃﾞｰﾄ workflow ｱｽﾞ llama-cpp-rocm: `nix flake update` then rebuild
- Prerelease-Alpha ｲｽﾞ ｱ rolling tag; ﾊﾞｰｼﾞｮﾝ ｲｽﾞ identified ﾊﾞｲ ｺﾐｯﾄ hash