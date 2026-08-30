# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage }:
callPackage ./dsh.nix {
  version = "0.1.2-alpha.2";
  hash = "sha256-W/BiompJCFP/uSlP48n7IEfwKb41RWEt6kVxioGSCkc=";
  npmDepsHash = "sha256-bJMeVSSEZngCysPvuS2w+3j+fzntcObddsi4y5fLlO0=";
  lockFile = ./dsh-package-lock-alpha.json;
}
