# breeze-black

[中文](../zh/breeze-black.md) | [English](breeze-black.en.md) | 日本語  | [偽中国語](breeze-black.pcn.md)

Plasma 6 向け高コントラスト Breeze Black アクセシビリティテーマ。グローバル Plasma look-and-feel + GTK テーマ + カラースキームを含む。

## 基本情報

| 項目 | 値 |
|------|-----|
| バージョン | nixpkgs `breeze` / `breeze-gtk` に追従 |
| 上流 | [KDE Breeze](https://invent.kde.org/plasma/breeze) |
| Overlay | `overlays/breeze-black.nix` |
| ライセンス | 上流と同じ（LGPL） |
| 注意 | Overlay は独立パッケージ出力なし、バイナリキャッシュ非対象 |

## インストール

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.breeze-black ];
```

## 有効化

```nix
programs.plasma.lookAndFeel = "org.kde.breezeblack.desktop";
gtk.theme = { name = "BreezeBlack"; package = pkgs.kdePackages.breeze-gtk; };
```

## キャッシュ

パッチは overlay のため、上流 nixpkgs パッケージを変更し、独立ビルドせず、バイナリキャッシュに含まれない。