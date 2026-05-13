final: prev: {
  asusctl = prev.asusctl.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      ../patches/rog-control-center-fix.patch
    ];
  });
}
