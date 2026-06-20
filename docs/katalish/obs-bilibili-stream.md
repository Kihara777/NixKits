# obs-bilibili-stream

[中文](../../zh/obs-bilibili-stream.md) | [English](obs-bilibili-stream.md) | [日本語](../../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../../katalish/obs-bilibili-stream.md)

Bilibili live ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ OBS Studio.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 2.1.0 |
| Upstream | [Zarosmm/obs-bilibili-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| ﾌﾟﾗｯﾄﾌｫｰﾑ | Linux ｵﾝﾘｰ |

## ｲﾝｽﾄｰﾙ

**Recommended: NixOS ﾓｼﾞｭｰﾙ**

```nix
{
  nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
  imports = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.nixosModules.obs-bilibili-stream ];
}
```

**Manual**

```nix
{
  nixpkgs.overlays = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.overlays.ﾃﾞﾌｫﾙﾄ ];
  programs.obs-studio = {
    ｲﾈｰﾌﾞﾙ = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**ﾎｰﾑ Manager**

```nix
ﾎｰﾑ.ﾊﾟｯｹｰｼﾞｰｽﾞ = [ ｲﾝﾌﾟｯﾄｽﾞ.nix-kits.ﾊﾟｯｹｰｼﾞｰｽﾞ.${pkgs.ｼｽﾃﾑ}.obs-bilibili-stream ];
```