(final: prev: let
  breezeBlackColors = ./breeze-black.colors;
  breezeBlackLookAndFeel = ./breeze-black-look-and-feel/org.kde.breezeblack.desktop;
in {
  kdePackages = prev.kdePackages // {
    breeze = prev.kdePackages.breeze.overrideAttrs (old: {
      # The original breeze-black.patch (hosted at injx.sbs / GitHub injx/breeze-black)
      # is permanently unavailable.  We install everything locally instead:
      #   - BreezeBlack.colors      → share/color-schemes/   (auto-discovered)
      #   - org.kde.breezeblack.desktop → share/plasma/look-and-feel/
      #     (global theme so BreezeBlack shows up in the system settings
      #      Global Theme chooser — without it the theme "disappears")
      postPatch = (old.postPatch or "") + ''
        mkdir -p $out/share/color-schemes
        cp ${breezeBlackColors} $out/share/color-schemes/BreezeBlack.colors
      '';
      postInstall = (old.postInstall or "") + ''
        mkdir -p $out/share/plasma/look-and-feel
        # cp -r of a store path keeps its hash-prefixed basename; rename to
        # the exact directory name KDE expects (org.kde.breezeblack.desktop).
        cp -r ${breezeBlackLookAndFeel} $out/share/plasma/look-and-feel/org.kde.breezeblack.desktop
      '';
    });

    breeze-gtk = prev.kdePackages.breeze-gtk.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace CMakeLists.txt \
          --replace-fail 'assets' 'assets-dark'
      '';
      # Rename the light "Breeze" GTK theme to "BreezeBlack" (it is built
      # dark via the assets→assets-dark substitution above).  Do NOT glob
      # Breeze* — that would also match Breeze-Dark and nest it inside
      # BreezeBlack, breaking GTK theme detection.
      preFixup = (old.preFixup or "") + ''
        if [ -d "$out/share/themes/Breeze" ]; then
          mv "$out/share/themes/Breeze" "$out/share/themes/BreezeBlack"
        fi
        rm -rf "$out/share/themes/Breeze-Dark"
      '';
    });
  };

  # plasma-framework no longer needs a patch — the BreezeBlack color scheme and
  # global theme are auto-discovered by KDE from the installed files above.
  plasma-framework = prev.plasma-framework.overrideAttrs (old: {
    # No patches needed
  });
})
