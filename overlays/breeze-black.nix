(final: prev: let
  breezeBlackColors = ./breeze-black.colors;
in {
  kdePackages = prev.kdePackages // {
    breeze = prev.kdePackages.breeze.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (prev.fetchpatch {
          name = "breeze-black.patch";
          url = "https://injx.sbs/breeze-black/breeze-black.patch";
          hash = "sha256-SV4xkqq9nK7lCXnBI59uGB3XwKp4umq5t2v63IbKYog=";
        })
      ];
      postPatch = (old.postPatch or "") + ''
        cp ${breezeBlackColors} $out/share/color-schemes/BreezeBlack.colors
      '';
    });

    breeze-gtk = prev.kdePackages.breeze-gtk.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace CMakeLists.txt \
          --replace-fail 'assets' 'assets-dark'
      '';
      preFixup = (old.preFixup or "") + ''
        for dir in $out/share/themes/Breeze*; do
          mv "$dir" "$out/share/themes/BreezeBlack"
        done
      '';
    });
  };

  plasma-framework = prev.plasma-framework.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (prev.fetchpatch {
        name = "breeze-black.patch";
        url = "https://injx.sbs/breeze-black/breeze-black.patch";
        hash = "sha256-y8kwRlcNbLgbCS6yC/L8HfzLVFUhYItBKPAG+1W4WW4=";
      })
    ];
  });
})
