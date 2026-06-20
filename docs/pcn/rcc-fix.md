# rcc-fix

[中文](../zh/rcc-fix.md) | [English](../en/rcc-fix.md) | 偽中国語 | [ｶﾀﾘｯｼｭ](../katalish/rcc-fix.md) 

ASUS ROG Control Center  2-in-1 脱着式キーボードデバイス向パッチ。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs `asusctl` 追従 |
| アップストリーム | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| パッチ | 本リポジトリ `patches/rog-control-center-fix.patch` |
| モジュール | `nixosModules.rog-control-center-fix`(systemd デッドロック修正) |
| 注意 | overlay  `pkgs.asusctl` 置換，単独パッケージ |

## 修正内容

- **キーボード検出**: 脱着式キーボード未接続時多言語メッセージ表示，クラッシュ防止
- **ホットプラグ復旧**: D-Bus イベント駆動 — 再接続時 Aura UI 自動復元
- **境界チェック**: ファームウェア報告無効 PowerZone 安全フィルタリング
- **systemd デッドロック修正**: `asus-shutdown.service`  `PartOf` 除去，asusd 停止時連鎖停止防止

## インストール

overlay(コードパッチ)+ NixOS モジュール(systemd 修正)，併用推奨：

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
