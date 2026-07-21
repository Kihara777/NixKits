# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.51.0-beta.20260714";
  hash = "sha256-saOsHG0wBawEBVxOfiorkeu8XLErt+aEJYPuLNXenQ4=";
}
