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

  cargoVendorDir = "vendor";

  doCheck = true;

  meta = {
    description = "A Nix configuration formatter with AST-based sorting, merging, and comment preservation";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    mainProgram = "kitsfmt";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
