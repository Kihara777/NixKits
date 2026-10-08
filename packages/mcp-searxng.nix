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
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TqDj86FTOekTswNQkTkiC8Q/H46bz4iigr5GRlM9Tno=";
  };

  # v2.1.0 requires Node.js >= 22 (uses unpdf 1.8.1 for PDF extraction).
  npmDepsHash = "sha256-WuN8xzG5uU1wZdMLdiT2GfUn1BeHTdtIkBc4x2kz81Q=";
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
