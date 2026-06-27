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
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FnLRcE6HUdHZCaw9LLC0S+curSekUepBuojnfRmKaVU=";
  };

  npmDepsHash = "sha256-nQq942kk43MsEu3hf78MEwSC3SboB5TgL2HTt+h0a0w=";
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
