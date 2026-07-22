# breeze-black

中文 | [English](../en/breeze-black.md) | [日本語](../ja/breeze-black.md)  | [偽中国語](../pcn/breeze-black.md)

为 Plasma 6 提供高对比度 Breeze Black 无障碍主题。包含全局 Plasma 主题（look-and-feel）+ GTK 主题 + 配色方案。

## 基本信息

| 项目 | 值 |
|------|-----|
| 版本 | 跟随 nixpkgs `breeze` / `breeze-gtk` |
| 上游 | [KDE Breeze](https://invent.kde.org/plasma/breeze) |
| overlay | `overlays/breeze-black.nix` |
| 许可 | 同上游（LGPL） |
| 注意 | overlay 无独立 package 输出，不进入二进制缓存 |

## 安装

```nix
nixpkgs.overlays = [ (import ./overlay.nix) ];
```

## 启用

```nix
programs.plasma.lookAndFeel = "org.kde.breezeblack.desktop";
gtk.theme = { name = "BreezeBlack"; package = pkgs.kdePackages.breeze-gtk; };
```

## 缓存

补丁均为 overlay，修改上游 nixpkgs 包而非独立构建，不在二进制缓存中。