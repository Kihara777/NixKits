# ruyi-beta — latest beta release channel
#
# Thin wrapper around the stable ruyi.nix with version + hash overrides.
{ callPackage }:
callPackage ./ruyi.nix {
  version = "0.53.0-beta.20260917";
  hash = "sha256-w8NlCER3XiMALrf2MVLG+YcaF5HUc/OBBJ2HhriLAtQ=";
}
