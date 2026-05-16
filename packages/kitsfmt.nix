{ lib, stdenv, cargo, rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "kitsfmt";
  version = "0.3.0";

  src = ./packages/kitsfmt-src;

  # 不指定 cargoLock，让 nix 自动生成
  # cargoLock = {
  #   lockFile = ../packages/kitsfmt-src/Cargo.lock;
  # };

  meta = with lib; {
    description = "A Nix configuration formatter with AST-based sorting, merging, and comment preservation";
    homepage = "https://github.com/Kihara777/NixKits";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
