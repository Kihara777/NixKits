# rcc-fix

[中文](../zh/rcc-fix.md) | [English](../en/rcc-fix.md) | [日本語](rcc-fix.md)

ASUS ROG Control Center を 2-in-1 脱着式キーボードデバイス向けにパッチ。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs `asusctl` に追従 |
| アップストリーム | [Asus-linux/asusctl](https://github.com/Asus-linux/asusctl) |
| パッチ | 本リポジトリ `patches/rog-control-center-fix.patch` |
| 注意 | overlay で `pkgs.asusctl` を置き換え、単独パッケージなし |

## 修正内容

- **キーボード検出**: 脱着式キーボード未接続時にクラッシュせず多言語メッセージを表示
- **ホットプラグ復旧**: D-Bus イベント駆動 — 再接続時に Aura UI を自動復元
- **境界チェック**: ファームウェア報告の無効な PowerZone を安全にフィルタリング

## インストール

```nix
{
  nixpkgs.overlays = [ inputs.nix-kits.overlays.rcc-fix ];

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
