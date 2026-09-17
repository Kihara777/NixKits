{
  lib,
  python3Packages,
  fetchzip,
  makeWrapper,
  blender ? null,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "blender-mcp";
  version = "1.0.3";

  # Blender's self-hosted Gitea rejects the `/archive/<rev>.tar.gz` path that
  # `fetchFromGitea` (and the `fetchFromGitHub` it delegates to) generates —
  # it answers 403 for *every* tag, including the previously working v1.0.0,
  # so this is an upstream change rather than a bad revision.  The archive is
  # still served from the API endpoint, which is what we fetch here.
  #
  # `stripRoot = true` reproduces fetchFromGitea's layout: the tarball's single
  # top-level directory is stripped, so `preConfigure`'s `cd mcp` keeps working.
  # (Verified against the v1.0.0 fetchFromGitea output, which lists `mcp/`
  # directly at the root.)
  src = fetchzip {
    url = "https://projects.blender.org/api/v1/repos/lab/blender_mcp/archive/v${finalAttrs.version}.tar.gz";
    stripRoot = true;
    hash = "sha256-pYeByO4Oi5eyynsJhGVd1vBWXHvhGn+Y5LGit6Kazlw=";
  };

  preConfigure = ''
    cd mcp
  '';

  pyproject = true;
  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies = [
    python3Packages.mcp
    python3Packages.docutils
    python3Packages.pyyaml
  ];

  # The build cd's into mcp/ via preConfigure. The addon lives at ../addon/
  # alongside it. Ship it so users can install it from the package.
  postInstall = ''
    addon_out="$out/share/blender/scripts/addons/blender_mcp_addon"
    mkdir -p "$(dirname "$addon_out")"
    cp -r ../addon/blender_mcp_addon "$addon_out"
  '';

  postFixup = lib.optionalString (blender != null) ''
    wrapProgram "$out/bin/blender-mcp" \
      --set-default BLENDER_PATH "${blender}/bin/blender"
  '';

  pythonImportsCheck = [ "blmcp" ];

  meta = {
    description = "MCP server for Blender — lightweight Model Context Protocol server";
    longDescription = ''
      A lightweight MCP (Model Context Protocol) server for Blender.
      It offers a natural language interface with Blender's Python API,
      improving access to documentation, and allowing users to explore
      and understand complex setups.
    '';
    homepage = "https://www.blender.org/lab/mcp-server/";
    changelog = "https://projects.blender.org/lab/blender_mcp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "blender-mcp";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
