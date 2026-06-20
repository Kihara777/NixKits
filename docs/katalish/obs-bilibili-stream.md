# ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream

[中文](../../zh/obs-bilibili-stream.md) | [English](obs-bilibili-stream.md) | [日本語](../../ja/obs-bilibili-stream.md) | [ｶﾀﾘｯｼｭ](../../katalish/obs-bilibili-stream.md) | [偽中国語](../../pcn/obs-bilibili-stream.md)

Bilibili live ｽﾄﾘｰﾐﾝｸﾞ ﾌﾟﾗｸﾞｲﾝ ﾌｫｱ OBS Studio.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | 2.1.0 |
| Upstream | [Zarosmm/ｵﾌﾞｴｽ-ﾋﾞﾘﾋﾞﾘ-stream](https://github.com/Zarosmm/obs-bilibili-stream) |
| ﾌﾟﾗｯﾄﾌｫｰﾑ | Linux ｵﾝﾘｰ |

## ｲﾝｽﾄｰﾙ

**Recommended: NixOS ﾓｼﾞｭｰﾙ**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  imports = [ inputs.nix-kits.nixosModules.obs-bilibili-stream ];
}
```

**Manual**

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.default ];
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-bilibili-stream ];
  };
}
```

**ﾎｰﾑ Manager**

```nix
home.packages = [ inputs.nix-kits.packages.${pkgs.system}.obs-bilibili-stream ];
```