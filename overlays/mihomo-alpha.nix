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
      hash = "sha256-42gWbg6on0g8tR7lVqrNH7x1GejzijP8bVvrQa0D3bM=";
      fetchSubmodules = old.src.fetchSubmodules or false;
    };

    vendorHash = "sha256-KpeFNqVtvOOB9NxETajOihcqOAFn3lLrbKns4UDUnnE=";

    ldflags = [
      "-s"
      "-w"
      "-X github.com/metacubex/mihomo/constant.Version=${version}"
    ];
  });
})
