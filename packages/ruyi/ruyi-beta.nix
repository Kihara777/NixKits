# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.54.0-beta.20261102";
  hash = "sha256-+adc3vV1yPElIxPLhbMttQBqp/Dl6jmQoFzFPJC1VzM=";
}
