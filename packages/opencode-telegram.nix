{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs
, makeWrapper
, python3
}:

buildNpmPackage (finalAttrs: {
  pname = "opencode-telegram";
  version = "0.20.5"; # 与上游 tag (v0.20.5) 保持一致

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cA5vbBm6diQf/YYCPe3QwCPAm/i8+BMr+bQTQlMdFxk=";
  };

  npmDepsHash = "sha256-M0xDEVEyJ7IE9Q/bRVW0CiITaPxpwtO1MZKS3nm3ybs=";
  npmBuildScript = "build";
  npmInstallFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ nodejs ] ++ lib.optionals (lib.versionAtLeast nodejs.version "20") [ python3 ];

  postInstall = ''
    wrapProgram $out/bin/opencode-telegram \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  doCheck = false;

  meta = {
    description = "OpenCode Telegram Bot - Secure Telegram client for OpenCode CLI";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    license = lib.licenses.mit;
    mainProgram = "opencode-telegram";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
