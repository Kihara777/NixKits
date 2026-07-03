{
  lib,
  python3Packages,
  fetchFromGitea,
  makeWrapper,
  blender ? null,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "blender-mcp";
  version = "1.0.0";

  src = fetchFromGitea {
    domain = "projects.blender.org";
    owner = "lab";
    repo = "blender_mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nt+sHozi+epJdu6GXcWGd33C9uewN+Ao8WP9Y2upPQc=";
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
