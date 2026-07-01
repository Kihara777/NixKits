{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.66";

  # Prebuilt binaries from GitHub Releases support three Linux architectures.
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = "riscv64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-94f2j1X15EdOR9+o1HJfcfA/X7wRdUjVlwA9BFmC+R8=";
    arm64   = "sha256-fxyC7kUJzQ2xysqpP9pF6bSz6L+5kru6MsVD8I7fS7Q=";
    riscv64 = "sha256-mzaW2ywlq9yyoxm1YBWqSi619aYIo1vC5D4qac4teZI=";
  };

  tuiHashes = {
    x64     = "sha256-0CoHU/9Pin7UrhmyxFI12R83KvPh6nptW8Kculsxio0=";
    arm64   = "sha256-HJst2hOvieI7QKnxc17D4cqjG4pWmIkqgd3bxbWJPUY=";
    riscv64 = "sha256-NY+CQT2zzbT1sOjXMksaDLwqHdPWJeoY6PisZJmuYq4=";
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