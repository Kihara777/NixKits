# ﾗｸｸ-ﾌｨｯｸｽ

[中文](../../zh/rcc-fix.md) | [ｲﾝｸﾞﾘｯｼｭ](rcc-fix.md) | [日本語](../../ja/rcc-fix.md) | [ｶﾀﾘｯｼｭ](../../katalish/rcc-fix.md) | [偽中国語](../../pcn/rcc-fix.md)

ﾊﾟｯﾁｰｽﾞ `asusctl` ﾌｫｱ ﾌﾞｴﾄﾄｴﾗ ｱｽｳｽﾞ ﾗｵｸﾞ ｸｵﾝﾄﾗｵﾙ ｽｴﾝﾄｴﾗ ｵﾝ 2-in-1 ﾄﾞｴﾄｱﾁｱﾌﾞﾙ ﾄﾞｴﾌﾞｲｸｽﾞ.

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | ﾌｫﾛｰｽﾞ ﾝｲｸｽﾌﾟｸｸﾞｽﾞ `asusctl` |
| ｳﾌﾟｽﾄﾗｴｱﾑ | [ｱｽｳｽﾞ-ﾙｲﾝｳｸｽ/ｱｽｳｽｸﾄﾙ](https://github.com/Asus-linux/asusctl) |
| ﾊﾟｯﾁ | ﾃﾞｨｽ ﾗｴﾌﾟｵ `patches/rog-control-center-fix.patch` |
| ﾓｼﾞｭｰﾙ | `nixosModules.rog-control-center-fix` (ｽｲｽﾄｴﾑﾄﾞ ﾄﾞｴｱﾄﾞﾙｵｯｸ ﾌｨｯｸｽ) |
| ﾉｰﾄ | ｵｰﾊﾞｰﾚｲ ﾗｴﾌﾟﾙｱｸｽﾞ `pkgs.asusctl`, ﾉｰ ｽﾄｱﾝﾄﾞｱﾙｵﾝｴ ﾊﾟｯｹｰｼﾞ |

## ﾌｨｯｸｼｰｽﾞ

- **ｸｴｲﾌﾞｵｱﾗﾄﾞ ﾄﾞｴﾄｴｸｼｮﾝ**: ｼｵｳｽﾞ ﾑｳﾙﾄｲ-ﾗﾝｹﾞｰｼﾞ ｵｰﾊﾞｰﾚｲ ｳｪﾝ ｸｴｲﾌﾞｵｱﾗﾄﾞ ﾄﾞｲｽｸｵﾝﾝｴｸﾄﾄﾞ, ｱﾌﾞｵｲﾄﾞｽﾞ ｸﾗｱｼ
- **ﾎｵﾄ-ﾌﾟﾙｳｸﾞ ﾗｴｸｵﾌﾞｴﾗｲ**: ﾄﾞ-ﾌﾞｳｽ ｲﾍﾞﾝﾄ-ﾄﾞﾗｲﾌﾞｴﾝ — ｵｰﾄ-ﾗｴｽﾄｵﾗｽﾞ ｱｳﾗｱ ﾕｰｱｲ ｵﾝ ﾗｴｸｵﾝﾝｴｸﾄ
- **ﾌﾞｵｳﾝﾄﾞｱﾗｲ ﾁｴｯｸｽﾞ**: ﾌﾟｵｳｴﾗｽﾞｵﾝｴ ｲﾝﾄﾞｴｸｽ ｸﾞｳｱﾗﾄﾞｽﾞ ﾌｫｱ ﾌｲﾗﾑｳｱﾗｴ-ﾗｴﾌﾟｵﾗﾄﾄﾞ ｲﾝﾌﾞｱﾙｲﾄﾞ ｽﾞｵﾝｽﾞ
- **ｽｲｽﾄｴﾑﾄﾞ ﾄﾞｴｱﾄﾞﾙｵｯｸ ﾌｨｯｸｽ**: ﾗｴﾑｵﾌﾞｽﾞ `PartOf` ﾌﾛﾑ `asus-shutdown.service` ﾄｩ ﾌﾟﾗｴﾌﾞｴﾝﾄ ｸｱｽｸｱﾄﾞｲﾝｸﾞ ｽﾄｯﾌﾟ ﾄﾞｴｱﾄﾞﾙｵｯｸ

## ｲﾝｽﾄｰﾙ

ｵｰﾊﾞｰﾚｲ (ｺｰﾄﾞ ﾊﾟｯﾁ) + NixOS ﾓｼﾞｭｰﾙ (ｽｲｽﾄｴﾑﾄﾞ ﾌｨｯｸｽ), ﾗｴｸｵﾑﾑｴﾝﾄﾞﾄﾞ ﾄｵｼﾞｴｽｴﾗ:

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusctl = {
    enable = true;
    power-profile = true;
    cpu-power-control = true;
  };

  programs.rog-control-center = {
    enable = true;
    autoStart = true;
  };
}
```