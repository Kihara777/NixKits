final: prev: {
  asusctl = prev.asusctl.overrideAttrs (oldAttrs: {
    patches = prev.lib.unique ((oldAttrs.patches or []) ++ [
      ../patches/rcc-fix.patch
    ]);

    # asusctl 6.4.0 renamed the desktop entry to
    # org.opengamingcollective.rog-control-center.desktop, but nixpkgs'
    # programs.rog-control-center autoStart (makeAutostartItem) still copies
    # <package>/share/applications/rog-control-center.desktop.  Ship the old
    # name as a symlink so the module keeps working.
    postInstall = (oldAttrs.postInstall or "") + ''
      ln -sf org.opengamingcollective.rog-control-center.desktop \
        "$out/share/applications/rog-control-center.desktop"
    '';
  });
}
