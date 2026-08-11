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
      #
      # Keep Breeze-Dark: BreezeBlack/gtk-{3,4}.0/gtk-dark.css contains
      #   @import url("../../Breeze-Dark/gtk-3.0/gtk.css")
      # which provides the actual dark color scheme (#202326 bg).  Deleting
      # Breeze-Dark breaks that import and GTK falls back to the light
      # theme — the "not black enough" symptom.
      #
      # Chromium-based apps (Edge/Chrome) do NOT honor gtk-application-
      # prefer-dark-theme; they load gtk.css directly.  BreezeBlack was
      # renamed from the light "Breeze", so its gtk.css still carries light
      # variables (#eff0f1).  Overwrite the CSS bodies with Breeze-Dark's
      # dark ones so every loader (GTK dark-pref, plain GTK, Chromium, ...)
      # gets the dark scheme.
      preFixup = (old.preFixup or "") + ''
        if [ -d "$out/share/themes/Breeze" ]; then
          mv "$out/share/themes/Breeze" "$out/share/themes/BreezeBlack"
        fi
        for v in 3.0 4.0; do
          for f in gtk.css gtk.css.map; do
            if [ -f "$out/share/themes/Breeze-Dark/gtk-$v/$f" ]; then
              cp -f "$out/share/themes/Breeze-Dark/gtk-$v/$f" "$out/share/themes/BreezeBlack/gtk-$v/$f"
            fi
          done
          # True-black + true-white: Breeze-Dark uses dark-gray backgrounds
          # (#202326) and near-white foregrounds (#fcfcfc).  User wants the
          # whole background (incl. buttons/toolbars/insensitive) pure black
          # and every foreground (buttons/icons/text) pure white.
          if [ -f "$out/share/themes/BreezeBlack/gtk-$v/gtk.css" ]; then
            sed -i \
              -e 's/#202326/#000000/g' \
              -e 's/#141618/#000000/g' \
              -e 's/#121416/#000000/g' \
              -e 's/#1d2023/#000000/g' \
              -e 's/#202428/#000000/g' \
              -e 's/#292c30/#000000/g' \
              -e 's/#fcfcfc/#ffffff/g' \
              -e 's/#a1a9b1/#ffffff/g' \
              "$out/share/themes/BreezeBlack/gtk-$v/gtk.css"
            # gtk-dark.css: make self-contained (copy of gtk.css) so it no
            # longer depends on Breeze-Dark's gray import.
            cp -f "$out/share/themes/BreezeBlack/gtk-$v/gtk.css" \
              "$out/share/themes/BreezeBlack/gtk-$v/gtk-dark.css"
          fi
        done
      '';
    });
  };

  # plasma-framework no longer needs a patch — the BreezeBlack color scheme and
  # global theme are auto-discovered by KDE from the installed files above.
  plasma-framework = prev.plasma-framework.overrideAttrs (old: {
    # No patches needed
  });
})
