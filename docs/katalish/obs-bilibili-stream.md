# obs-bilibili-ｽﾄﾘｰﾑ

[中文](../zh/obs-bilibili-ｽﾄﾘｰﾑ.md) | ｶﾀﾘｯｼｭ | [日本語](../ja/obs-bilibili-ｽﾄﾘｰﾑ.md) | [ｶﾀﾘｯｼｭ](../katalish/obs-bilibili-ｽﾄﾘｰﾑ.md) | [偽中国語](../pcn/obs-bilibili-ｽﾄﾘｰﾑ.md)

Bilibili live ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ OBS Studio.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| Version | 2.1.0 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [Zarosmm/obs-bilibili-ｽﾄﾘｰﾑ](https://github.com/Zarosmm/obs-bilibili-ｽﾄﾘｰﾑ) |
| Platform | Linux ｵﾝﾘｰ |

## ｲﾝｽﾄｰﾙ

**Recommended: NixOS ﾓｼﾞｭｰﾙ**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  imports = [ inputs.nix-kits.nixosModules.obs-bilibili-ｽﾄﾘｰﾑ ];
}
```

**Manual**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-ｽﾄﾘｰﾑ ];
  };
}
```

**Home Manager**

```nix
ﾎｰﾑ.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-ｽﾄﾘｰﾑ ];
```
