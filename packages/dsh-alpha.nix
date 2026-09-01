# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage, lib }:
callPackage ./dsh.nix {
  version = "0.1.2-alpha.3";
  hash = "sha256-MwlKS+Jx+edLMvs4NHJanw1T7SXxNBdQb/7htXANr8c=";
  npmDepsHash = "sha256-mmatKs0jykfMcaIf0SVNLyIZ+Z7ipjGjjp2IaZo9FoE=";
  lockFile = ./dsh-package-lock-alpha.json;
}
