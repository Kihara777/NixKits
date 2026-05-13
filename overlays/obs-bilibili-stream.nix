{ src }:
final: prev: {
  obs-bilibili-stream = final.callPackage ../packages/obs-bilibili-stream.nix {
    inherit src;
  };
}
