{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dbus,
  allowSudo ? false,
}:

let
  version = "0.9.0";

  # Prebuilt binaries from GitHub Releases — x86_64 and aarch64 only.
  # riscv64 is built from source (see codewhale-src.nix).
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = throw "codewhale: riscv64 must be built from source via codewhale-src.nix";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-oBdJ1ND0zrvx+2LlyfOTy1wFtXDaFEF2I450BVLej8o=";
    arm64   = "sha256-6mCCJF34n7A+eWlrTHt3WnORarLR1O7wXA36kR0yH0M=";
  };

  tuiHashes = {
    x64     = "sha256-CKFC/CVfI+AOBJQW1OpT9/t34Cbgk+vfrRaEfAkGyFs=";
    arm64   = "sha256-e4BOVVfBJiXfw7erlqXX46GgdbdC9Km6qNFjqigizl0=";
  };

  codewhale-cli = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-linux-${archSuffix}";
    hash = cliHashes.${archSuffix};
  };
  codewhale-tui = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-tui-linux-${archSuffix}";
    hash = tuiHashes.${archSuffix};
  };

  # LD_PRELOAD shim to intercept prctl(PR_SET_NO_NEW_PRIVS) and prctl(PR_SET_SECCOMP)
  sudoShim = stdenv.mkDerivation {
    name = "codewhale-sudo-shim";
    src = ./codewhale-sudo-shim.c;
    buildPhase = ''
      $CC -shared -fPIC -o libcodewhale-sudo-shim.so $src -ldl
    '';
    installPhase = ''
      mkdir -p $out/lib
      cp libcodewhale-sudo-shim.so $out/lib/
    '';
  };
in
stdenv.mkDerivation {
  pname = "codewhale";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ] ++ lib.optionals allowSudo [
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    dbus
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 ${codewhale-cli} $out/bin/.codewhale-wrapped
    install -Dm755 ${codewhale-tui} $out/bin/.codewhale-tui-wrapped
  '' + lib.optionalString allowSudo ''
    makeWrapper $out/bin/.codewhale-wrapped $out/bin/codewhale \
      --prefix LD_PRELOAD : ${sudoShim}/lib/libcodewhale-sudo-shim.so \
      --set-default CODEWHALE_ALLOW_SUDO 1
    makeWrapper $out/bin/.codewhale-tui-wrapped $out/bin/codewhale-tui \
      --prefix LD_PRELOAD : ${sudoShim}/lib/libcodewhale-sudo-shim.so \
      --set-default CODEWHALE_ALLOW_SUDO 1
  '' + lib.optionalString (!allowSudo) ''
    mv $out/bin/.codewhale-wrapped $out/bin/codewhale
    mv $out/bin/.codewhale-tui-wrapped $out/bin/codewhale-tui
  '' + ''
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