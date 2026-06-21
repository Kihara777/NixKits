final: prev: {
  ruyi = prev.ruyi.overrideAttrs (oldAttrs: {
    patches = prev.lib.unique ((oldAttrs.patches or []) ++ [
      ../patches/ruyi-nixos-compat.patch
    ]);

    buildInputs = (oldAttrs.buildInputs or []) ++ [ final.patchelf ];
  });
}
