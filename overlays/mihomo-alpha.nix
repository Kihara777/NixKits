{
  mihomo-ver,  # flake input: https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha
}:
(final: prev: let
  releaseInfo = builtins.fromJSON (builtins.readFile mihomo-ver);

  # Format: mihomo-linux-amd64-alpha-<commit>.gz → extract commit
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

    src = prev.fetchurl {
      url = "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-alpha-${commitHash}.gz";
      hash = "sha256-2LJTnbu7KxI0nHtHN7G2Yp4twroRPjV0pJ0199xy0HU=";
    };

    sourceRoot = ".";

    nativeBuildInputs = [ prev.gzip ];

    unpackPhase = ''
      gzip -cd $src > mihomo
      chmod +x mihomo
    '';

    configurePhase = "true";
    buildPhase = "true";

    installPhase = ''
      mkdir -p $out/bin
      cp mihomo $out/bin/mihomo
    '';

    # Prebuilt binary from GitHub releases — no Go deps needed
    vendorHash = null;
    deleteVendor = true;
    proxyVendor = true;

    ldflags = [];
  });
})