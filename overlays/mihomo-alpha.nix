# Overlay: mihomo-alpha
#
# Replaces pkgs.mihomo with a prebuilt binary tracking the
# Prerelease-Alpha release from MetaCubeX/mihomo.
#
# Usage (system flake.nix):
#   nix-kits.overlays.mihomo-alpha
#
# flake input: mihomo-ver.url = "https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/Prerelease-Alpha";
#              mihomo-ver.flake = false;

{ mihomo-ver }:

final: prev:

let
  # Parse version from the GitHub release API JSON.
  release = builtins.fromJSON (builtins.readFile mihomo-ver);
  assets = release.assets or [];
  amd64Gz = builtins.filter
    (a: builtins.match "mihomo-linux-amd64-alpha-[0-9a-f]+\.gz" (a.name or "") != null)
    assets;
  gzAsset = builtins.head amd64Gz;
  name = gzAsset.name;
  commitHash = builtins.head
    (builtins.match "mihomo-linux-amd64-alpha-([0-9a-f]+)\.gz" name);
in
{
  mihomo = prev.stdenv.mkDerivation {
    pname = "mihomo-alpha";
    version = "alpha-${commitHash}";

    src = final.fetchurl {
      url = gzAsset.browser_download_url;
      sha256 = gzAsset.sha256 or "";
    };

    nativeBuildInputs = [ final.gzip ];

    unpackPhase = ''
      runHook preUnpack
      mkdir -p mihomo
      gzip -cd $src > mihomo/mihomo
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m 755 mihomo/mihomo $out/bin/mihomo
      runHook postInstall
    '';

    meta = prev.mihomo.meta or {} // {
      version = "alpha-${commitHash}";
    };
  };
}
