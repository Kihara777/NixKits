# obs-bilibili-stream

[中文](../zh/obs-bilibili-stream.md) | [English](../en/obs-bilibili-stream.md) | [日本語](../ja/obs-bilibili-stream.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/obs-bilibili-stream.md)

Bilibili ﾙｲﾌﾞｴ ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ OBS ｽﾄｳﾄﾞｲｵ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 2.1.0 |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ｽﾞｱﾗｵｽﾑﾑ/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| ﾌﾟﾗｯﾄﾌｫｰﾑ | ﾙｲﾝｳｸｽ ｵﾝﾘｰ |

## ｲﾝｽﾄｰﾙ

**ﾗｴｸｵﾑﾑｴﾝﾄﾞﾄﾞ: NixOS ﾓｼﾞｭｰﾙ**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
  ｲﾑﾌﾟｵﾗﾄｽﾞ = [ inputs.nix-kits.ﾝｲｸｽｵｽﾑｵﾄﾞｳﾙｽﾞ.obs-bilibili-stream ];
}
```

**ﾏﾆｭｱﾙ**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
  ﾌﾟﾗｵｸﾞﾗｱﾑｽﾞ.ｵﾌﾞｴｽ-ｽﾄｳﾄﾞｲｵ = {
    ｲﾈｰﾌﾞﾙ = ﾄﾗｳｴ;
    ﾌﾟﾙｳｼﾞｲﾝｽﾞ = [ pkgs.obs-bilibili-stream ];
  };
}
```

**ﾎｰﾑ ﾑｱﾝｱｼﾞｴﾗ**

```nix
ﾎｰﾑ.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
```