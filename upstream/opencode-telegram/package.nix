{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "opencode-telegram";
  version = "0.26.4";

  src = fetchFromGitHub {
    owner = "grinev";
    repo = "opencode-telegram-bot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c4VpXRuQuvcKSvbiWxmvtg7fjMriS/6hY3XvISREzQc=";
  };

  npmDepsHash = "sha256-KbZkgfAgvF/+iPtmzPrfRLgDjzeqYneAnAWCw/Iz6DQ=";

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Telegram client for OpenCode, for running and monitoring coding tasks from a phone";
    homepage = "https://github.com/grinev/opencode-telegram-bot";
    changelog = "https://github.com/grinev/opencode-telegram-bot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "opencode-telegram";
    # better-sqlite3, which this app imports at startup, ships prebuilt binaries
    # for exactly these four platforms and is installed with --ignore-scripts, so
    # there is no fallback build here. Claiming more would be a lie.
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [ grg41 ];
  };
})
