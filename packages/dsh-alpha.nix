# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage, lib, allowLanSettings ? false }:
callPackage ./dsh.nix {
  version = "0.1.6-alpha.1";
  hash = "sha256-9K/QE9p0mJygaNN9sdBNVS1/nI1Slv9mxQ1nGApjhPg=";
  npmDepsHash = "sha256-qAlIccAJG/FEMRL1JWtjZQ/MvyIeWORFDWo8+pQ5Xk4=";
  lockFile = ./dsh-package-lock-alpha.json;
  inherit allowLanSettings;
}
