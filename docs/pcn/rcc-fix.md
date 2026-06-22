# rcc-fix

[中文](../zh/rcc-fix.md) | [English](../en/rcc-fix.md) | [日本語](../ja/rcc-fix.md) | [ｶﾀﾘｯｼｭ](../katalish/rcc-fix.md) | 偽中国語

ASUS ROG Control Center 2-in-1 脱着式向。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | nixpkgs `asusctl` 追従 |
| 上流 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| | 本倉庫 `patches/rog-control-center-fix.patch` |
| 部品 | `nixosModules.rog-control-center-fix`（systemd 修正） |
| 注意 | overlay `pkgs.asusctl` 置換、単独包 |

## 修正内容

- **検出**: 脱着式未接続時多言語表示、防止
- **復旧**: D-Bus 駆動 — 再接続時 Aura UI 自動復元
- **境界**: 報告之無効 PowerZone 安全
- **systemd 修正**: `asus-shutdown.service` `PartOf` 除去、asusd 停止時之連鎖停止防止

## 導入

overlay（）+ NixOS 部品（systemd 修正）、併用推奨：

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.rcc-fix ];

  imports = [ inputs.nixkits.nixosModules.rog-control-center-fix ];

  nixkits.rog-control-center-fix.enable = true;

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
