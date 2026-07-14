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
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R6pJ5fJ0V46rY7XZBhf7RDK5I3kVlqbbaxqtfm6XKkU=";
  };

  npmDepsHash = "sha256-3Mbhmd9Rw6k5OcbcfJf7JKXtgpke5GiDkf0CqY9YYAw=";
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
