# NixKits 🐾

> A comprehensive NixOS flake repository in active development.

## What is this?

NixKits is a personal NixOS flake repository that provides:

- **RCC-FIX Overlay**: A fix for ASUS ROG Control Center on tablets
- **kitsfmt**: A lightweight Nix configuration formatter
- **obs-bilibili-stream**: Bilibili streaming plugin for OBS Studio

## Prerequisites

- Nix 2.4+ with flake support enabled
- Modern NixOS system

## Installation

Add `nix-kits` as an input to your flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  };
}
```

Then use the outputs from `nix-kits` in your configuration.

## Current Features

### RCC-FIX Overlay

The `rcc-fix` overlay patches `asusctl` to fix issues with ROG Control Center on ROG Flow Z13, particularly:

- Keyboard detection improvements
- Aura lighting control fixes
- Better error handling

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  outputs = {
    nixpkgs.overlays = [
      nix-kits.overlays.rcc-fix
    ];
  };
  
  # Enable ROG Control Center
  programs.rog-control-center.enable = true;
}
```

### Kitsfmt Package

`kitsfmt` is a lightweight Nix configuration formatter based on `nixpkgs-fmt`:

- ✅ Standard formatting with nixpkgs-fmt engine
- ✅ Preserves comments
- ✅ Cleans up extra blank lines
- ✅ CLI tool with full options
- ✅ Flake integration

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  # As system package
  environment.systemPackages = [
    nix-kits.packages.x86_64-linux.kitsfmt
  ];
  
  # Or as Nix formatter
  nix.settings.formatter = nix-kits.packages.x86_64-linux.kitsfmt;
}
```

**Command examples**:
```bash
# Format a file
kitsfmt file.nix

# Check if formatted (no modifications)
kitsfmt --check file.nix

# From stdin
cat config.nix | kitsfmt
```

### OBS Bilibili Stream Plugin

Bilibili streaming plugin for OBS Studio:

- ✅ Bilibili live streaming support
- ✅ Qt6-based UI
- ✅ Integrated with OBS Studio

**Usage**:
```nix
{
  inputs.nix-kits.url = "path:/path/to/NixKits";  # or github:Kihara777/NixKits
  
  # Enable OBS with Bilibili plugin
  programs.obs-studio = {
    enable = true;
    plugins = [
      nix-kits.packages.x86_64-linux.obs-bilibili-stream
    ];
  };
}
```

Or use the provided NixOS module:

```nix
{
  imports = [
    nix-kits.nixosModules.obs-bilibili-stream
  ];
}
```

## Project Structure

```
NixKits/
├── flake.nix                    # Main flake definition
├── modules/                     # NixOS modules
│   └── obs-bilibili-stream.nix
├── overlays/                    # nixpkgs overlays
│   ├── kitsfmt.nix
│   ├── obs-bilibili-stream.nix
│   └── rog-control-center-fix.nix
├── packages/                    # Custom packages
│   ├── kitsfmt.nix
│   ├── kitsfmt-src/             # kitsfmt Rust source
│   └── obs-bilibili-stream.nix
├── patches/                     # Patch files
│   └── rog-control-center-fix.patch
└── README.md
```

## Development Status

🚧 **Work in Progress**

This repository is actively being developed. Features may change, and new modules will be added over time.

## Contributing

Contributions are welcome! Please feel free to submit a Merge Request.

## Authors

**狐莉 キツのり (Kihara777)**

- GitHub: [@Kihara777](https://github.com/Kihara777)
- First Commit: 2026-04-30

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Repository**: https://github.com/Kihara777/NixKits
