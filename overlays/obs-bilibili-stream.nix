final: prev: {
  obs-bilibili-stream = final.callPackage ../packages/obs-bilibili-stream.nix {
    qtbase = final.qt6.qtbase;
  };
}
