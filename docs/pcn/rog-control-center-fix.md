# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-fix.md) | 偽中国語

asusd 停止時 `asus-shutdown.service` 膠着修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | nixpkgs 追従 |
| 種別 | NixOS 部品 |
| 路 | `modules/rog-control-center-fix.nix` |
| 引金 | `services.asusd.enable = true` |

## 修正内容

- **PartOf 除去**: `asus-shutdown.service` `PartOf` 空化、asusd 停止時連鎖停止膠着防止

## 導入

```nix
{
  imports = [ inputs.nixkits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
