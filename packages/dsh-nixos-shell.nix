{
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "dsh-nixos-shell";
  version = "0.1.0";

  src = ./dsh-nixos-shell;

  # Embed the repository's canonical skills/ tree so the maintenance-skills
  # preset entry (维护模式) can register the latest skill content as runtime
  # skills at apply time — the repo skills/ directory stays the single source
  # of truth, the package snapshots it at build time.
  postPatch = ''
    cp -r ${../skills} ./skills-embedded
    chmod -R u+w ./skills-embedded
  '';

  # dsh ecosystem packages declare peers against same-release prereleases;
  # the plugin resolves those peers from the host dsh tree at runtime.
  # Lock generation and install both need the legacy resolver.
  npmFlags = [ "--legacy-peer-deps" ];

  # Pure JS plugin (lib/index.js committed); no build script to run.
  dontNpmBuild = true;

  # Same dependency tree as the former dsh-nix-shell package (dsh-tools +
  # schemastery, peers resolved at runtime from the host dsh tree).
  npmDepsHash = "sha256-bAXZCiAJ6h+vykOG1+MnD1a3MNzA2Z/429FokpgDmfY=";

  meta = {
    description = "Consolidated NixOS operations plugin for the DeepSeek Harness (shell execution, tool bootstrap, sudo daemon routing, read-only NixOS diagnostics, NixOS-mode gate and maintenance-mode skill presets)";
    homepage = "https://github.com/Kihara777/NixKits";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
