# ruyi-alpha overlay — latest alpha release
#
# Override the stable ruyi package to use the newest alpha tag.
# Usage:
#   nixpkgs.overlays = [ inputs.nixkits.overlays.ruyi-alpha ];
final: prev: {
  ruyi = prev.ruyi.overrideAttrs (old: {
    version = "0.51.0-alpha.20260616";
    src = prev.fetchFromGitHub {
      owner = "ruyisdk";
      repo = "ruyi";
      rev = "0.51.0-alpha.20260616";
      hash = "sha256-A7/Ca/H0NG+dGeQkGXal+b/q9s5KAkKI6s8BteeoKRg=";
    };
  });
}
