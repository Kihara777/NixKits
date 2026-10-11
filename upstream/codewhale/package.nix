{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  dbus,
}:

rustPlatform.buildRustPackage rec {
  pname = "codewhale";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "codewhale-hq";
    repo = "Codewhale";
    tag = "v${version}";
    hash = "sha256-/aTVxY+l3S30wm31BlWExbkIZx8s2R2lqCsQJVZa7TE=";
  };

  cargoHash = "sha256-DUobhZ6hmrhsyl3VcVhFJnFWZi3QEE77QPq2DPtpTNY=";

  strictDeps = true;
  # nixpkgs-vet ratchets: a new top-level package must *evaluate* with both of
  # these true (the README says "must evaluate with", not "must be written").
  # Measured: without this line the attribute evaluates to false, while 2192
  # packages under pkgs/by-name set it.
  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [ dbus ];

  # Only the CLI and TUI are the default workspace members; everything else in
  # the workspace is libraries they link against.
  buildAndTestSubdir = "crates/cli";

  doCheck = false;

  # Upstream's release archives ship the same binary under both names and tell
  # Cargo users to add a `codew` symlink, so mirror that shape.
  postInstall = ''
    ln -s codewhale $out/bin/codew
  '';

  meta = {
    description = "Open-source Rust agent engine and terminal client";
    homepage = "https://github.com/codewhale-hq/Codewhale";
    changelog = "https://github.com/codewhale-hq/Codewhale/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "codewhale";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ grg41 ];
  };
}
