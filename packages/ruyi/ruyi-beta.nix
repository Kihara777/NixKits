# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.55.0-beta.20261120";
  hash = "sha256-X1P9Geyr+AY18MKpCWExTLZjaz25k9eZJJTJ887VuIc=";
}
