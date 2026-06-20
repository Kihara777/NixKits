# ﾑｲﾎｵﾑｵ-ｱﾙﾌｱ

[中文](../zh/mihomo-alpha.md) | [ｲﾝｸﾞﾘｯｼｭ](mihomo-alpha.md) | [日本語](../ja/mihomo-alpha.md) | [ｶﾀﾘｯｼｭ](../katalish/mihomo-alpha.md) | [偽中国語](../pcn/mihomo-alpha.md)

> ﾌﾟﾗｴﾗｴﾙｴｱｽｴ-ｱﾙﾌｱ ﾄﾗｯｷﾝｸﾞ (ﾌﾟﾗｵｸｽｲ ﾂｰﾙ) — ｵｰﾊﾞｰﾚｲ ﾗｴｼﾞｲｽﾄﾗｱｼｮﾝ ｵﾌﾞ ﾑｴﾄｱｸｳﾌﾞｴｸｽ/ﾑｲﾎｵﾑｵ'ｽ ﾌﾟﾗｴﾗｴﾙｴｱｽｴ-ｱﾙﾌｱ ﾘﾘｰｽ ﾌｫｱ NixOS ﾓｼﾞｭｰﾙ ﾕｰｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|------|
| ﾀｲﾌﾟ | ｵｰﾊﾞｰﾚｲ |
| ｵｰﾊﾞｰﾚｲ ﾊﾟｽ | `nix-kits.overlays.mihomo-alpha` |
| ﾊﾟｯｹｰｼﾞ ﾈｰﾑ | `mihomo` |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ﾑｴﾄｱｸｳﾌﾞｴｸｽ/ﾑｲﾎｵﾑｵ](https://github.com/MetaCubeX/mihomo) |
| ﾄﾗｱｯｸﾄﾞ ﾊﾞｰｼﾞｮﾝ | ﾌﾟﾗｴﾗｴﾙｴｱｽｴ-ｱﾙﾌｱ |

## ｲﾝｽﾄｱﾙﾙｱｼｮﾝ

```nix
# ﾌﾚｲｸ.ﾆｯｸｽ
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

- ﾄﾗｱｯｸｽﾞ ﾙｱﾄｴｽﾄ ﾑｴﾄｱｸｳﾌﾞｴｸｽ/ﾑｲﾎｵﾑｵ ﾌﾟﾗｴﾗｴﾙｴｱｽｴ-ｱﾙﾌｱ ﾘﾘｰｽ
- ﾕｰｼｰｽﾞ ﾌﾟﾗｴ-ﾌﾞｳｲﾙﾄ ﾙｲﾝｳｸｽ AMD64 ﾊﾞｲﾅﾘ
- ｵﾌﾞｴﾗﾗｲﾄﾞｽﾞ `pkgs.mihomo` ﾊﾞｰｼﾞｮﾝ

## ﾉｰﾂ

- ｾｲﾑ ｱｯﾌﾟﾃﾞｰﾄ ﾜｰｸﾌﾛｰ ｱｽﾞ ﾗﾏ-cpp-rocm: `nix flake update` ｾﾞﾝ ﾗｴﾌﾞｳｲﾙﾄﾞ
- ﾌﾟﾗｴﾗｴﾙｴｱｽｴ-ｱﾙﾌｱ ｲｽﾞ ｱ ﾗｵﾙﾙｲﾝｸﾞ ﾄｱｸﾞ; ﾊﾞｰｼﾞｮﾝ ｲｽﾞ ｲﾄﾞｴﾝﾄｲﾌｲﾄﾞ ﾊﾞｲ ｺﾐｯﾄ ﾊｯｼｭ