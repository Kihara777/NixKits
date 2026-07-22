# breeze-black

[中文](../zh/breeze-black.md) | English | [日本語](breeze-black.ja.md)  | [偽中国語](breeze-black.pcn.md)

High-contrast Breeze Black accessibility theme for Plasma 6. Includes global Plasma look-and-feel + GTK theme + color scheme.

## Info

| Item | Value |
|------|-------|
| Version | Follows nixpkgs `breeze` / `breeze-gtk` |
| Upstream | [KDE Breeze](https://invent.kde.org/plasma/breeze) |
| Overlay | `overlays/breeze-black.nix` |
| License | Same as upstream (LGPL) |
| Note | Overlay has no standalone package output, not in binary cache |

## Install

```nix
nixpkgs.overlays = [ inputs.nixkits.overlays.breeze-black ];
```

## Enable

```nix
programs.plasma.lookAndFeel = "org.kde.breezeblack.desktop";
gtk.theme = { name = "BreezeBlack"; package = pkgs.kdePackages.breeze-gtk; };
```

## Cache

Patches are overlays — they modify upstream nixpkgs packages rather than building independently, and are not in the binary cache.