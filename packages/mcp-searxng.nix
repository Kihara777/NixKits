{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs
, makeWrapper
, python3
, nix-update-script
}:

buildNpmPackage (finalAttrs: {
  pname = "mcp-searxng";
  version = "1.0.3"; # 与上游 tag (v1.0.3) 保持一致

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "MCP-searxng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DEZW6pG/t13I95ZmW7WyIJNfPd64d9cf55ceUyl0SAY=";
  };

  npmDepsHash = "sha256-STrntrJ4k9Gvo+kYUXw/mnC5XyKvzxy28HifCQqostU=";
  npmBuildScript = "build";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/mcp-searxng \
      --add-flags "$out/lib/node_modules/mcp-searxng/dist/index.js" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MCP Server for SearXNG integration";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = licenses.mit;
    mainProgram = "mcp-searxng";
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
})
