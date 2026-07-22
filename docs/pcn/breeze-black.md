# breeze-black

[中文](../zh/breeze-black.md) | [English](breeze-black.en.md) | [日本語](breeze-black.ja.md)  | 偽中国語

Plasma 6 向高対比 Breeze Black 障碍支援主題。包括全局 Plasma look-and-feel + GTK 主題 + 配色方案。

## 基本情報

| 項目 | 値 |
|------|-----|
| 版 | nixpkgs `breeze` / `breeze-gtk` 追従 |
| 上流 | [KDE Breeze](https://invent.kde.org/plasma/breeze) |
| Overlay | `overlays/breeze-black.nix` |
| 許諾 | 同上流（LGPL） |
| 注意 | Overlay 独立包出力無、二進緩衝対象外 |

## 導入

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.breeze-black ];
```

## 有効化

```nix
programs.plasma.lookAndFeel = "org.kde.breezeblack.desktop";
gtk.theme = { name = "BreezeBlack"; package = pkgs.kdePackages.breeze-gtk; };
```

## 緩衝

補丁 overlay 故、上流 nixpkgs 包変更、独立構築無、二進緩衝不包含。