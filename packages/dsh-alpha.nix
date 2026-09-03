# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage }:
callPackage ./dsh.nix {
  version = "0.1.2-alpha.5";
  hash = "sha256-xtRp4CJ8WbCu6AoZxKAy9EsmPi1OtdRHAXBO1a/BNxs=";
  npmDepsHash = "sha256-/d/TL3qVBCYm0xzqLp+EHwX7OSCGMJDAAmrBSrVksS8=";
  lockFile = ./dsh-package-lock-alpha.json;
}
