# rog-control-center-fix

[中文](../zh/rog-control-center-fix.md) | [English](../en/rog-control-center-fix.md) | 日本語 | [Katalish](../katalish/rog-control-center-fix.md) | [Pseudo-Chinese](../pcn/rog-control-center-fix.md)

asusd シャットダウン時の `asus-shutdown.service` デッドロックを修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs に追従 |
| タイプ | NixOS モジュール |
| パス | `modules/rog-control-center-fix.nix` |
| トリガー | `services.asusd.enable = true` |

## 修正内容

- **PartOf 除去**: `asus-shutdown.service` の `PartOf` を空にし、asusd 停止時の連鎖停止デッドロックを防止

## インストール

```nix
{
  imports = [ inputs.nix-kits.nixosModules.rog-control-center-fix ];

  services.asusd.enable = true;
}
```
