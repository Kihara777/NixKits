# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | [日本語](../ja/rog-control-center-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rog-control-center-fix.md) | 偽中国語

asusd シャットダウン時 `asus-shutdown.service` デッドロック修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs 追従 |
| タイプ | NixOS モジュール |
| パス | `modules/rog-control-center-fix.nix` |
| トリガー | `services.asusd.enable = true` |

## 修正内容

- **PartOf 除去**: `asus-shutdown.service`  `PartOf` 空，asusd 停止時連鎖停止デッドロック防止

## インストール

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
