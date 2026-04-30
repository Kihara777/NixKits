# NixKits 🐾

> A comprehensive NixOS configuration repository in active development.

## What is this?

NixKits is a personal NixOS flakes repository that provides:

- **RCC-FIX Overlay**: A fix for ASUS ROG Control Center on laptops

## Current Features

### RCC-FIX Overlay

The `rcc-fix` overlay patches `asusctl` to fix issues with ROG Control Center on ROG Flow Z13, particularly:

- Keyboard detection improvements
- Aura lighting control fixes
- Better error handling

**Requirements**: 
- `programs.rog-control-center.enable = true` must be set when using `nix-kits.overlays.rcc-fix`

**Usage:

```nix
nixpkgs.overlays = [ nix-kits.overlays.rcc-fix ];
```

## Development Status

🚧 **Work in Progress**

This repository is actively being developed. Features may change, and new modules will be added over time.

---

**Created by**: 狐莉 キツのり (Kitsunori)  
**First Commit**: 2026-04-30  
**Status**: Active Development 🐾
