{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  python3,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "mcp-searxng";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zakEU/6eeYClbj8VsSU0T6OqG0rl5iXUPSdAife4Juo=";
  };

  # v2.0.0 requires Node.js >= 22 (uses unpdf 1.8.1 for PDF extraction).
  npmDepsHash = "sha256-4WUOJJU9fXLVPE8ryB1IMWKVg5OL743VjupctYpPH0Y=";
  npmBuildScript = "build";

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  postInstall = ''
    makeWrapper "${nodejs}/bin/node" "$out/bin/mcp-searxng" \
      --add-flags "$out/lib/node_modules/mcp-searxng/dist/cli.js" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP Server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    changelog = "https://github.com/ihor-sokoliuk/MCP-searxng/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "mcp-searxng";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
