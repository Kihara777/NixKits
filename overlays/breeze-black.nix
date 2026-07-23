(final: prev: let
  breezeBlackColors = ./breeze-black.colors;
in {
  kdePackages = prev.kdePackages // {
    breeze = prev.kdePackages.breeze.overrideAttrs (old: {
      # The original breeze-black.patch hosted at injx.sbs / GitHub injx/breeze-black
      # is no longer available. Since the user only needs the BreezeBlack color scheme
      # (not the full look-and-feel theme), we drop the external patch and rely on
      # postPatch to install the .colors file. KDE Plasma auto-discovers color schemes
      # from share/color-schemes/.
      postPatch = (old.postPatch or "") + ''
        mkdir -p $out/share/color-schemes
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

  # plasma-framework no longer needs a patch — the BreezeBlack color scheme is
  # auto-discovered by KDE from share/color-schemes/. The original fetchpatch
  # URL (injx.sbs) is permanently unavailable.
  plasma-framework = prev.plasma-framework.overrideAttrs (old: {
    # No patches needed
  });
})
