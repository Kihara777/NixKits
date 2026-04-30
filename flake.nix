{
  description = "NixKits - A comprehensive NixOS configuration repository";

  outputs = { ... }:
  {
    # Overlay for RCC-FIX (ROG Control Center Fix)
    overlays.rcc-fix = final: prev: {
      asusctl = prev.asusctl.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or []) ++ [
          ./patches/rog-control-center-fix.patch
        ];
      });
    };

    # NixOS configuration module
    nixosModules.rcc-fix = import ./nixos-modules/rcc-fix.nix;

    # Flakes template for quick start
    templates.rcc-fix = {
      path = ./templates/rcc-fix;
      description = "Example NixOS configuration with RCC-FIX";
    };
  };
}
