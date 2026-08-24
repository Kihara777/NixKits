{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dbus,
  allowSudo ? false,
}:

let
  version = "0.9.11";

  # Prebuilt binaries from GitHub Releases — x86_64 and aarch64 only.
  # riscv64 is built from source (see codewhale-src.nix).
  archSuffix = {
    "x86_64-linux"  = "x64";
    "aarch64-linux" = "arm64";
    "riscv64-linux" = throw "codewhale: riscv64 must be built from source via codewhale-src.nix";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported platform: ${stdenv.hostPlatform.system}");

  cliHashes = {
    x64     = "sha256-wClpVW5R4Tivo/6cl6E1mHjNPRmGsc4fX6lsk8aQlBY=";
    arm64   = "sha256-YKFFUemUdHpPTdt3m5whxtdao+f9+EUVVDdIRQqkjxg=";
  };

  tuiHashes = {
    x64     = "sha256-wClpVW5R4Tivo/6cl6E1mHjNPRmGsc4fX6lsk8aQlBY=";
    arm64   = "sha256-YKFFUemUdHpPTdt3m5whxtdao+f9+EUVVDdIRQqkjxg=";
  };

  codewhale-cli = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codewhale-linux-${archSuffix}";
    hash = cliHashes.${archSuffix};
  };
  # The TUI binary was renamed `codewhale-tui` → `codew` upstream in v0.9.9
  # (release asset `codew-linux-*`; same compiled runtime as the main CLI).
  codewhale-tui = fetchurl {
    url = "https://github.com/Hmbown/CodeWhale/releases/download/v${version}/codew-linux-${archSuffix}";
    hash = tuiHashes.${archSuffix};
  };

  # ptrace-based syscall interceptor for statically-linked codewhale binaries.
  # Codewhale is statically linked so LD_PRELOAD cannot work; we use ptrace
  # to intercept prctl(PR_SET_NO_NEW_PRIVS) and prctl(PR_SET_SECCOMP) at the
  # kernel boundary.
  sudoPtrace = stdenv.mkDerivation {
    name = "codewhale-sudo-ptrace";
    src = ./codewhale-sudo-ptrace.c;
    dontUnpack = true;
    buildPhase = ''
      cp $src codewhale-sudo-ptrace.c
      $CC -std=c99 -Wall -Wextra -O2 -o codewhale-sudo-ptrace codewhale-sudo-ptrace.c
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp codewhale-sudo-ptrace $out/bin/
    '';
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
    install -Dm755 ${codewhale-cli} $out/bin/.codewhale-wrapped
    install -Dm755 ${codewhale-tui} $out/bin/.codew-wrapped
  '' + lib.optionalString allowSudo ''
    # ptrace-based sudo intercept: launch codewhale through the ptrace wrapper
    # which intercepts prctl(PR_SET_NO_NEW_PRIVS) and prctl(PR_SET_SECCOMP)
    # at the kernel boundary.
    cat > $out/bin/codewhale << WRAPEOF
#!${stdenv.shell}
export CODEWHALE_ALLOW_SUDO=1
exec ${sudoPtrace}/bin/codewhale-sudo-ptrace ${placeholder "out"}/bin/.codewhale-wrapped "\$@"
WRAPEOF
    chmod +x $out/bin/codewhale

    cat > $out/bin/codew << WRAPEOF
#!${stdenv.shell}
export CODEWHALE_ALLOW_SUDO=1
exec ${sudoPtrace}/bin/codewhale-sudo-ptrace ${placeholder "out"}/bin/.codew-wrapped "\$@"
WRAPEOF
    chmod +x $out/bin/codew
  '' + lib.optionalString (!allowSudo) ''
    mv $out/bin/.codewhale-wrapped $out/bin/codewhale
    mv $out/bin/.codew-wrapped $out/bin/codew
  '' + ''
    # Backward-compat alias for the pre-0.9.9 binary name (codewhale-tui).
    ln -s codew $out/bin/codewhale-tui
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