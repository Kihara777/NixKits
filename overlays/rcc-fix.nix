final: prev: {
  asusctl = prev.asusctl.overrideAttrs (oldAttrs: {
    patches = prev.lib.unique ((oldAttrs.patches or []) ++ [
      ../patches/rcc-fix.patch
    ]);
  });
}
