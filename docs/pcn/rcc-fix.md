# rcc-fix

[中文](../zh/rcc-fix.md) | [English](../en/rcc-fix.md) | [日本語](../ja/rcc-fix.md)  | 偽中国語

ASUS ROG Control Center 2-in-1 脱着式鍵盤機器向修正。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | nixpkgs `asusctl` 追従 |
| 上流 | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| 修正 | 本倉庫 `patches/rcc-fix.patch` |
| 部品 | `nixosModules.rcc-fix`（systemd 膠着修正） |
| 注意 | 上乗以 `pkgs.asusctl` 置換、単独包無 |

## 修正内容

- **鍵盤検出**: 脱着式鍵盤未接続時多言語消息表示、崩壊防止
- **熱挿抜復旧**: D-Bus 事象駆動 — 再接続時 Aura UI 自動復元
- **境界検査**: 固件報告無効 PowerZone 安全濾過
- **systemd 膠着修正**: `asus-shutdown.service` 自 `PartOf` 除去、asusd 停止時連鎖停止防止

## 導入

上乗（符号修正）+ NixOS 部品（systemd 修正）、併用推奨：

```nix
{
  nixpkgs.overlays = [ inputs.nixkits.overlays.rcc-fix ];

  imports = [ inputs.nixkits.nixosModules.rcc-fix ];

  nixkits.rcc-fix.enable = true;

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
