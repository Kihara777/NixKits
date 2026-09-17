{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs,
  makeWrapper,
  python3,
}:

buildNpmPackage (finalAttrs: {
  pname = "opencode-telegram";
  version = "0.25.2";

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wNM/QNtFaRaColS2MGqk2p94NpVeHXoqJ26RjNRVypU=";
  };

  npmDepsHash = "sha256-NnvFOrS7Y7NFYoS/lWTb3tTs5xwHhzDLTzkdGN+f3vw=";
  npmBuildScript = "build";
  npmInstallFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  postInstall = ''
    wrapProgram "$out/bin/opencode-telegram" \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  meta = {
    description = "OpenCode Telegram Bot - Secure Telegram client for OpenCode CLI";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    changelog = "https://github.com/grinev/opencode-telegram-bot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "opencode-telegram";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
