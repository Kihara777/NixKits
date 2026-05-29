{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.47";
  codewhale-cli = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-linux-x64";
    hash = "sha256-g4a8XT9jwt0uKbVwgVVG/U+EI12la2hvSv5dBYE4aY8=";
  };
  codewhale-tui = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-tui-linux-x64";
    hash = "sha256-yf2Mo7oNUXviXPeJtBFS2L3HRtiE6Mgf1cE/7Eu3T1c=";
  };
in
stdenv.mkDerivation {
  pname = "codewhale";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    dbus
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 ${codewhale-cli} $out/bin/codewhale
    install -Dm755 ${codewhale-tui} $out/bin/codewhale-tui
    runHook postInstall
  '';

  meta = {
    description = "Terminal coding agent for DeepSeek V4";
    homepage = "https://github.com/Hmbown/CodeWhale";
    changelog = "https://github.com/Hmbown/CodeWhale/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codewhale";
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
