# ruyi-alpha — latest alpha release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.51.0-alpha.20260616";
  hash = "sha256-A7/Ca/H0NG+dGeQkGXal+b/q9s5KAkKI6s8BteeoKRg=";
}
