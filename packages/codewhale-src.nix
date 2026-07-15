{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  dbus,
  autoPatchelfHook,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "codewhale";
  version = "0.8.67";

  src = fetchFromGitHub {
    owner = "Hmbown";
    repo = "CodeWhale";
    rev = "v${version}";
    hash = "sha256-a6URxUWHxtVDHG7HTsld3OvNCpLwPn0ycmwU9F4HXsA=";
  };

  # Cargo.lock is in workspace root
  cargoLock = {
    lockFile = ./codewhale-src-Cargo.lock;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    autoPatchelfHook
  ];

  buildInputs = [
    dbus
  ];

  # Only build CLI and TUI (default workspace members)
  buildAndTestSubdir = "crates/cli";

  # Skip tests during build (they require network access)
  doCheck = false;

  # Build both CLI and TUI binaries
  postInstall = ''
    # Build TUI binary as well (not part of default-members)
    cargo build --release -p codewhale-tui
    install -Dm755 target/release/codewhale-tui -t $out/bin
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