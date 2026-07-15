{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
}:

let
  version = "0.8.67";

  # Prebuilt binaries from GitHub Releases — x86_64 and aarch64 only.
  # riscv64 is built from source (see codewhale-src.nix).
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = throw "codewhale: riscv64 must be built from source via codewhale-src.nix";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-xl02Q6a1/+XI+YdfHDDfgZl2W2TLna9muDg9Rdn8q0s=";
    arm64   = "sha256-6dexeyBHj0F7Pmoad0FKsyw8Uo6SscMX510YLeh0sXk=";
  };

  tuiHashes = {
    x64     = "sha256-JkUeBFM/dennS6l0pi7mgbPQA3eTOUcYDhEydOGXBBs=";
    arm64   = "sha256-8DqnQ1K97wK4gDwGuXu+zXqbnuZz7Gh895R7oFq9KQI=";
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