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
  version = "0.9.0";

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

  # ring/cc crate passes -m64 (x86_64 host flag) to riscv64 cross-compiler.
  # The fix from commit 7160431 cleared per-target CFLAGS but the cc crate
  # also picks up the generic CFLAGS from the build environment.  Clear both
  # per-target and generic CFLAGS/CXXFLAGS so that cc-rs receives a clean
  # flag set for the target architecture.
  env = lib.optionalAttrs stdenv.hostPlatform.isRiscV {
    CFLAGS_riscv64_unknown_linux_gnu = "";
    CXXFLAGS_riscv64_unknown_linux_gnu = "";
    CFLAGS = "";
    CXXFLAGS = "";
    # cc-rs also inherits from Nix's internal flag variables; clear those too
    # so -m64 (x86_64-only) doesn't leak into the riscv64 cross-compiler.
    NIX_CFLAGS_COMPILE = "";
    NIX_CXXFLAGS_COMPILE = "";
  };

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