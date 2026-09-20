# ruyi-alpha — latest alpha release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.54.0-alpha.20260918";
  hash = "sha256-6XSVQuU+szU8CnijgAwQa1XmoHgpk/vHW6tmWP5dkpQ=";
}
