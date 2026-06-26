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
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xyNjBJ268JqJVhKOC/wLQ4SqKqTI+TgQEgbSdYLGid0=";
  };

  npmDepsHash = "sha256-dVFX5wmYTd28e9FsmwkuuF09do9Z8+Du9osxAFEx4/4=";
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
