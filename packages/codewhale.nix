{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "codewhale";
  version = "0.8.47";

  src = fetchFromGitHub {
    owner = "Hmbown";
    repo = "CodeWhale";
    tag = "v${version}";
    hash = "sha256-JGNVKihR55U66xWy6/67XHIulE88IZkpt27KlxmJZS0=";
  };

  cargoHash = "sha256-7wkA8lVv1lsh/eU3dKpK6XrE/P9ZgL+cADNRGSor97M=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    openssl
  ];

  doCheck = false;

  cargoBuildFlags = [
    "-p" "codewhale-cli"
    "-p" "codewhale-tui"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 target/release/codewhale $out/bin/codewhale 2>/dev/null || \
    install -Dm755 target/x86_64-unknown-linux-gnu/release/codewhale $out/bin/codewhale
    install -Dm755 target/release/codewhale-tui $out/bin/codewhale-tui 2>/dev/null || \
    install -Dm755 target/x86_64-unknown-linux-gnu/release/codewhale-tui $out/bin/codewhale-tui
    runHook postInstall
  '';

  meta = {
    description = "Terminal coding agent for DeepSeek V4";
    homepage = "https://github.com/Hmbown/CodeWhale";
    changelog = "https://github.com/Hmbown/CodeWhale/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codewhale";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
