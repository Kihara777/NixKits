(final: prev: let    breeze-gtk = prev.kdePackages.breeze-gtk.overrideAttrs (old: {
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
