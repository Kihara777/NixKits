# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.52.0-beta.20260824";
  hash = "sha256-vxu9AhRD+4NA4PRfYEj0bdHy1PWhmeHyr0NKv0PJU3M=";
}
