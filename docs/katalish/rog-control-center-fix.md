# ﾗｵｸﾞ-ｸｵﾝﾄﾗｵﾙ-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md) | ｶﾀﾘｯｼｭ | [偽中国語](../pcn/rog-control-center-fix.md)

ﾌｨｯｸｼｰｽﾞ ｱ ｽｲｽﾄｴﾑﾄﾞ ﾄﾞｴｱﾄﾞﾙｵｯｸ ﾃﾞｭｱﾘﾝｸﾞ ｼｳﾄﾄﾞｵｳﾝ ｲﾝ `asus-shutdown.service`

## ｲﾝﾌｫ

| ｱｲﾃﾑ | ﾊﾞﾘｭｰ |
|------|-------|
| ﾊﾞｰｼﾞｮﾝ | ﾄﾗｱｯｸｽﾞ ﾝｲｸｽﾌﾟｸｸﾞｽﾞ |
| ﾀｲﾌﾟ | NixOS ﾓｼﾞｭｰﾙ |
| ﾊﾟｽ | `modules/rog-control-center-fix.nix` |
| ﾄﾘｶﾞｰ | `services.asusd.enable = true` |

## ﾌｨｯｸｼｰｽﾞ

- **ﾘﾑｰﾌﾞ ﾌﾟｱﾗﾄｵﾌ**: ｸﾙｴｱﾗｽﾞ `PartOf` ｵﾝ `asus-shutdown.service` ﾄｩ ﾌﾟﾗｴﾌﾞｴﾝﾄ ｸｱｽｸｱﾄﾞｲﾝｸﾞ ｽﾄｯﾌﾟ ﾄﾞｴｱﾄﾞﾙｵｯｸ ｳｪﾝ ｱｽｳｽﾄﾞ ﾗｴｽﾄｱﾗﾄｽﾞ

## ｲﾝｽﾄｰﾙ

```nix
{
  ｲﾑﾌﾟｵﾗﾄｽﾞ = [ ｲﾝﾌﾟｯﾄｽﾞ.ﾆｯｸｽ-ｸｲﾄｽﾞ.ﾝｲｸｽｵｽﾑｵﾄﾞｳﾙｽﾞ.ﾗｵｸﾞ-ｸｵﾝﾄﾗｵﾙ-center-fix ];

  ｽｴﾗﾌﾞｲｸｽﾞ.ｱｽｳｽﾄﾞ.ｲﾈｰﾌﾞﾙ = ﾄﾗｳｴ;
}
```