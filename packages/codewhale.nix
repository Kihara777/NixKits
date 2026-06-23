{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.64";

  # Prebuilt binaries from GitHub Releases support three Linux architectures.
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = "riscv64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-sKvJm6xJSDIZjN7iXsq5BMay7Am4mivhzWmYorpg7XY=";
    arm64   = "sha256-gYofCLHQ2DQb54UfT/tG0p2FE41CWZ8F71b65oQGNjk=";
    riscv64 = "sha256-TOkojmi6PfO+Lwj2NZ1mHQoBKsnW3+XzMeXQpvCPISA=";
  };

  tuiHashes = {
    x64     = "sha256-Q3wRQ5EEpQWZh8gFWhd0jjRAVTiz/oDtVVKQZ6H0JkM=";
    arm64   = "sha256-CSKaNhrJGOn3gW7ge0GuNNeCs4LFckaxF66pB7b244M=";
    riscv64 = "sha256-mAARZqXUdwSUrzJR/ztb8ct8+kHONky7ixhvDdZ9TtY=";
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