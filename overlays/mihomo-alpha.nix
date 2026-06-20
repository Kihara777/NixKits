{ mihomo-ver }:
(final: prev: let
  releaseInfo = builtins.fromJSON (builtins.readFile mihomo-ver);

  # Extract commit-ish from linux-amd64 asset name
  # Format: mihomo-linux-amd64-alpha-<commit>.gz
  assets = releaseInfo.assets or [];
  commitHash = let
    amd64gz = builtins.filter
      (a: prev.lib.hasPrefix "mihomo-linux-amd64-alpha-" (a.name or "")
          && prev.lib.hasSuffix ".gz" (a.name or ""))
      assets;
    name = if builtins.length amd64gz > 0
      then (builtins.elemAt amd64gz 0).name
      else "";
    m = builtins.match "mihomo-linux-amd64-alpha-(.+)\.gz" name;
  in if m != null then prev.lib.elemAt m 0 else "unknown";

  version = "alpha-${commitHash}";
in {
  mihomo = prev.mihomo.overrideAttrs (old: {
    inherit version;

    src = prev.fetchFromGitHub {
      inherit (old.src) owner repo;
      rev = commitHash;
      hash = "sha256-I4Vol4mjkvCiRLbSL0q2EP+AMCmTjisrWrxaX9Hlwvg=";
      fetchSubmodules = old.src.fetchSubmodules or false;
    };

    vendorHash = "sha256-k/+Tg+iHLLOS9bYCb+8TnT3rc7H5AgHqTzC2cY1WOcU=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/metacubex/mihomo/constant.Version=${version}"
    ];
  });
})
