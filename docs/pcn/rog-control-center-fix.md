# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-fix.md) | 偽中国語

asusd 時 `asus-shutdown.service` 修復。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版本 | nixpkgs 追従 |
| 類型 | NixOS 模塊 |
| | `modules/rog-control-center-fix.nix` |
| | `services.asusd.enable = true` |

## 修復内容

- **PartOf 除去**: `asus-shutdown.service` `PartOf` 空，asusd 停止時連鎖停止防止

## 安裝

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
