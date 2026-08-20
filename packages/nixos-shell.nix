{
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "nixos-shell";
  version = "0.1.0";

  src = ./nixos-shell;

  # dsh ecosystem rc.7 packages declare peers against unreleased rc.8
  # prereleases; the plugin resolves those peers from the host dsh tree at
  # runtime.  Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js committed); no build script to run.
  dontNpmBuild = true;

  # Same dependency tree as the former dsh-nix-shell package (dsh-tools +
  # schemastery, peers resolved at runtime from the host dsh tree).
  npmDepsHash = "sha256-18Z9sTpUA/dvsKc+gqTdwklMHPpDMzar0B7urHamKGI=";

  meta = {
    description = "Consolidated NixOS operations plugin for the DeepSeek Harness (shell execution, tool bootstrap, sudo daemon routing, read-only NixOS diagnostics)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
