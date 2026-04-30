(self: super: {
  asusctl = super.asusctl.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [
      ../patches/rog-control-center-fix.patch
    ];
  });
})
