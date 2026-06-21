{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.63";

  # Prebuilt binaries from GitHub Releases support three Linux architectures.
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = "riscv64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-SMaOUHs9VYFfyu0OHmU0vFtUGMFZGEgSDdLWt0qmZ6M=";
    arm64   = "sha256-gGv2T4BS4OybeKAEtLIX2zHFZSF1S8qp75Dtyw1dGM8=";
    riscv64 = "sha256-qSVNmsgB3FaUC4Jgnhjowgi9Z/T8UxNuHgzOd/PnCMg=";
  };

  tuiHashes = {
    x64     = "sha256-UA66uCdJUlR6/+acV+cf/Jvfe5MfNdWFIsjnsf8zjyM=";
    arm64   = "sha256-m24T1TPdg5JhJTXtQyo72EMlorhDvRlqxHv09oMui1g=";
    riscv64 = "sha256-l1tgSn6TrLxucAUmJKRvuTof0Sie5UCNrABeddG0nKw=";
  };

  codewhale-cli = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-linux-${archSuffix}";
    hash = cliHashes.${archSuffix};
  };
  codewhale-tui = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-tui-linux-${archSuffix}";
    hash = tuiHashes.${archSuffix};
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
    platforms = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];
    maintainers = [ ];
  };
}