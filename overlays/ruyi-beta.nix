# ruyi-beta overlay — latest beta release
#
# Override the stable ruyi package to use the newest beta tag.
# Usage:
#   nixpkgs.overlays = [ inputs.nixkits.overlays.ruyi-beta ];
final: prev: {
  ruyi = prev.ruyi.overrideAttrs (old: {
    version = "0.50.0-beta.20260623";
    src = prev.fetchFromGitHub {
      owner = "ruyisdk";
      repo = "ruyi";
      rev = "0.50.0-beta.20260623";
      hash = "sha256-6TSPifSgyo/jNGthz6uFZ/oBSl5P1Py16sQTYQ0yJfc=";
    };
  });
}
