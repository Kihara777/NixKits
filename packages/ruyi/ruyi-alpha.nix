# ruyi-alpha — latest alpha release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.52.0-alpha.20260714";
  hash = "sha256-x6DGsnGgeClKXsS1kXP+3nIYGG2hJhyk6J1ENE2VD8s=";
}
