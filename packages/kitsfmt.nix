{ lib, stdenv, cargo, rustPlatform, nixpkgs-fmt, fetchFromGitHub }:

let
  buildRustPackage = rustPlatform.buildRustPackage;
in

buildRustPackage {
  name = "kitsfmt-0.1.0";

  src = ./kitsfmt-src;

  nativeBuildInputs = [ cargo ];

  cargoLock = {
    lockFile = ../packages/kitsfmt-src/Cargo.lock;
  };

  meta = with lib; {
    description = "A minimal Nix configuration formatter written in Rust";
    homepage = "https://github.com/Kihara777/NixKits";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
