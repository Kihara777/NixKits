# dsh-alpha — latest alpha development channel
#
# Thin wrapper around the stable dsh.nix with version + hash overrides.
{ callPackage, lib, allowLanSettings ? false }:
callPackage ./dsh.nix {
  version = "0.1.6-alpha.2";
  hash = "sha256-o8FNF1wFECPc3gePsnOyh7E7S3dlTqkLUtlWy/QJF40=";
  npmDepsHash = "sha256-p4uALt5vuWnFnnJnNAmPDW10DEGnfbjEC1BhQ9CyLDE=";
  lockFile = ./dsh-package-lock-alpha.json;
  inherit allowLanSettings;
}
