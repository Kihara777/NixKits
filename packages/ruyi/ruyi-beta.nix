# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.50.0-beta.20260623";
  hash = "sha256-6TSPifSgyo/jNGthz6uFZ/oBSl5P1Py16sQTYQ0yJfc=";
}
