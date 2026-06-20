# Overlay: mihomo-alpha
#
# Tracks MetaCubeX/mihomo Prerelease-Alpha release.
# Version is extracted from the release asset filename.
# Package name remains `mihomo` (overrides nixpkgs mihomo).
{
  mihomo-ver,
}:

final: prev:

let
  release = builtins.fromJSON (builtins.readFile mihomo-ver);
  assets = release.assets or [];

  # Find the amd64 .gz asset
  isAmd64Gz = a:
    let name = a.name or "";
    in builtins.match "mihomo-linux-amd64-alpha-.*\.gz" name != null;

  amd64Assets = builtins.filter isAmd64Gz assets;

  # Extract version hash from the first matching asset name
  firstAsset = if amd64Assets != [] then builtins.head amd64Assets else null;
  assetName = if firstAsset != null then firstAsset.name else "unknown";
  tags = if firstAsset != null then firstAsset.browser_download_url else "";
  versionHash = builtins.head (builtins.match ".*mihomo-linux-amd64-alpha-(.+)\.gz" assetName);

  # Full version string
  version = "alpha-${versionHash}";

in
{
  mihomo = prev.mihomo.overrideAttrs (oldAttrs: {
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-alpha-${versionHash}.gz";
      sha256 = "";  # impure fetch — set at build time
    };

    # Override the unpackPhase to handle .gz (gzip-compressed, not tar)
    unpackPhase = ''
      runHook preUnpack
      mkdir -p mihomo
      gzip -cd $src > mihomo/mihomo
      chmod +x mihomo/mihomo
      cd mihomo
      runHook postUnpack
    '';

    # Override the installPhase to install the binary
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp mihomo $out/bin/
      runHook postInstall
    '';

    # No build, no source root
    sourceRoot = ".";
    dontBuild = true;
    dontConfigure = true;

    # Override source derivation properties
    outputHashMode = "flat";
    outputHashAlgo = "sha256";

    meta = oldAttrs.meta // {
      description = "Mihomo — Prerelease-Alpha (tracking upstream)";
      version = version;
    };
  });
}

