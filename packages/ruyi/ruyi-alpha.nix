# ruyi-alpha — latest alpha release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.56.0-alpha.20261123";
  hash = "sha256-4NlaUMg/e4HdNBuzRz8firs76+J+4rbJ66CGfaY+yC4=";
}
