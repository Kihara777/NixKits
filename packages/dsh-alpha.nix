# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage, lib, allowLanSettings ? false }:
callPackage ./dsh.nix {
  version = "0.1.5-alpha.2";
  hash = "sha256-dY58jb6ykhWVyMobGtXN+G/u0RVm1DGsXVoW8F3PsFA=";
  npmDepsHash = "sha256-SVYhLVZwiseq4zgy4yoDBn+rIhHj3mMVE/Hez0LT+Ac=";
  lockFile = ./dsh-package-lock-alpha.json;
  inherit allowLanSettings;
}
