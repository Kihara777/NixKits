{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.65";

  # Prebuilt binaries from GitHub Releases support three Linux architectures.
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = "riscv64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-JD69uCNhO27crUBLUHqphQdfAJqrAPOIrq65TN2uHFE=";
    arm64   = "sha256-SLQOxi48XavfwUE0W4Gy/Na+whuu2sR56vXXHTJmwUs=";
    riscv64 = "sha256-dCxRYcMbbOFxMaGZkUAoVPxk0QOCh4hRS35f/0ew0Ck=";
  };

  tuiHashes = {
    x64     = "sha256-U1sDRoUkAJ5n+4bqZ9JrAx1R9RXS2ZIFukTFeVFaT/g=";
    arm64   = "sha256-jPcoG28M/kZreU86NXW0OX2BBsTT27Sd9WjOAqemp1w=";
    riscv64 = "sha256-bh3Qq/OA4fopjSFaleA1X2FwzhfvTfbSPq8jkO7+p+o=";
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