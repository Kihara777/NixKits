{
  lib,
  rustPlatform,
}:

let
  cargoToml = builtins.fromTOML (builtins.readFile ./kitsfmt-src/Cargo.toml);
in
rustPlatform.buildRustPackage {
  pname = "kitsfmt";
  version = cargoToml.package.version;

  src = ./kitsfmt-src;

  cargoLock = {
    lockFile = ./kitsfmt-src/Cargo.lock;
  };

  doCheck = true;

  meta = {
    description = "A Nix configuration formatter with AST-based sorting, merging, and comment preservation";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
