{
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh-nix-shell";
  version = "0.2.0";

  src = ./dsh-nix-shell;

  # dsh ecosystem rc.7 packages declare peers against unreleased rc.8
  # prereleases; the plugin resolves those peers from the host dsh tree at
  # runtime.  Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js committed); no build script to run.
  dontNpmBuild = true;

  # npm package tarballs ship no lock file; the one in src/ is committed.
  npmDepsHash = "sha256-5zDwzj6ek3C0KmN5JiVsJU8fCQKERbarsY9nlBDBoHI=";

  meta = {
    description = "NixOS-aware shell tool plugin for the DeepSeek Harness (dsh)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
